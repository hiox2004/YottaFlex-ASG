"""Operational metrics for the claims workflow, computed from the dataset tables (no ground_truth involved), and the
markdown report that combines them with the precision/recall scoring."""

from collections import Counter, defaultdict
from statistics import mean, median

from claimsgen import scoring


def usd(cents: int) -> str:
    return f"{cents / 100:,.2f}"


def _pct(n: int, d: int) -> float:
    return round(n / d, 4) if d else 0.0


def _p90(values: list) -> float:
    ordered = sorted(values)
    return float(ordered[int(0.9 * (len(ordered) - 1))]) if ordered else 0.0


def operational(tables: dict) -> dict:
    claims = {c["claim_id"]: c for c in tables["claim"]}
    status, last = {}, {}
    for e in tables["claim_status_history"]:
        status[e["claim_id"]] = e["to_status"]
    for a in tables["assessment"]:
        last[a["claim_id"]] = a
    total = len(claims)
    counts = Counter(status.values())
    groups = {
        "approved": counts["assessed"] + counts["approved"] + counts["paid"],
        "denied": counts["denied"],
        "docs_pending": counts["docs_pending"],
        "under_review": counts["under_review"],
        "not_yet_assessed": counts["submitted"],
    }
    first_settlement = {}
    for s in tables["settlement"]:
        first_settlement.setdefault(s["claim_id"], s)
    reserve = {}
    for r in tables["reserve"]:
        reserve[r["claim_id"]] = r["amount"]
    to_paid = [
        (s["paid_date"] - claims[cid]["submission_date"]).days
        for cid, s in first_settlement.items()
        if s["paid_date"]
    ]
    to_approval = [
        (s["approved_date"] - claims[cid]["submission_date"]).days
        for cid, s in first_settlement.items()
        if s["approved_date"]
    ]
    held = sum(
        claims[c]["claimed_amount"]
        for c, s in status.items()
        if s in ("docs_pending", "under_review")
    )
    mismatches = [
        cid for cid, s in first_settlement.items() if s["recommended_amount"] != reserve.get(cid)
    ]
    by_type: dict = defaultdict(Counter)
    for cid, c in claims.items():
        by_type[c["claim_type"]][status[cid]] += 1
    return {
        "claims": total,
        "status_counts": dict(counts),
        "rates": {k: _pct(v, total) for k, v in groups.items()},
        "counts": groups,
        "days_to_approval": {
            "mean": round(mean(to_approval), 2),
            "median": median(to_approval),
            "p90": _p90(to_approval),
        },
        "days_to_settlement": {
            "mean": round(mean(to_paid), 2),
            "median": median(to_paid),
            "p90": _p90(to_paid),
        },
        "amounts_cents": {
            "claimed_total": sum(c["claimed_amount"] for c in claims.values()),
            "blocked_by_denial": sum(
                claims[c]["claimed_amount"] for c, s in status.items() if s == "denied"
            ),
            "reduced_by_rules": sum(
                claims[c]["claimed_amount"] - a["payable_amount"]
                for c, a in last.items()
                if a["decision"] == "approve"
            ),
            "held_for_docs_or_review": held,
            "recommended_total": sum(s["recommended_amount"] for s in first_settlement.values()),
            "paid_total": sum(
                s["paid_amount"] for s in first_settlement.values() if s["paid_amount"]
            ),
        },
        "reserve_vs_final": {
            "settled_claims": len(first_settlement),
            "reserve_total": sum(reserve[c] for c in first_settlement if c in reserve),
            "recommended_total": sum(s["recommended_amount"] for s in first_settlement.values()),
            "mismatched_claims": len(mismatches),
        },
        "by_claim_type": {
            t: {
                "claims": sum(c.values()),
                "approval_rate": _pct(c["assessed"] + c["approved"] + c["paid"], sum(c.values())),
                "denial_rate": _pct(c["denied"], sum(c.values())),
            }
            for t, c in sorted(by_type.items())
        },
    }


def _fmt(value) -> str:
    return "n/a" if value is None else f"{value:.2f}"


def to_markdown(tables: dict, ground_truth: list, checks: list) -> str:
    op, rows = operational(tables), scoring.score(tables, ground_truth, checks)
    a, r = op["amounts_cents"], op["reserve_vs_final"]
    out = [
        "# Metrics",
        "",
        "Operational numbers come from the dataset; the scoring table compares engine and validator output with ground_truth.",
        "",
        "## Outcomes",
        "",
        "| Outcome | Claims | Share |",
        "|---|---|---|",
        *[f"| {k} | {op['counts'][k]} | {op['rates'][k]:.1%} |" for k in op["counts"]],
        "",
        f"Days from submission to approval: mean {op['days_to_approval']['mean']}, median {op['days_to_approval']['median']}, p90 {op['days_to_approval']['p90']}",
        f"Days from submission to settlement (paid): mean {op['days_to_settlement']['mean']}, median {op['days_to_settlement']['median']}, p90 {op['days_to_settlement']['p90']}",
        "",
        "## Amounts (USD)",
        "",
        f"- Claimed total: {usd(a['claimed_total'])}",
        f"- Blocked by denial: {usd(a['blocked_by_denial'])}",
        f"- Reduced by deductible, exclusions and limits on approved claims: {usd(a['reduced_by_rules'])}",
        f"- Held for documents or review: {usd(a['held_for_docs_or_review'])}",
        f"- Recommended settlements: {usd(a['recommended_total'])} | paid: {usd(a['paid_total'])}",
        "",
        "## Reserve vs final settlement",
        "",
        f"- Settled claims: {r['settled_claims']} | reserve total {usd(r['reserve_total'])} | recommended total {usd(r['recommended_total'])}",
        f"- Claims where the settlement differs from the reserve: {r['mismatched_claims']} (compare with the integrity defects in the validation summary)",
        "",
        "## By claim type",
        "",
        "| Type | Claims | Approval rate | Denial rate |",
        "|---|---|---|---|",
        *[
            f"| {t} | {v['claims']} | {v['approval_rate']:.1%} | {v['denial_rate']:.1%} |"
            for t, v in op["by_claim_type"].items()
        ],
        "",
        "## Precision and recall vs ground_truth",
        "",
        "Predicted labels come from engine output, input data and validator failures only. Unassessed (very recent) claims count as misses.",
        "",
        "| Class | Truth | Predicted | True positives | Precision | Recall |",
        "|---|---|---|---|---|---|",
        *[
            f"| {x['class']} | {x['truth']} | {'' if x['predicted'] is None else x['predicted']} | {x['true_positive']} | {_fmt(x['precision'])} | {_fmt(x['recall'])} |"
            for x in rows
        ],
        "",
    ]
    return "\n".join(out)
