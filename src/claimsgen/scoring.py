"""Precision and recall of the engine and validator against ground_truth.

Predicted labels are derived ONLY from engine output (assessments, history), input data (policy events) and validator
failures, never from ground_truth; ground_truth is read only to build the truth sets being scored.
Claims not yet assessed by AS_OF count as misses, which is honest for very recent claims.
"""

from collections import defaultdict

COVERAGE_RULES = ("R-COV-01", "R-COV-02", "R-COV-03")
DOC_LABELS = ("incomplete_evidence", "missing_mandatory_doc")


def _event_dates(tables: dict, event_type: str) -> dict:
    out = {}
    for e in tables["policy_event"]:
        if e["event_type"] == event_type:
            out[e["policy_id"]] = e["event_date"]
    return out


def predictions(tables: dict, checks: list) -> dict[str, set]:
    """label (or class) -> predicted entity ids. `checks` are the validator results (failures carry id and reason)."""
    last, rules = {}, defaultdict(set)
    for a in tables["assessment"]:
        last[a["claim_id"]] = a
        rules[a["claim_id"]].add(a["rule_id"])
    claim = {c["claim_id"]: c for c in tables["claim"]}
    incident = {i["incident_id"]: i["incident_date"] for i in tables["incident"]}
    cancelled, lapsed = _event_dates(tables, "cancelled"), _event_dates(tables, "lapsed")

    def denied_by(rule, ended=None):
        out = set()
        for cid, a in last.items():
            if a["decision"] == "deny" and a["rule_id"] == rule:
                c = claim[cid]
                if ended is None or (
                    c["policy_id"] in ended and ended[c["policy_id"]] <= incident[c["incident_id"]]
                ):
                    out.add(cid)
        return out

    policy = {p["policy_id"]: p for p in tables["policy"]}
    on_start = {
        cid: incident[c["incident_id"]] == policy[c["policy_id"]]["start_date"]
        for cid, c in claim.items()
    }
    on_end = {
        cid: incident[c["incident_id"]] == policy[c["policy_id"]]["end_date"]
        for cid, c in claim.items()
    }
    limit = {
        (r["policy_id"], r["coverage_id"]): r["limit_amount"] for r in tables["policy_coverage"]
    }
    at_limit = {
        i["claim_id"]
        for i in tables["claim_item"]
        if i["claimed_amount"] == limit.get((claim[i["claim_id"]]["policy_id"], i["coverage_id"]))
    }

    failures = [(i, why) for c in checks for i, why in c.failures]
    return {
        "claim_before_policy_start": denied_by("R-COV-01"),
        "cancelled_before_incident": denied_by("R-COV-02", cancelled),
        "lapsed_policy": denied_by("R-COV-02", lapsed),
        "outside_coverage_period": denied_by("R-COV-03"),
        "duplicate_incident": {c for c, r in rules.items() if "R-ELG-03" in r},
        "suspected_fraud": {c for c, r in rules.items() if "R-FRD-05" in r},
        "claim_over_limit": {c for c, a in last.items() if a["reason_code"] == "limit_reached"},
        "not_covered": denied_by("R-ELG-01"),
        "documents": {c for c, r in rules.items() if "R-DOC-01" in r},
        "settlement_exceeds_limit": {i for i, why in failures if why.startswith("recommended")},
        "paid_twice": {i for i, why in failures if why == "more than one settlement for a claim"},
        # boundary labels are scored on recall of "decided as expected", with the boundary condition read from input tables
        "boundary_incident_on_start": {
            c for c, a in last.items() if a["rule_id"] not in COVERAGE_RULES and on_start[c]
        },
        "boundary_incident_on_end": {
            c for c, a in last.items() if a["rule_id"] not in COVERAGE_RULES and on_end[c]
        },
        "boundary_amount_at_limit": {
            c for c, a in last.items() if a["decision"] == "approve" and c in at_limit
        },
        "boundary_amount_at_deductible": {
            c
            for c, a in last.items()
            if a["decision"] == "deny" and a["reason_code"] == "within_deductible"
        },
    }


def _row(name, labels, truth, predicted, precision=True):
    tp = len(truth & predicted)
    return {
        "class": name,
        "labels": ", ".join(labels),
        "truth": len(truth),
        "predicted": len(predicted) if precision else None,
        "true_positive": tp,
        "precision": tp / len(predicted) if precision and predicted else None,
        "recall": tp / len(truth) if truth else None,
    }


def score(tables: dict, ground_truth: list, checks: list) -> list[dict]:
    """Per-label precision/recall rows. The shared document class is scored as one class, then per label for recall."""
    pred = predictions(tables, checks)
    truth = defaultdict(set)
    for r in ground_truth:
        truth[r["label"]].add(r["entity_id"])
    detectors = (
        "claim_before_policy_start",
        "cancelled_before_incident",
        "lapsed_policy",
        "outside_coverage_period",
        "duplicate_incident",
        "suspected_fraud",
        "claim_over_limit",
        "not_covered",
        "settlement_exceeds_limit",
        "paid_twice",
    )
    rows = [_row(label, (label,), truth[label], pred[label]) for label in detectors]
    doc_truth = truth[DOC_LABELS[0]] | truth[DOC_LABELS[1]]
    rows.append(_row("documents (shared class)", DOC_LABELS, doc_truth, pred["documents"]))
    rows += [
        _row(f"{label} (recall only)", (label,), truth[label], pred["documents"], precision=False)
        for label in DOC_LABELS
    ]
    boundary = [label for label in pred if label.startswith("boundary_")]
    rows += [
        _row(f"{label} (decided as expected)", (label,), truth[label], pred[label], precision=False)
        for label in boundary
    ]
    return rows
