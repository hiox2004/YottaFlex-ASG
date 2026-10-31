"""Rule catalogue and pure rule functions (no I/O, no randomness). Every decision cites one of these IDs."""

from dataclasses import dataclass
from datetime import timedelta

from claimsgen import config

RULES = {
    "R-COV-01": "Claim is submitted on or after the policy start date",
    "R-COV-02": "Policy is in force on the incident date (start <= d <= end, no lapse/cancel on or before d)",
    "R-COV-03": "Incident date is inside the effective dates of every claimed coverage",
    "R-ELG-01": "Item type and incident type must be covered by the item's coverage; others contribute nothing",
    "R-ELG-02": "Excluded item types contribute no eligible amount",
    "R-ELG-03": "Same policy, incident date and claim type as an earlier claim is a duplicate",
    "R-DOC-01": "Mandatory documents must be received within the document window of submission",
    "R-FRD-01": "F1: submitted within 30 days after policy start",
    "R-FRD-02": "F2: at least 3 earlier claims by the customer in the prior 90 days",
    "R-FRD-03": "F3: any coverage claimed at 95% or more of its limit",
    "R-FRD-04": "F4: reported more than 60 days after the incident",
    "R-FRD-05": "Fraud score (flags / 4) at or above the threshold goes to review",
    "R-PAY-01": "Payable = per coverage min(max(0, eligible - deductible), remaining limit)",
    "R-RSV-01": "FNOL reserve at submission = per coverage min(claimed, limit), summed",
    "R-RSV-02": "Reserve revised to the payable (0 on denial) at the decisive assessment",
    "R-APR-01": "Payable above the threshold needs the approver; otherwise the process owner",
}

TRANSITIONS = {
    "": {"submitted"},
    "submitted": {"denied", "docs_pending", "under_review", "assessed"},
    "docs_pending": {"denied", "under_review", "assessed"},
    "assessed": {"approved"},
    "approved": {"paid"},
    "denied": set(),
    "under_review": set(),
    "paid": set(),
}


@dataclass(frozen=True)
class Payout:
    eligible: int
    deductible: int
    payable: int
    capped: bool
    by_coverage: dict


def in_force(policy: dict, ends: dict, day) -> bool:
    """ends maps policy_id -> earliest lapse/cancel date; the expired event does not end coverage early."""
    stop = ends.get(policy["policy_id"])
    return policy["start_date"] <= day <= policy["end_date"] and (stop is None or stop > day)


def covered(coverages: list, day) -> bool:
    return all(r["effective_start"] <= day <= r["effective_end"] for r in coverages)


def missing_docs(required: set, docs: list, submission) -> list:
    have = {
        d["doc_type"]
        for d in docs
        if d["status"] == "received"
        and (d["received_date"] - submission).days <= config.DOC_WINDOW_DAYS
    }
    return sorted(required - have)


def fraud_flags(
    claim: dict, incident_date, policy: dict, claimed_by_cov: dict, limits: dict, earlier: list
) -> dict:
    sub = claim["submission_date"]
    window = sub - timedelta(days=config.FRAUD_F2_DAYS)
    return {
        "F1": sub <= policy["start_date"] + timedelta(days=config.FRAUD_F1_DAYS),
        "F2": sum(window <= s <= sub for s in earlier) >= config.FRAUD_F2_MIN,
        "F3": any(total >= 0.95 * limits[cov] for cov, total in claimed_by_cov.items()),
        "F4": (sub - incident_date).days > config.FRAUD_F4_DAYS,
    }


def covered_items(items: list, incident_type: str, terms: dict) -> list:
    """terms maps coverage_id -> (covered incident types, covered item types); R-ELG-01 keeps covered items."""
    return [
        i
        for i in items
        if incident_type in terms[i["coverage_id"]][0]
        and i["item_type"] in terms[i["coverage_id"]][1]
    ]


def eligible_by_coverage(items: list, exclusions: dict) -> dict:
    out: dict = {}
    for i in items:
        if i["item_type"] not in exclusions[i["coverage_id"]]:
            out[i["coverage_id"]] = out.get(i["coverage_id"], 0) + i["claimed_amount"]
    return out


def fnol_reserve(items: list, pcv_by_cov: dict) -> int:
    """First reserve, set at submission before any rule has run: what is claimed, capped at each coverage limit."""
    claimed: dict = {}
    for i in items:
        claimed[i["coverage_id"]] = claimed.get(i["coverage_id"], 0) + i["claimed_amount"]
    return sum(min(a, pcv_by_cov[k]["limit_amount"]) for k, a in claimed.items())


def payable(eligible: dict, pcv_by_cov: dict, committed: dict) -> Payout:
    elig = ded = pay = 0
    capped = False
    by_cov = {}
    for cov in sorted(eligible):
        row, e = pcv_by_cov[cov], eligible[cov]
        remaining = max(0, row["limit_amount"] - committed.get((row["policy_id"], cov), 0))
        net = max(0, e - row["deductible"])
        amount = min(net, remaining)
        capped = capped or amount < net
        elig, ded, pay = elig + e, ded + min(e, row["deductible"]), pay + amount
        by_cov[cov] = amount
    return Payout(elig, ded, pay, capped, by_cov)
