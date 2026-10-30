"""Step 5 of the pipeline: inject the six labelled edge cases into a clean baseline.

Targets are clean (never planted) claims whose policy AND customer have exactly that one claim, so changing them cannot
move any other claim (limits, duplicates and the F2 window are all per policy/customer). Target sets are disjoint.
Business-outcome cases mutate inputs and re-run the engine; integrity-defect cases patch engine outputs afterwards and
are never re-run. Labels are returned separately; no input table gets a label column.
"""

import copy
from collections import Counter, defaultdict
from datetime import timedelta

from claimsgen import config, engine, ids

BUSINESS = {
    "claim_before_policy_start": ("R-COV-01", "deny: at intake, coverage not yet effective"),
    "cancelled_before_incident": ("R-COV-02", "deny: policy was cancelled before the incident"),
    "duplicate_incident": ("R-ELG-03", "refer_review: flag the later claim as a duplicate"),
    "missing_mandatory_doc": (
        "R-DOC-01",
        "pend_docs: request the document, hold in docs_pending, no settlement",
    ),
}
LIVE = ("assessed", "approved", "paid")


def _pools(data: dict, planted: list) -> tuple[list, list]:
    special = {p["claim_id"] for p in planted}
    policy = {p["policy_id"]: p for p in data["policy"]}
    per_policy = Counter(c["policy_id"] for c in data["claim"])
    per_customer = Counter(policy[c["policy_id"]]["customer_id"] for c in data["claim"])
    status = {}
    for e in data["claim_status_history"]:
        status[e["claim_id"]] = e["to_status"]
    covs = defaultdict(set)
    for i in data["claim_item"]:
        covs[i["claim_id"]].add(i["coverage_id"])
    base = [
        c
        for c in sorted(data["claim"], key=lambda c: c["claim_id"])
        if c["claim_id"] not in special
        and per_policy[c["policy_id"]] == 1
        and per_customer[policy[c["policy_id"]]["customer_id"]] == 1
        and status.get(c["claim_id"]) in LIVE
    ]
    paid = [c for c in base if status[c["claim_id"]] == "paid" and len(covs[c["claim_id"]]) == 1]
    return base, paid


def _take(rng, pool: list, k: int, used: set, ok=lambda c: True) -> list:
    candidates = [c for c in pool if c["claim_id"] not in used and ok(c)]
    if len(candidates) < k:
        raise RuntimeError(f"only {len(candidates)} eligible injection targets, need {k}")
    chosen = sorted(rng.sample(candidates, k), key=lambda c: c["claim_id"])
    used.update(c["claim_id"] for c in chosen)
    return chosen


def _entry(label, kind, entity_type, entity_id, rule, expected, detail=""):
    return {
        "label": label,
        "kind": kind,
        "entity_type": entity_type,
        "entity_id": entity_id,
        "rule_id": rule,
        "expected_decision": expected,
        "detail": detail,
    }


def _before_start(rng, inp, c, ix) -> dict:
    p, inc = ix["policy"][c["policy_id"]], ix["incident"][c["incident_id"]]
    new_incident = p["start_date"] - timedelta(days=rng.randint(3, 30))
    new_sub = min(
        new_incident + timedelta(days=rng.randint(0, 2)), p["start_date"] - timedelta(days=1)
    )
    delta = new_sub - c["submission_date"]
    for d in inp["document"]:
        if d["claim_id"] == c["claim_id"]:
            d["received_date"] += delta
    inc["incident_date"], c["submission_date"] = new_incident, new_sub
    return _entry(
        "claim_before_policy_start",
        "business_outcome",
        "claim",
        c["claim_id"],
        *BUSINESS["claim_before_policy_start"],
    )


def _cancelled(rng, inp, c, ix) -> dict:
    p, inc = ix["policy"][c["policy_id"]], ix["incident"][c["incident_id"]]
    gap = rng.randint(1, min(30, (inc["incident_date"] - p["start_date"]).days - 1))
    inp["policy_event"].append(
        {
            "event_id": ids.pev(p["policy_id"], 2),
            "policy_id": p["policy_id"],
            "event_type": "cancelled",
            "event_date": inc["incident_date"] - timedelta(days=gap),
        }
    )
    return _entry(
        "cancelled_before_incident",
        "business_outcome",
        "claim",
        c["claim_id"],
        *BUSINESS["cancelled_before_incident"],
    )


def _duplicate(rng, inp, c, ix, k: int) -> dict:
    claim_id, inc_id = ids.clm(900000 + k), ids.inc(900000 + k)
    sub = c["submission_date"] + timedelta(days=rng.randint(1, 10))
    inp["incident"].append(dict(ix["incident"][c["incident_id"]], incident_id=inc_id))
    inp["claim"].append(dict(c, claim_id=claim_id, incident_id=inc_id, submission_date=sub))
    for n, i in enumerate(
        (i for i in inp["claim_item"] if i["claim_id"] == c["claim_id"]), start=1
    ):
        inp["claim_item"].append(dict(i, item_id=ids.itm(claim_id, n), claim_id=claim_id))
    docs = [d for d in inp["document"] if d["claim_id"] == c["claim_id"]]
    for n, d in enumerate(docs, start=1):
        received = min(config.AS_OF, sub + (d["received_date"] - c["submission_date"]))
        inp["document"].append(
            dict(d, document_id=ids.doc(claim_id, n), claim_id=claim_id, received_date=received)
        )
    return _entry(
        "duplicate_incident",
        "business_outcome",
        "claim",
        claim_id,
        *BUSINESS["duplicate_incident"],
        detail=c["claim_id"],
    )


