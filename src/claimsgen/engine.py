"""Step 4 of the pipeline: the rules engine. Turns claims into assignments, assessments, reserves (FNOL, then revised), settlements
and an append-only status history. Every outcome is derived from rules.py; nothing here is randomly assigned except
processing delays and the 5% reassignment, which only move dates and adjusters.

Claims are processed in submission-date order (then incident date, policy, claim id), never by claim_id alone. A step whose date would fall after AS_OF is not
taken, so recent claims honestly stay in an earlier status.
"""

from collections import defaultdict
from datetime import timedelta

from claimsgen import config, ids, rules
from claimsgen.decide import Decision, evaluate

STATUS = {
    "deny": "denied",
    "refer_review": "under_review",
    "pend_docs": "docs_pending",
    "approve": "assessed",
}


class World:
    def __init__(self, t: dict, as_of=None, fraud_threshold=None, approver_threshold_cents=None):
        self.as_of = as_of or config.AS_OF
        self.fraud_threshold = (
            config.FRAUD_THRESHOLD if fraud_threshold is None else fraud_threshold
        )
        self.approver_threshold_cents = (
            config.APPROVER_THRESHOLD_CENTS
            if approver_threshold_cents is None
            else approver_threshold_cents
        )
        self.policy = {p["policy_id"]: p for p in t["policy"]}
        self.incident = {i["incident_id"]: i for i in t["incident"]}
        # processing order is by dates, never by (provisional) claim_id
        self.claims = sorted(
            t["claim"],
            key=lambda c: (
                c["submission_date"],
                self.incident[c["incident_id"]]["incident_date"],
                c["policy_id"],
                c["claim_id"],
            ),
        )
        self.items, self.docs = defaultdict(list), defaultdict(list)
        for i in t["claim_item"]:
            self.items[i["claim_id"]].append(i)
        for d in t["document"]:
            self.docs[d["claim_id"]].append(d)
        self.pcv = defaultdict(dict)
        for r in t["policy_coverage"]:
            self.pcv[r["policy_id"]][r["coverage_id"]] = r
        self.exclusions = {
            c["coverage_id"]: set(filter(None, c["exclusion_codes"].split("|")))
            for c in t["coverage"]
        }
        self.terms = {
            c["coverage_id"]: (
                set(c["covered_incident_types"].split("|")),
                set(c["covered_item_types"].split("|")),
            )
            for c in t["coverage"]
        }
        self.ends: dict = {}
        for e in sorted(t["policy_event"], key=lambda e: e["event_date"]):
            if e["event_type"] in ("lapsed", "cancelled"):
                self.ends.setdefault(e["policy_id"], e["event_date"])
        self.required = defaultdict(set)
        for r in t["document_requirement"]:
            if r["mandatory"] == "Y":
                self.required[r["claim_type"]].add(r["doc_type"])
        self.adjusters = defaultdict(list)
        for a in sorted(t["adjuster"], key=lambda a: a["adjuster_id"]):
            self.adjusters[a["specialty"]].append(a["adjuster_id"])
        self.committed: dict = defaultdict(int)
        self.customer_subs = defaultdict(list)
        self.seen_keys: set = set()
        self.seq: dict = defaultdict(int)
        self.out = {
            k: []
            for k in (
                "claim_adjuster_assignment",
                "assessment",
                "reserve",
                "settlement",
                "claim_status_history",
            )
        }


def _event(w, cid, frm, to, day, role, rule, reason):
    w.seq[cid] += 1
    w.out["claim_status_history"].append(
        {
            "event_id": ids.evt(cid, w.seq[cid]),
            "claim_id": cid,
            "from_status": frm,
            "to_status": to,
            "event_date": day,
            "actor_role": role,
            "rule_id": rule,
            "reason_code": reason,
        }
    )


def _assign(w, c, day, reason, pick: float, exclude=None) -> str:
    """Pick an adjuster of the claim's specialty from a per-claim random number (no shared load state)."""
    pool = [a for a in w.adjusters[c["claim_type"]] if a != exclude]
    adjuster = pool[int(pick * len(pool))]
    rows = w.out["claim_adjuster_assignment"]
    n = 1 + sum(r["claim_id"] == c["claim_id"] for r in rows[-3:])
    rows.append(
        {
            "assignment_id": ids.asn(c["claim_id"], n),
            "claim_id": c["claim_id"],
            "adjuster_id": adjuster,
            "assigned_date": day,
            "reason": reason,
        }
    )
    return adjuster


def _assess(w, c, adjuster, day, d: Decision, frm: str):
    cid = c["claim_id"]
    n = 1 + sum(r["claim_id"] == cid for r in w.out["assessment"][-3:])
    w.out["assessment"].append(
        {
            "assessment_id": ids.asm(cid, n),
            "claim_id": cid,
            "adjuster_id": adjuster,
            "assessment_date": day,
            "decision": d.decision,
            "rule_id": d.rule_id,
            "reason_code": d.reason,
            "eligible_amount": d.eligible,
            "deductible_applied": d.deductible,
            "payable_amount": d.payable,
            "fraud_score": d.score,
            "missing_doc_types": d.missing,
        }
    )
    _event(w, cid, frm, STATUS[d.decision], day, "operations_analyst", d.rule_id, d.reason)


