"""Build the separate ground_truth answer key from planted baseline scenarios and injected cases.

Expected decisions come from the documented rules (not copied from engine output), so the engine can be scored against them.
Rows are written with provisional ids and translated once through the finalize id map.
"""

# scenario -> (kind, rule_id, expected decision)
BASELINE = {
    "lapsed_policy": ("business_outcome", "R-COV-02", "deny: policy lapsed before the incident"),
    "outside_coverage_period": (
        "business_outcome",
        "R-COV-03",
        "deny: incident outside the coverage effective dates",
    ),
    "incomplete_evidence": (
        "business_outcome",
        "R-DOC-01",
        "pend_docs: request the missing mandatory document; no payout until it arrives",
    ),
    "claim_over_limit": (
        "business_outcome",
        "R-PAY-01",
        "approve: pay no more than the remaining coverage limit (reason limit_reached)",
    ),
    "suspected_fraud": (
        "business_outcome",
        "R-FRD-05",
        "refer_review: fraud score at or above the threshold",
    ),
    "duplicate_incident": (
        "business_outcome",
        "R-ELG-03",
        "refer_review: flag the later claim as a duplicate",
    ),
    "boundary_incident_on_start": (
        "boundary",
        "R-COV-02",
        "covered: an incident on the start date is in force",
    ),
    "boundary_incident_on_end": (
        "boundary",
        "R-COV-02",
        "covered: an incident on the end date is in force",
    ),
    "boundary_amount_at_limit": (
        "boundary",
        "R-PAY-01",
        "approve: claimed amount at the limit is paid minus the deductible",
    ),
    "boundary_amount_at_deductible": (
        "boundary",
        "R-PAY-01",
        "deny: amount equal to the deductible leaves a payable of zero",
    ),
}
EXPECTED_WORDS = ("deny", "refer_review", "pend_docs", "approve", "covered", "flag")
FIELDS = ("entity_id", "entity_type", "label", "origin", "kind", "expected_decision", "rule_id")


def build(planted: list, injected: list, idmap: dict) -> list[dict]:
    rows = []
    for p in planted:
        kind, rule, expected = BASELINE[p["scenario"]]
        rows.append(
            dict.fromkeys(FIELDS)
            | {
                "entity_id": idmap[p["claim_id"]],
                "entity_type": "claim",
                "label": p["scenario"],
                "origin": "baseline",
                "kind": kind,
                "expected_decision": expected,
                "rule_id": rule,
            }
        )
    for e in injected:
        rows.append(
            dict.fromkeys(FIELDS)
            | {
                "entity_id": idmap[e["entity_id"]],
                "entity_type": e["entity_type"],
                "label": e["label"],
                "origin": "injected",
                "kind": e["kind"],
                "expected_decision": e["expected_decision"],
                "rule_id": e["rule_id"],
            }
        )
    return sorted(rows, key=lambda r: (r["entity_id"], r["label"]))
