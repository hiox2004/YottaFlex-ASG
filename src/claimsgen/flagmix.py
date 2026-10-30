"""How often each fraud indicator (F1-F4) fires on the dataset, recomputed from the tables with the engine's own
`rules.fraud_flags` and its processing order. Input and engine data only: ground_truth is not read."""

from collections import Counter, defaultdict

from claimsgen import rules


def flag_counts(tables: dict) -> dict:
    """{"claims": n, "flags": {"F1": k, ...}, "combos": {"F1+F3": k, "none": k, ...}} over every claim."""
    policy = {p["policy_id"]: p for p in tables["policy"]}
    incident = {i["incident_id"]: i["incident_date"] for i in tables["incident"]}
    limits: dict = defaultdict(dict)
    for r in tables["policy_coverage"]:
        limits[r["policy_id"]][r["coverage_id"]] = r["limit_amount"]
    claimed: dict = defaultdict(lambda: defaultdict(int))
    for i in tables["claim_item"]:
        claimed[i["claim_id"]][i["coverage_id"]] += i["claimed_amount"]
    order = sorted(
        tables["claim"],
        key=lambda c: (
            c["submission_date"],
            incident[c["incident_id"]],
            c["policy_id"],
            c["claim_id"],
        ),
    )
    earlier: dict = defaultdict(list)  # customer -> submissions already processed, as in the engine
    flags, combos = Counter(), Counter()
    for c in order:
        p = policy[c["policy_id"]]
        got = rules.fraud_flags(
            c,
            incident[c["incident_id"]],
            p,
            claimed[c["claim_id"]],
            limits[c["policy_id"]],
            earlier[p["customer_id"]],
        )
        earlier[p["customer_id"]].append(c["submission_date"])
        flags.update(k for k, v in got.items() if v)
        combos["+".join(k for k, v in got.items() if v) or "none"] += 1
    return {
        "claims": len(order),
        "flags": {k: flags[k] for k in ("F1", "F2", "F3", "F4")},
        "combos": dict(sorted(combos.items())),
    }
