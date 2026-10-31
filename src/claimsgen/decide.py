"""The decision step: given one claim and the indexed world, run the rules in order and return a Decision.

`w` is the engine.World (duck-typed to avoid a cycle). Pure with respect to it: reads, never writes.
The first failing rule ends the path. Split out of engine.py, which owns processing order, dates, adjusters and the append-only output rows.
"""

from collections import defaultdict
from dataclasses import dataclass

from claimsgen import rules


@dataclass
class Decision:
    decision: str
    rule_id: str
    reason: str
    eligible: int = 0
    deductible: int = 0
    payable: int = 0
    score: float = 0.0
    payout: object = None
    missing: str = ""  # pipe list of the document types requested (pend_docs only)


def evaluate(w, c: dict, duplicate: bool, resumed: bool) -> Decision:
    inc, p = w.incident[c["incident_id"]], w.policy[c["policy_id"]]
    items, day = w.items[c["claim_id"]], inc["incident_date"]
    claimed: dict = defaultdict(int)
    for i in items:
        claimed[i["coverage_id"]] += i["claimed_amount"]
    pcv = w.pcv[p["policy_id"]]
    flags = rules.fraud_flags(
        c,
        day,
        p,
        claimed,
        {k: r["limit_amount"] for k, r in pcv.items()},
        w.customer_subs[p["customer_id"]],
    )
    score = sum(flags.values()) / 4

    def out(decision, rule, reason, payout=None, scored=True, missing=""):
        e, d, a = (payout.eligible, payout.deductible, payout.payable) if payout else (0, 0, 0)
        return Decision(decision, rule, reason, e, d, a, score if scored else 0.0, payout, missing)

    if not resumed:
        if c["submission_date"] < p["start_date"]:
            return out("deny", "R-COV-01", "before_policy_start", scored=False)
        if not rules.in_force(p, w.ends, day):
            return out("deny", "R-COV-02", "policy_not_in_force", scored=False)
        if not rules.covered([pcv[k] for k in claimed], day):
            return out("deny", "R-COV-03", "outside_coverage_period", scored=False)
        if duplicate:
            return out("refer_review", "R-ELG-03", "duplicate_claim", scored=False)
        missing = rules.missing_docs(
            w.required[c["claim_type"]], w.docs[c["claim_id"]], c["submission_date"]
        )
        if missing:
            return out(
                "pend_docs", "R-DOC-01", "missing_document", scored=False, missing="|".join(missing)
            )
    if score >= w.fraud_threshold:
        return out("refer_review", "R-FRD-05", "suspected_fraud")
    covered = rules.covered_items(items, inc["incident_type"], w.terms)
    if not covered:
        return out("deny", "R-ELG-01", "not_covered")
    eligible = rules.eligible_by_coverage(covered, w.exclusions)
    if not eligible:
        return out("deny", "R-ELG-02", "item_excluded")
    payout = rules.payable(eligible, pcv, w.committed)
    if payout.payable == 0:
        return out(
            "deny", "R-PAY-01", "limit_reached" if payout.capped else "within_deductible", payout
        )
    return out("approve", "R-PAY-01", "limit_reached" if payout.capped else "eligible", payout)
