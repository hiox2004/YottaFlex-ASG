"""Threshold sensitivity: re-run the engine while sweeping the approver threshold and the fraud-score cutoff.

Deterministic (the engine is seeded, no clock). Thresholds are passed to engine.run as arguments; config is never mutated.
ground_truth is read only to build the suspected_fraud truth set that precision and recall are scored against.
"""

from claimsgen import config, engine, scoring

APPROVER_VALUES = [1_000_000, 2_500_000, 5_000_000, 10_000_000]
FRAUD_VALUES = [0.25, 0.5, 0.75, 1.0]
OUTPUT_TABLES = (
    "claim_adjuster_assignment",
    "assessment",
    "reserve",
    "settlement",
    "claim_status_history",
)


def _rerun(tables: dict, **kwargs) -> dict:
    inputs = {k: v for k, v in tables.items() if k not in OUTPUT_TABLES}
    return {**inputs, **engine.run(inputs, **kwargs)}


def _row(value, current: bool, rerun: dict, truth: set | None, threshold: int) -> dict:
    claimed = {c["claim_id"]: c["claimed_amount"] for c in rerun["claim"]}
    fraud = scoring.predictions(rerun, [])["suspected_fraud"]
    routed = [
        s["recommended_amount"] for s in rerun["settlement"] if s["recommended_amount"] > threshold
    ]
    row = {
        "value": value,
        "current": current,
        "fraud_referred": len(fraud),
        "flagged_amount_cents": sum(claimed[c] for c in fraud),
        "approver_settlements": len(routed),
        "approver_amount_cents": sum(routed),
        "precision": None,
        "recall": None,
    }
    if truth is not None:
        tp = len(fraud & truth)
        row["precision"] = round(tp / len(fraud), 4) if fraud else None
        row["recall"] = round(tp / len(truth), 4) if truth else None
    return row


def sweep(tables: dict, ground_truth: list) -> dict:
    """{"current": {...}, "approver": [row...], "fraud": [row...]}; rows carry the keys built in `_row`."""
    truth = {r["entity_id"] for r in ground_truth if r["label"] == "suspected_fraud"}
    now = {
        "approver_threshold_cents": config.APPROVER_THRESHOLD_CENTS,
        "fraud_threshold": config.FRAUD_THRESHOLD,
    }
    approver, fraud = [], []
    for v in APPROVER_VALUES:
        rerun = _rerun(tables, approver_threshold_cents=v)
        # the approver threshold does not change fraud decisions, so no precision/recall for this sweep
        approver.append(_row(v, v == now["approver_threshold_cents"], rerun, None, v))
    for v in FRAUD_VALUES:
        rerun = _rerun(tables, fraud_threshold=v)
        fraud.append(
            _row(v, v == now["fraud_threshold"], rerun, truth, now["approver_threshold_cents"])
        )
    return {"current": now, "approver": approver, "fraud": fraud}


def _usd(cents: int) -> str:
    return f"{cents / 100:,.2f}"


def _pr(x) -> str:
    return "n/a" if x is None else f"{x:.2f}"


def to_markdown_section(result: dict) -> list[str]:
    cur = result["current"]

    def mark(r):
        return " (current)" if r["current"] else ""

    return [
        "## Threshold sensitivity",
        "",
        (
            "The engine is re-run with one threshold changed at a time; the current setting is marked. "
            f"Current: approver threshold {_usd(cur['approver_threshold_cents'])} USD, fraud cutoff {cur['fraud_threshold']}."
        ),
        "",
        "### Approver threshold (settlements above it need the approver role)",
        "",
        (
            "Counts every recommended settlement above the threshold on a clean re-run, including recent ones not yet approved "
            "and without the planted amount defects, so the current row can differ slightly from the approver workload table."
        ),
        "",
        "| Threshold (USD) | Recommended settlements above it | Amount (USD) |",
        "|---|---|---|",
        *[
            f"| {_usd(r['value'])}{mark(r)} | {r['approver_settlements']} | {_usd(r['approver_amount_cents'])} |"
            for r in result["approver"]
        ],
        "",
        "### Fraud-score cutoff (score = flags / 4; at or above it the claim goes to review)",
        "",
        "| Cutoff | Fraud-referred claims | Claimed amount flagged (USD) | Precision | Recall |",
        "|---|---|---|---|---|",
        *[
            f"| {r['value']}{mark(r)} | {r['fraud_referred']} | {_usd(r['flagged_amount_cents'])} | {_pr(r['precision'])} | {_pr(r['recall'])} |"
            for r in result["fraud"]
        ],
        "",
    ]