def _drop_doc(rng, inp, c, ix) -> dict:
    mandatory = {
        r["doc_type"]
        for r in inp["document_requirement"]
        if r["claim_type"] == c["claim_type"] and r["mandatory"] == "Y"
    }
    victim = rng.choice(
        sorted(
            d["document_id"]
            for d in inp["document"]
            if d["claim_id"] == c["claim_id"] and d["doc_type"] in mandatory
        )
    )
    inp["document"] = [d for d in inp["document"] if d["document_id"] != victim]
    return _entry(
        "missing_mandatory_doc",
        "business_outcome",
        "claim",
        c["claim_id"],
        *BUSINESS["missing_mandatory_doc"],
    )


def _exceed_limit(rng, data, c) -> dict:
    s = next(s for s in data["settlement"] if s["claim_id"] == c["claim_id"])
    cov = next(i["coverage_id"] for i in data["claim_item"] if i["claim_id"] == c["claim_id"])
    limit = next(
        r["limit_amount"]
        for r in data["policy_coverage"]
        if r["policy_id"] == c["policy_id"] and r["coverage_id"] == cov
    )
    correct, wrong = s["recommended_amount"], int(limit * rng.uniform(1.05, 1.4))
    s.update(recommended_amount=wrong, approved_amount=wrong, paid_amount=wrong)
    return _entry(
        "settlement_exceeds_limit",
        "integrity_defect",
        "settlement",
        s["settlement_id"],
        "R-PAY-01",
        f"flag: settlement should be {correct} cents (R-PAY-01 payable, at most the limit {limit})",
    )


def _paid_twice(rng, data, c) -> dict:
    s = next(s for s in data["settlement"] if s["claim_id"] == c["claim_id"])
    second = dict(
        s,
        settlement_id=ids.settlement(c["claim_id"], 2),
        paid_date=min(config.AS_OF, s["paid_date"] + timedelta(days=rng.randint(1, 10))),
    )
    data["settlement"].append(second)
    return _entry(
        "paid_twice",
        "integrity_defect",
        "settlement",
        second["settlement_id"],
        "R-PAY-01",
        "flag: a claim is paid once; the second payment must be flagged",
    )


def inject(
    master: dict, pol: dict, claim_tables: dict, planted: list, scale: float
) -> tuple[dict, list]:
    rng, k = config.rng("inject"), config.inject_rows(scale)
    base = {**master, **pol, **claim_tables}
    data0 = {**base, **engine.run(base)}
    pool, paid_pool = _pools(data0, planted)
    used: set = set()
    paid_cases = {
        "settlement_exceeds_limit": _take(rng, paid_pool, k, used),
        "paid_twice": _take(rng, paid_pool, k, used),
    }
    policy = {p["policy_id"]: p for p in data0["policy"]}
    early = {p["policy_id"] for p in data0["policy"]} - {
        e["policy_id"] for e in data0["policy_event"] if e["event_type"] != "issued"
    }
    inc_of = {i["incident_id"]: i for i in data0["incident"]}
    business = {
        "missing_mandatory_doc": _take(rng, pool, k, used),
        "cancelled_before_incident": _take(
            rng,
            pool,
            k,
            used,
            lambda c: (
                c["policy_id"] in early
                and (
                    inc_of[c["incident_id"]]["incident_date"] - policy[c["policy_id"]]["start_date"]
                ).days
                >= 10
            ),
        ),
        "duplicate_incident": _take(
            rng, pool, k, used, lambda c: c["submission_date"] + timedelta(days=15) <= config.AS_OF
        ),
        "claim_before_policy_start": _take(rng, pool, k, used),
    }
    inp = copy.deepcopy(base)
    ix = {
        "policy": {p["policy_id"]: p for p in inp["policy"]},
        "incident": {i["incident_id"]: i for i in inp["incident"]},
    }
    claim_row = {c["claim_id"]: c for c in inp["claim"]}
    injected = []
    for n, c in enumerate(business["duplicate_incident"], start=1):
        injected.append(_duplicate(rng, inp, claim_row[c["claim_id"]], ix, n))
    for c in business["missing_mandatory_doc"]:
        injected.append(_drop_doc(rng, inp, claim_row[c["claim_id"]], ix))
    for c in business["cancelled_before_incident"]:
        injected.append(_cancelled(rng, inp, claim_row[c["claim_id"]], ix))
    for c in business["claim_before_policy_start"]:
        injected.append(_before_start(rng, inp, claim_row[c["claim_id"]], ix))
    data = {**inp, **engine.run(inp)}
    for c in paid_cases["settlement_exceeds_limit"]:
        injected.append(_exceed_limit(rng, data, c))
    for c in paid_cases["paid_twice"]:
        injected.append(_paid_twice(rng, data, c))
    return data, injected
