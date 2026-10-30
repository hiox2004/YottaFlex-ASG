"""Step 2 of the pipeline: policy, policy_event (append-only lifecycle) and policy_coverage (bridge).

Status mix is chosen first (in_force 75 / expired 13 / lapsed 8 / cancelled 4), then dates are drawn to be
consistent with it. Policy status is never stored; it derives from policy_event + dates (see rules step).
"""

from datetime import date, timedelta
from random import Random

from claimsgen import config, ids
from claimsgen.masterdata import rand_date

STATUS_WEIGHTS = (("in_force", 75), ("expired", 13), ("lapsed", 8), ("cancelled", 4))
PRODUCT_WEIGHTS = (("AUTO", 35), ("HOME", 25), ("HLTH", 20), ("TRVL", 10), ("LIAB", 10))
PREMIUM_USD = {
    "AUTO": (900, 2400),
    "HOME": (700, 2000),
    "HLTH": (1500, 5000),
    "TRVL": (40, 300),
    "LIAB": (300, 1200),
}
FLOOR = date(2024, 1, 1)
LIMIT_FACTORS = (0.5, 1, 1.5, 2)


def _pick(rng: Random, pairs: tuple[tuple[str, int], ...]) -> str:
    return rng.choices([p[0] for p in pairs], weights=[p[1] for p in pairs])[0]


def _dates(rng: Random, status: str, term: int) -> tuple[date, date | None]:
    """Return (start, event_date); event_date is the lapse/cancel date for those statuses."""
    as_of = config.AS_OF
    if status == "in_force":
        return as_of - timedelta(days=rng.randint(0, term - 1)), None
    if status == "expired":
        return rand_date(rng, FLOOR, as_of - timedelta(days=term)), None
    start = rand_date(rng, FLOOR, as_of - timedelta(days=60))
    hi = min(term - 2, (as_of - start).days)
    lo = min(hi, max(7, term // 6))
    return start, start + timedelta(days=rng.randint(lo, hi))


def _specs(n: int, customer_ids: list[str]) -> list[dict]:
    rng = config.rng("policies")
    specs = []
    for i in range(n):
        product = _pick(rng, PRODUCT_WEIGHTS)
        status = _pick(rng, STATUS_WEIGHTS)
        term = rng.randint(30, 90) if product == "TRVL" else 365
        start, event_date = _dates(rng, status, term)
        # the first len(customers) policies give each customer one; the rest are random repeats
        customer_id = customer_ids[i] if i < len(customer_ids) else rng.choice(customer_ids)
        low, high = PREMIUM_USD[product]
        specs.append(
            {
                "customer_id": customer_id,
                "product": product,
                "status": status,
                "start_date": start,
                "end_date": start + timedelta(days=term - 1),
                "event_date": event_date,
                "premium": rng.randint(low, high) * 100,
            }
        )
    return sorted(specs, key=lambda s: (s["start_date"], s["product"], s["customer_id"]))


def _coverages(rng: Random, policy: dict, catalogue: list[dict], pcv_rows: list[dict]) -> None:
    options = [c for c in catalogue if c["product"] == policy["product"]]
    chosen = sorted(
        rng.sample(options, min(len(options), rng.randint(2, 3))), key=lambda c: c["coverage_id"]
    )
    term = (policy["end_date"] - policy["start_date"]).days + 1
    for n, cov in enumerate(chosen, start=1):
        limit = round(cov["default_limit"] * rng.choice(LIMIT_FACTORS) / 10000) * 10000
        deductible = min(
            cov["default_deductible"] * rng.choice((1, 2)), limit // 4 // 10000 * 10000
        )
        late = (
            rng.random() < 0.10
        )  # coverage that starts after the policy does -> real "outside coverage" cases
        offset = rng.randint(7, max(7, term // 4)) if late else 0
        pcv_rows.append(
            {
                "policy_coverage_id": ids.pcv(policy["policy_id"], n),
                "policy_id": policy["policy_id"],
                "coverage_id": cov["coverage_id"],
                "limit_amount": limit,
                "deductible": deductible,
                "effective_start": policy["start_date"] + timedelta(days=offset),
                "effective_end": policy["end_date"],
            }
        )


def generate(master: dict[str, list[dict]], scale: float) -> dict[str, list[dict]]:
    c = config.counts(scale)
    customer_ids = [r["customer_id"] for r in master["customer"]]
    rng = config.rng("policy_coverage")
    policies, events, pcvs = [], [], []
    for number, s in enumerate(_specs(c.policies, customer_ids), start=1):
        policy = {
            "policy_id": ids.pol(s["product"], number),
            "customer_id": s["customer_id"],
            "product": s["product"],
            "start_date": s["start_date"],
            "end_date": s["end_date"],
            "premium": s["premium"],
        }
        policies.append(policy)
        lifecycle = [("issued", s["start_date"])]
        if s["status"] == "expired":
            lifecycle.append(("expired", s["end_date"]))
        elif s["event_date"] is not None:
            lifecycle.append((s["status"], s["event_date"]))
        for n, (event_type, event_date) in enumerate(lifecycle, start=1):
            events.append(
                {
                    "event_id": ids.pev(policy["policy_id"], n),
                    "policy_id": policy["policy_id"],
                    "event_type": event_type,
                    "event_date": event_date,
                }
            )
        _coverages(rng, policy, master["coverage"], pcvs)
    return {"policy": policies, "policy_event": events, "policy_coverage": pcvs}