def _reserve(w, cid, day, amount, basis, rule):
    rows = w.out["reserve"]
    n = 1 + sum(r["claim_id"] == cid for r in rows[-3:])
    rows.append(
        {
            "reserve_id": ids.rsv(cid, n),
            "claim_id": cid,
            "reserve_date": day,
            "amount": amount,
            "basis": basis,
            "rule_id": rule,
        }
    )


def _resume_date(w, c):
    """Date the last late mandatory document arrived, if every missing type eventually arrived."""
    missing = rules.missing_docs(
        w.required[c["claim_type"]], w.docs[c["claim_id"]], c["submission_date"]
    )
    arrived = {
        d["doc_type"]: d["received_date"]
        for d in w.docs[c["claim_id"]]
        if d["status"] == "received"
    }
    return max(arrived[t] for t in missing) if all(t in arrived for t in missing) else None


def _settle(w, c, d: Decision, day, delays):
    cid, as_of = c["claim_id"], w.as_of
    for cov, amount in d.payout.by_coverage.items():
        w.committed[(c["policy_id"], cov)] += amount
    role = "approver" if d.payable > w.approver_threshold_cents else "process_owner"
    lo, hi = config.APPROVAL_DAYS[role]
    approved = day + timedelta(days=lo + int(delays[1] * (hi - lo + 1)))
    paid = approved + timedelta(days=delays[2])
    row = {
        "settlement_id": ids.settlement(cid, 1),
        "claim_id": cid,
        "recommended_amount": d.payable,
        "recommended_date": day,
        "approved_amount": None,
        "approved_date": None,
        "approver_role": None,
        "paid_amount": None,
        "paid_date": None,
    }
    w.out["settlement"].append(row)
    if approved > as_of:
        return
    row.update(approved_amount=d.payable, approved_date=approved, approver_role=role)
    _event(w, cid, "assessed", "approved", approved, role, "R-APR-01", "approved_by_authority")
    if paid <= as_of:
        row.update(paid_amount=d.payable, paid_date=paid)
        _event(w, cid, "approved", "paid", paid, "administrator", "R-APR-01", "payment_recorded")


def _ready_date(w, c):
    """Earliest date all in-window documents have arrived (an assessment cannot precede them)."""
    sub = c["submission_date"]
    window = [
        d["received_date"]
        for d in w.docs[c["claim_id"]]
        if (d["received_date"] - sub).days <= config.DOC_WINDOW_DAYS
    ]
    return max(window, default=sub)


def _process(w: World, c: dict, rng):
    # fixed draw order per claim; the stream depends only on the claim's own stable fields
    # three draws per claim, always: assessment days (per product), a uniform for approval days, payment days
    delays = (rng.randint(*config.ASSESS_DAYS[c["claim_type"]]), rng.random(), rng.randint(1, 5))
    reassign, pick1, pick2 = rng.random() < 0.05, rng.random(), rng.random()
    cid, sub, as_of = c["claim_id"], c["submission_date"], w.as_of
    key = (c["policy_id"], w.incident[c["incident_id"]]["incident_date"], c["claim_type"])
    duplicate = key in w.seen_keys
    w.seen_keys.add(key)
    _event(w, cid, "", "submitted", sub, "requester", "", "submitted")
    fnol = rules.fnol_reserve(w.items[cid], w.pcv[c["policy_id"]])
    _reserve(w, cid, sub, fnol, "preliminary", "R-RSV-01")
    adjuster = _assign(w, c, sub, "initial", pick1)
    if reassign and sub < as_of and len(w.adjusters[c["claim_type"]]) > 1:
        adjuster = _assign(w, c, sub + timedelta(days=1), "reassigned", pick2, exclude=adjuster)
    day = max(sub + timedelta(days=delays[0]), _ready_date(w, c))
    if day > as_of:
        return
    d = evaluate(w, c, duplicate, resumed=False)
    _assess(w, c, adjuster, day, d, "submitted")
    if d.decision == "pend_docs":
        resume = _resume_date(w, c)
        # a late document that arrived before the pend was recorded is picked up the next day, never before it
        day = None if resume is None else max(resume, day + timedelta(days=1))
        if day is None or day > as_of:
            return
        d = evaluate(w, c, duplicate, resumed=True)
        _assess(w, c, adjuster, day, d, "docs_pending")
    if d.decision in ("approve", "deny") and d.payable != w.out["reserve"][-1]["amount"]:
        _reserve(w, cid, day, d.payable, "revised", "R-RSV-02")
    if d.decision == "approve":
        _settle(w, c, d, day, delays)


def run(
    tables: dict, as_of=None, *, fraud_threshold=None, approver_threshold_cents=None
) -> dict[str, list[dict]]:
    """as_of, fraud_threshold and approver_threshold_cents default to the config values (read once per run).

    A later as_of lets recent claims progress; overriding thresholds is how what-if and the sensitivity
    sweep vary them without ever mutating config (safe under concurrent sessions).
    """
    w = World(tables, as_of, fraud_threshold, approver_threshold_cents)
    for c in w.claims:
        incident_date = w.incident[c["incident_id"]]["incident_date"]
        stream = f"engine:{c['policy_id']}:{incident_date}:{c['submission_date']}:{c['claim_type']}"
        _process(w, c, config.rng(stream))
        w.customer_subs[w.policy[c["policy_id"]]["customer_id"]].append(c["submission_date"])
    return w.out
