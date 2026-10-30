"""Operational metrics for the claims workflow, computed from the dataset tables (no ground_truth involved), and the
markdown report that combines them with the precision/recall scoring."""

from collections import Counter, defaultdict
from statistics import mean, median

from claimsgen import config, flagmix, scoring, sensitivity


def usd(cents: int) -> str:
    return f"{cents / 100:,.2f}"


def _pct(n: int, d: int) -> float:
    return round(n / d, 4) if d else 0.0


def _p90(values: list) -> float:
    ordered = sorted(values)
    return float(ordered[int(0.9 * (len(ordered) - 1))]) if ordered else 0.0


STRAIGHT_THROUGH_NOTE = (
    "Straight-through means the claim never pended for documents or went to review and ended assessed, approved or paid. "
    "Every decision in this dataset is automated; the actor roles show who would own each step in a real operation. "
    "It is not comparable with an industry touchless rate."
)

EFFECT = {"deny": "blocked", "approve": "reduced", "pend_docs": "held", "refer_review": "held"}


def _business(tables: dict, claims: dict, status: dict, first_settlement: dict) -> dict:
    """IMP-007 metrics from each claim's FINAL assessment and the first settlement (dataset tables only)."""
    final, reviewed = {}, set()
    for a in tables["assessment"]:
        final[a["claim_id"]] = a
        if a["decision"] in ("pend_docs", "refer_review"):
            reviewed.add(a["claim_id"])
    by_rule: dict = {}
    for cid, a in final.items():
        amount = claims[cid]["claimed_amount"]
        if a["decision"] == "approve":
            amount -= a["payable_amount"]
        cell = by_rule.setdefault(
            f"{a['rule_id']}/{EFFECT[a['decision']]}",
            {"effect": EFFECT[a["decision"]], "claims": 0, "amount_cents": 0},
        )
        cell["claims"] += 1
        cell["amount_cents"] += amount
    straight = sum(
        1
        for cid in final
        if cid not in reviewed and status[cid] in ("assessed", "approved", "paid")
    )
    workload: dict = {}
    for s in first_settlement.values():
        if s["approver_role"]:
            w = workload.setdefault(s["approver_role"], {"settlements": 0, "amount_cents": 0})
            w["settlements"] += 1
            w["amount_cents"] += s["approved_amount"]
    history: dict = {}
    for e in tables["claim_status_history"]:
        history[e["claim_id"]] = e["event_date"]
    ages = [
        (config.AS_OF - history[c]).days for c, s in sorted(status.items()) if s == "docs_pending"
    ]
    cycle: dict = defaultdict(list)
    for cid, s in first_settlement.items():
        if s["paid_date"]:
            cycle[claims[cid]["claim_type"]].append(
                (s["paid_date"] - claims[cid]["submission_date"]).days
            )
    return {
        "by_rule": dict(sorted(by_rule.items())),
        "straight_through": {
            "assessed": len(final),
            "straight_through": straight,
            "reviewed": len(final) - straight,
            "human_step": len(reviewed),
            "straight_through_rate": _pct(straight, len(final)),
        },
        "approver_share": _pct(
            workload.get("approver", {}).get("settlements", 0),
            sum(w["settlements"] for w in workload.values()),
        ),
        "approver_workload": dict(sorted(workload.items())),
        "docs_pending_aging": {
            "count": len(ages),
            "mean_days": round(mean(ages), 2) if ages else 0.0,
            "median_days": float(median(ages)) if ages else 0.0,
            "p90_days": _p90(ages),
            "max_days": max(ages, default=0),
            "older_than_14_days": sum(a > 14 for a in ages),
            "older_than_30_days": sum(a > 30 for a in ages),
            "older_than_90_days": sum(a > 90 for a in ages),
        },
        "cycle_by_claim_type": {
            t: {"paid_claims": len(v), "median_days": float(median(v)), "p90_days": _p90(v)}
            for t, v in sorted(cycle.items())
        },
    }


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
    business = _business(tables, claims, status, first_settlement)
    return {
        **business,
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


def _business_markdown(op: dict) -> list[str]:
    t, g = op["straight_through"], op["docs_pending_aging"]
    return [
        "## Money effect by rule (final assessment, USD)",
        "",
        "| Rule / effect | Claims | Amount |",
        "|---|---|---|",
        *[f"| {k} | {v['claims']} | {usd(v['amount_cents'])} |" for k, v in op["by_rule"].items()],
        "",
        "## Straight-through (no exception) rate",
        "",
        STRAIGHT_THROUGH_NOTE,
        "",
        f"- Assessed claims: {t['assessed']} | straight-through: {t['straight_through']} ({t['straight_through_rate']:.1%}) | other: {t['reviewed']} (of which pended or referred: {t['human_step']})",
        "",
        "## Approver workload",
        "",
        "| Role | Settlements | Amount |",
        "|---|---|---|",
        *[
            f"| {k} | {v['settlements']} | {usd(v['amount_cents'])} |"
            for k, v in op["approver_workload"].items()
        ],
        "",
        f"- Share of approved settlements that needed the approver: {op['approver_share']:.1%}",
        "",
        "## Documents pending: aging at the as-of date",
        "",
        f"- Claims: {g['count']} | mean {g['mean_days']} days, median {g['median_days']}, p90 {g['p90_days']}, max {g['max_days']} | older than 14 days: {g['older_than_14_days']}, 30 days: {g['older_than_30_days']}, 90 days: {g['older_than_90_days']}",
        "- There is no document-chase SLA or closure: a claim stays in `docs_pending` unless the documents arrive.",
        "",
        "## Cycle time by claim type (submission to paid, days)",
        "",
        "| Type | Paid claims | Median | p90 |",
        "|---|---|---|---|",
        *[
            f"| {k} | {v['paid_claims']} | {v['median_days']} | {v['p90_days']} |"
            for k, v in op["cycle_by_claim_type"].items()
        ],
        "",
    ]


def _flag_line(tables: dict) -> str:
    mix = flagmix.flag_counts(tables)
    n, f = mix["claims"], mix["flags"]
    shares = ", ".join(f"{k} {v} ({v / n:.1%})" for k, v in f.items())
    combos = ", ".join(f"{k} {v}" for k, v in mix["combos"].items())
    return f"Fraud flag counts over {n} claims: {shares}. Flag combinations: {combos}."


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
        *_business_markdown(op),
        *sensitivity.to_markdown_section(sensitivity.sweep(tables, ground_truth)),
        "## Precision and recall vs ground_truth",
        "",
        "Predicted labels come from engine output, input data and validator failures only. Unassessed (very recent) claims count as misses.",
        "",
        _flag_line(tables),
        "",
        "Fraud caveat: the fraud labels are the planted indicator pattern (an early claim near the limit), so the suspected_fraud row checks rule consistency; it is not a fraud-detection accuracy.",
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
