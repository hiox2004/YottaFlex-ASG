"""Business validation: date order, arithmetic reconciliation, lifecycle, duplicates.

Derived amounts are replayed from source records with rules.payable in processing order, using the REPLAYED
(expected) amounts for committed limits, so a corrupted settlement is flagged alone and does not shift later claims.
"""

from collections import defaultdict
from itertools import pairwise

from claimsgen import config, rules
from claimsgen.checks_structure import Check
from claimsgen.engine import World


def _group(rows, key="claim_id"):
    out = defaultdict(list)
    for r in rows:
        out[r[key]].append(r)
    return out


def business_checks(t: dict) -> list[Check]:
    order = Check("dates", "date order across the claim lifecycle")
    arith = Check("arithmetic", "totals, payable, reserve and settlement reconcile")
    life = Check("lifecycle", "legal transitions, approval before payment, roles")
    dup = Check("duplicates", "duplicate claims are referred; no duplicate documents")
    w = World(t)
    history, assess = _group(t["claim_status_history"]), _group(t["assessment"])
    reserves, settles = _group(t["reserve"]), _group(t["settlement"])
    assigns = _group(t["claim_adjuster_assignment"])
    # a claim denied at intake by R-COV-01 is the one case where activity precedes the policy start
    intake_denied = {
        e["claim_id"]
        for e in t["claim_status_history"]
        if e["to_status"] == "denied" and e["rule_id"] == "R-COV-01"
    }
    for p_id, evs in _group(t["policy_event"], "policy_id").items():
        order.checked += 1
        p = w.policy[p_id]
        dates = [e["event_date"] for e in evs]
        if (
            evs[0]["event_type"] != "issued"
            or dates != sorted(dates)
            or dates[0] != p["start_date"]
        ):
            order.fail(p_id, "policy events out of order")
    committed: dict = defaultdict(int)
    for c in w.claims:
        cid, inc, p = c["claim_id"], w.incident[c["incident_id"]], w.policy[c["policy_id"]]
        a_rows, sets = assess.get(cid, []), settles.get(cid, [])
        last = a_rows[-1] if a_rows else None
        # --- date order
        order.checked += 1
        bad = inc["incident_date"] > c["submission_date"]
        if cid not in intake_denied:
            bad = (
                bad
                or p["start_date"] > inc["incident_date"]
                or inc["incident_date"] > p["end_date"]
            )
        bad = bad or any(a["assigned_date"] < c["submission_date"] for a in assigns[cid])
        bad = bad or any(d["received_date"] < c["submission_date"] for d in w.docs[cid])
        bad = bad or any(a["assessment_date"] < c["submission_date"] for a in a_rows)
        bad = bad or any(r["reserve_date"] < c["submission_date"] for r in reserves.get(cid, []))
        if bad:
            order.fail(cid, "claim dates out of order")
        for s in sets:
            order.checked += 1
            chain = [s["recommended_date"], s["approved_date"], s["paid_date"]]
            chain = [d for d in chain if d is not None]
            if chain != sorted(chain) or (last and s["recommended_date"] < last["assessment_date"]):
                order.fail(s["settlement_id"], "settlement dates out of order")
        # --- arithmetic
        arith.checked += 1
        if c["claimed_amount"] != sum(i["claimed_amount"] for i in w.items[cid]):
            arith.fail(cid, "claimed_amount != sum of items")
        for a in a_rows:
            if a["eligible_amount"] > c["claimed_amount"] or (
                a["decision"] != "approve" and a["payable_amount"]
            ):
                arith.fail(a["assessment_id"], "eligible/payable inconsistent with decision")
        for a in a_rows:  # the requested document types are a derived value: recompute them
            want = (
                "|".join(
                    rules.missing_docs(
                        w.required[c["claim_type"]], w.docs[cid], c["submission_date"]
                    )
                )
                if a["decision"] == "pend_docs"
                else ""
            )
            if a["missing_doc_types"] != want:
                arith.fail(a["assessment_id"], "missing_doc_types does not match the recomputation")
        approved = last is not None and last["decision"] == "approve"
        if approved:
            exp = rules.payable(
                rules.eligible_by_coverage(
                    rules.covered_items(
                        w.items[cid], w.incident[c["incident_id"]]["incident_type"], w.terms
                    ),
                    w.exclusions,
                ),
                w.pcv[p["policy_id"]],
                committed,
            )
            for cov, amount in exp.by_coverage.items():
                committed[(p["policy_id"], cov)] += amount
            arith.checked += 1
            if (last["eligible_amount"], last["deductible_applied"], last["payable_amount"]) != (
                exp.eligible,
                exp.deductible,
                exp.payable,
            ):
                arith.fail(last["assessment_id"], "assessment does not replay from source records")
            for s in sets:
                arith.checked += 1
                if s["recommended_amount"] != exp.payable:
                    arith.fail(
                        s["settlement_id"],
                        f"recommended {s['recommended_amount']} != replayed {exp.payable}",
                    )
        # reserve: FNOL row first (recomputed), then the decisive assessment's payable (0 on denial)
        res = reserves.get(cid, [])
        arith.checked += 1
        fnol = rules.fnol_reserve(w.items[cid], w.pcv[p["policy_id"]])
        final = last["payable_amount"] if last and last["decision"] in ("approve", "deny") else fnol
        if not res or res[0]["amount"] != fnol or res[0]["basis"] != "preliminary":
            arith.fail(res[0]["reserve_id"] if res else cid, "first reserve != FNOL recomputation")
        elif res[-1]["amount"] != final:
            arith.fail(res[-1]["reserve_id"], "latest reserve != final payable (FNOL if undecided)")
        for s in sets:
            if s["approved_date"] and s["approved_amount"] != s["recommended_amount"]:
                arith.fail(s["settlement_id"], "approved != recommended")
            if s["paid_date"] and s["paid_amount"] != s["approved_amount"]:
                arith.fail(s["settlement_id"], "paid != approved")
        # --- lifecycle
        life.checked += 1
        evs = history[cid]
        ok = evs[0]["from_status"] == "" and evs[0]["to_status"] == "submitted"
        for prev, cur in pairwise(evs):
            ok = (
                ok
                and cur["from_status"] == prev["to_status"]
                and cur["to_status"] in rules.TRANSITIONS[cur["from_status"]]
            )
            ok = ok and prev["event_date"] <= cur["event_date"]
        if not ok:
            life.fail(cid, "illegal or unordered status history")
        for n, s in enumerate(sets, start=1):
            life.checked += 1
            if n > 1:
                life.fail(s["settlement_id"], "more than one settlement for a claim")
            if not approved:
                life.fail(s["settlement_id"], "settlement without an approving assessment")
            if s["paid_date"] and not s["approved_date"]:
                life.fail(s["settlement_id"], "paid without approval")
            if s["approved_date"]:
                role = (
                    "approver"
                    if s["recommended_amount"] > config.APPROVER_THRESHOLD_CENTS
                    else "process_owner"
                )
                event = next((e for e in evs if e["to_status"] == "approved"), None)
                if s["approver_role"] != role or (
                    event and event["actor_role"] != s["approver_role"]
                ):
                    life.fail(s["settlement_id"], "approver role does not match R-APR-01")
            if bool(s["paid_date"]) != any(e["to_status"] == "paid" for e in evs):
                life.fail(s["settlement_id"], "settlement stage disagrees with status history")
    # --- duplicates
    seen: set = set()
    for c in w.claims:
        dup.checked += 1
        key = (c["policy_id"], w.incident[c["incident_id"]]["incident_date"], c["claim_type"])
        first = assess.get(c["claim_id"], [None])[0]
        if key in seen and first and first["decision"] in ("approve", "pend_docs"):
            dup.fail(c["claim_id"], "duplicate claim was not referred for review")
        seen.add(key)
    kinds: set = set()
    for d in t["document"]:
        k = (d["claim_id"], d["doc_type"])
        dup.checked += 1
        if k in kinds:
            dup.fail(d["document_id"], "duplicate document type on a claim")
        kinds.add(k)
    return [order, arith, life, dup]
