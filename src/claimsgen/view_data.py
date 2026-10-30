"""Data for the minimal view: decisions table, exceptions list, per-claim detail/timeline and the metrics panel.

Pure functions over the dataset tables (no Streamlit), so everything the view shows is tested. Decisions and exceptions come from
engine output and validator failures only; ground_truth is used solely by the metrics panel's scoring table.
"""

import hashlib
from collections import Counter, defaultdict
from itertools import pairwise
from statistics import mean, median

from claimsgen import export, generate, metrics, schema, scoring, sensitivity, validate
from claimsgen.view_trace import counterfactual, rule_trace

__all__ = ["counterfactual", "rule_trace"]

EXCEPTION_TITLES = {
    "documents": "Documents pending (R-DOC-01)",
    "duplicate_incident": "Duplicate claim referred (R-ELG-03)",
    "claim_over_limit": "Over limit, paid at the cap or nothing (R-PAY-01)",
    "suspected_fraud": "Suspected fraud referred (R-FRD-05)",
    "cancelled_before_incident": "Policy cancelled before incident (R-COV-02)",
    "lapsed_policy": "Policy lapsed before incident (R-COV-02)",
    "claim_before_policy_start": "Claim before policy start (R-COV-01)",
    "outside_coverage_period": "Incident outside coverage dates (R-COV-03)",
    "paid_twice": "Paid twice (integrity defect)",
    "settlement_exceeds_limit": "Settlement above the replayed limit (integrity defect)",
}


def load(scale: float) -> tuple[dict, list, list]:
    """Build the dataset and validate it. Returns (tables, ground_truth, checks)."""
    tables, gt = generate.build_dataset(scale)
    return tables, gt, validate.run_all(tables)


def _last(rows: list, key: str = "claim_id") -> dict:
    out = {}
    for r in rows:
        out[r[key]] = r
    return out


def decisions_table(tables: dict) -> list[dict]:
    """One row per claim: final decision, rule, reason, status and the actor of the latest event."""
    assess, history = _last(tables["assessment"]), _last(tables["claim_status_history"])
    rows = []
    for c in tables["claim"]:
        a, h = assess.get(c["claim_id"]), history[c["claim_id"]]
        rows.append(
            {
                "claim_id": c["claim_id"],
                "claim_type": c["claim_type"],
                "submitted": c["submission_date"].isoformat(),
                "claimed_usd": c["claimed_amount"] / 100,
                "status": h["to_status"],
                "decision": a["decision"] if a else "not_assessed",
                "rule_id": a["rule_id"] if a else "",
                "reason_code": a["reason_code"] if a else "",
                "actor_role": h["actor_role"],
                "payable_usd": a["payable_amount"] / 100 if a else 0.0,
                "last_event": h["event_date"].isoformat(),
            }
        )
    return rows


def exceptions(tables: dict, checks: list) -> dict[str, list[dict]]:
    """Exception title -> rows, derived from engine output and validator failures (never from ground_truth)."""
    predicted = scoring.predictions(tables, checks)
    settlement_claim = {s["settlement_id"]: s["claim_id"] for s in tables["settlement"]}
    decisions = {r["claim_id"]: r for r in decisions_table(tables)}
    why = {i: w for c in checks for i, w in c.failures}
    out = {}
    for key, title in EXCEPTION_TITLES.items():
        rows = []
        for ident in sorted(predicted[key]):
            claim_id = settlement_claim.get(ident, ident)
            d = decisions[claim_id]
            rows.append(
                {
                    "entity_id": ident,
                    "claim_id": claim_id,
                    "status": d["status"],
                    "rule_id": d["rule_id"],
                    "reason_code": why.get(ident, d["reason_code"]),
                    "claimed_usd": d["claimed_usd"],
                }
            )
        out[title] = rows
    return out


def claim_detail(tables: dict, claim_id: str) -> dict:
    """Everything about one claim, including the status timeline with the reason behind each step."""
    claim = next(c for c in tables["claim"] if c["claim_id"] == claim_id)
    grouped = defaultdict(lambda: defaultdict(list))
    for name in (
        "claim_item",
        "document",
        "claim_adjuster_assignment",
        "assessment",
        "reserve",
        "settlement",
        "claim_status_history",
    ):
        for r in tables[name]:
            if r["claim_id"] == claim_id:
                grouped[name]["rows"].append(r)
    policy = next(p for p in tables["policy"] if p["policy_id"] == claim["policy_id"])
    incident = next(i for i in tables["incident"] if i["incident_id"] == claim["incident_id"])
    requested = {
        a["assessment_date"]: a["missing_doc_types"]
        for a in grouped["assessment"]["rows"]
        if a["decision"] == "pend_docs"
    }
    timeline = [
        {
            "date": e["event_date"].isoformat(),
            "from": e["from_status"] or "-",
            "to": e["to_status"],
            "actor_role": e["actor_role"],
            "rule_id": e["rule_id"],
            "reason": e["reason_code"],
            "detail": (
                "Requested: " + requested[e["event_date"]].replace("|", ", ")
                if e["to_status"] == "docs_pending" and requested.get(e["event_date"])
                else ""
            ),
        }
        for e in grouped["claim_status_history"]["rows"]
    ]
    return {
        "claim": claim,
        "policy": policy,
        "incident": incident,
        "timeline": timeline,
        **{
            name: grouped[name]["rows"]
            for name in (
                "claim_item",
                "document",
                "claim_adjuster_assignment",
                "assessment",
                "reserve",
                "settlement",
            )
        },
    }


def display(table: str, rows: list) -> list[dict]:
    """Rows of a schema table as display text: money as dollars.cents, dates ISO, None as empty."""
    fields = {f.name: f for f in schema.TABLE_BY_NAME[table].fields}
    return [
        {k: ("" if (t := export.text(fields[k], v)) is None else t) for k, v in r.items()}
        for r in rows
    ]


def metrics_panel(
    tables: dict, ground_truth: list, checks: list, sweep_result: dict | None = None
) -> dict:
    """Operational metrics, precision/recall rows and the threshold sweep (the only place ground_truth is read).

    The sweep re-runs the engine 8 times; callers that cache it pass it as `sweep_result`.
    """
    return {
        "operational": metrics.operational(tables),
        "scoring": scoring.score(tables, ground_truth, checks),
        "sensitivity": sweep_result or sensitivity.sweep(tables, ground_truth),
    }


def dataset_checksum(tables: dict) -> str:
    """SHA-256 over the canonical CSV text of the input tables in schema order (byte-stable, nothing written)."""
    h = hashlib.sha256()
    for t in export.INPUT_TABLES:
        h.update(f"{t.name}\n".encode())
        h.update(export.csv_text(t, tables[t.name]).encode("utf-8"))
    return h.hexdigest()


def rebuild_and_compare(scale: float) -> tuple[bool, str, str]:
    """Build the dataset twice from the fixed seed: (identical, checksum_1, checksum_2)."""
    first = dataset_checksum(generate.build_dataset(scale)[0])
    second = dataset_checksum(generate.build_dataset(scale)[0])
    return first == second, first, second


LAG_BINS = [
    ("0", 0, 0),
    ("1", 1, 1),
    ("2", 2, 2),
    ("3", 3, 3),
    ("4-7", 4, 7),
    ("8-14", 8, 14),
    ("15-30", 15, 30),
    ("31-60", 31, 60),
    ("61+", 61, 10**6),
]
AMOUNT_EDGES_USD = [0, 500, 1_000, 2_500, 5_000, 10_000, 25_000]


def realism(tables: dict) -> dict:
    """Plain data for the realism panel: amount histogram and stats, type mix, policy status at AS_OF, report lag."""
    claims = tables["claim"]
    amounts = sorted(c["claimed_amount"] for c in claims)
    edges = [e * 100 for e in AMOUNT_EDGES_USD] + [None]
    hist = []
    for lo, hi in pairwise(edges):
        n = sum(a >= lo and (hi is None or a < hi) for a in amounts)
        label = f"{lo // 100}+" if hi is None else f"{lo // 100}-{hi // 100}"
        hist.append({"bin_usd": label, "count": n})
    incident = {i["incident_id"]: i["incident_date"] for i in tables["incident"]}
    lags = [(c["submission_date"] - incident[c["incident_id"]]).days for c in claims]
    lag = [
        {"bin_days": label, "count": sum(lo <= d <= hi for d in lags)} for label, lo, hi in LAG_BINS
    ]
    last = {}
    for e in tables["policy_event"]:
        last[e["policy_id"]] = {"issued": "in force"}.get(e["event_type"], e["event_type"])
    n = len(amounts)
    return {
        "claimed_histogram": hist,
        "claimed_stats_usd": {
            "median": median(amounts) / 100 if n else 0.0,
            "mean": mean(amounts) / 100 if n else 0.0,
            "p90": amounts[int(0.9 * (n - 1))] / 100 if n else 0.0,
        },
        "claim_type_mix": dict(sorted(Counter(c["claim_type"] for c in claims).items())),
        "policy_status": dict(sorted(Counter(last.values()).items())),
        "lag_days": lag,
    }
