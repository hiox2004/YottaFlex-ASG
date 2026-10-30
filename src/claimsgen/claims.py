"""Step 3 of the pipeline: incident, claim, claim_item, document, plus the planted baseline scenarios.

Scenarios (lapsed policy, outside coverage, incomplete evidence, over-limit, fraud indicators, organic duplicate,
boundary cases) are chosen here as INPUT conditions only; decisions come from the rules engine later.
The planted list is returned separately (never stored in input tables) so ground_truth can be built from it.
IDs are assigned by sorting on (submission_date, incident_date, policy_id); the injection step renumbers.
"""

from datetime import timedelta
from random import Random

from claimsgen import config, ids
from claimsgen.claim_build import (
    DAY,
    Ctx,
    Spec,
    build_spec,
    draw_lag,
    latest_incident,
    make_ctx,
    make_docs,
    normal_spec,
)
from claimsgen.masterdata import rand_date


def _lapsed(rng, ctx):
    p = ctx.policies[rng.choice(ctx.lapsed)]
    pcv, lag = rng.choice(ctx.pcvs[p["policy_id"]]), draw_lag(rng, p["product"])
    lo, hi = (
        ctx.ends[p["policy_id"]][1] + DAY,
        min(p["end_date"], config.AS_OF - timedelta(days=lag)),
    )
    return (
        build_spec(rng, ctx, pcv, rand_date(rng, lo, hi), lag, "lapsed_policy")
        if lo <= hi
        else None
    )


def _outside(rng, ctx):
    p = ctx.policies[rng.choice(ctx.late)]
    pcv = rng.choice(
        [r for r in ctx.pcvs[p["policy_id"]] if r["effective_start"] > p["start_date"]]
    )
    lag = draw_lag(rng, p["product"])
    hi = min(latest_incident(ctx, p, lag), pcv["effective_start"] - DAY)
    if p["start_date"] > hi:
        return None
    return build_spec(
        rng,
        ctx,
        pcv,
        rand_date(rng, p["start_date"], hi),
        lag,
        "outside_coverage_period",
        only_primary=True,
    )


def _fraud(rng, ctx):
    p = ctx.policies[rng.choice(ctx.ids)]
    pcv, lag = rng.choice(ctx.pcvs[p["policy_id"]]), rng.randint(0, 3)
    lo, hi = (
        max(p["start_date"], pcv["effective_start"]),
        min(latest_incident(ctx, p, lag), p["start_date"] + 20 * DAY),
    )
    if lo > hi:
        return None
    cents = int(pcv["limit_amount"] * rng.uniform(0.95, 1.0))
    return build_spec(rng, ctx, pcv, rand_date(rng, lo, hi), lag, "suspected_fraud", cents)


def _on_start(rng, ctx):
    p = ctx.policies[rng.choice(ctx.ids)]
    zero = [r for r in ctx.pcvs[p["policy_id"]] if r["effective_start"] == p["start_date"]]
    lag = draw_lag(rng, p["product"])
    if not zero or p["start_date"] > latest_incident(ctx, p, lag):
        return None
    return build_spec(
        rng, ctx, rng.choice(zero), p["start_date"], lag, "boundary_incident_on_start"
    )


def _on_end(rng, ctx):
    p = ctx.policies[rng.choice(ctx.expired)]
    lag = draw_lag(rng, p["product"])
    if p["end_date"] > latest_incident(ctx, p, lag):
        return None
    return build_spec(
        rng,
        ctx,
        rng.choice(ctx.pcvs[p["policy_id"]]),
        p["end_date"],
        lag,
        "boundary_incident_on_end",
    )


def _at_deductible(rng, pcv):
    return pcv["deductible"] if pcv["deductible"] > 0 else None


BUILDERS = {
    "normal": normal_spec,
    "lapsed_policy": _lapsed,
    "outside_coverage_period": _outside,
    "incomplete_evidence": lambda rng, ctx: normal_spec(
        rng, ctx, "incomplete_evidence", incomplete=True
    ),
    "claim_over_limit": lambda rng, ctx: normal_spec(
        rng,
        ctx,
        "claim_over_limit",
        lambda r, c: int(c["limit_amount"] * r.uniform(1.1, 1.6)) + c["deductible"],
        after_start_days=config.FRAUD_F1_DAYS,
        cosmetic=False,
    ),
    "suspected_fraud": _fraud,
    "boundary_incident_on_start": _on_start,
    "boundary_incident_on_end": _on_end,
    "boundary_amount_at_limit": lambda rng, ctx: normal_spec(
        rng,
        ctx,
        "boundary_amount_at_limit",
        lambda r, c: c["limit_amount"],
        after_start_days=config.FRAUD_F1_DAYS,
        cosmetic=False,
    ),
    "boundary_amount_at_deductible": lambda rng, ctx: normal_spec(
        rng, ctx, "boundary_amount_at_deductible", _at_deductible, cosmetic=False
    ),
}


def _draw(rng: Random, ctx: Ctx, scenario: str, seen: set) -> Spec:
    """Draw a spec whose (policy, incident date) is new, so no unlabelled duplicate can appear."""
    for _ in range(2000):
        spec = BUILDERS[scenario](rng, ctx)
        if spec and (key := (spec.policy["policy_id"], spec.incident_date)) not in seen:
            seen.add(key)
            return spec
    raise RuntimeError(f"cannot build scenario {scenario}")


def _duplicate(rng: Random, ctx: Ctx, normals: list, used: set) -> Spec:
    """A re-submission of a normal claim; each source is copied at most once, so duplicates always come in pairs."""
    for _ in range(2000):
        src = rng.choice(normals)
        if id(src) in used:
            continue
        submission = src.submission_date + timedelta(days=rng.randint(1, 20))
        if submission <= config.AS_OF:
            docs = make_docs(rng, ctx, src.policy["product"], submission)
            used.add(id(src))
            return Spec(
                src.policy,
                src.incident_date,
                src.incident_type,
                submission,
                list(src.items),
                docs,
                "duplicate_incident",
                source=src,
            )
    raise RuntimeError("cannot build duplicate")


def _assemble(specs: list) -> tuple[dict, list]:
    order = sorted(
        range(len(specs)),
        key=lambda i: (
            specs[i].submission_date,
            specs[i].incident_date,
            specs[i].policy["policy_id"],
            i,
        ),
    )
    tables = {"incident": [], "claim": [], "claim_item": [], "document": []}
    claim_of, planted = {}, []
    for n, i in enumerate(order, start=1):
        s, claim_id = specs[i], ids.clm(n)
        claim_of[id(s)] = claim_id
        tables["incident"].append(
            {
                "incident_id": ids.inc(n),
                "policy_id": s.policy["policy_id"],
                "incident_date": s.incident_date,
                "incident_type": s.incident_type,
            }
        )
        tables["claim"].append(
            {
                "claim_id": claim_id,
                "policy_id": s.policy["policy_id"],
                "incident_id": ids.inc(n),
                "claim_type": s.policy["product"],
                "submission_date": s.submission_date,
                "claimed_amount": sum(c for _, _, c in s.items),
            }
        )
        for k, (cov_id, item_type, cents) in enumerate(s.items, start=1):
            tables["claim_item"].append(
                {
                    "item_id": ids.itm(claim_id, k),
                    "claim_id": claim_id,
                    "coverage_id": cov_id,
                    "item_type": item_type,
                    "claimed_amount": cents,
                }
            )
        for k, (doc_type, received) in enumerate(s.docs, start=1):
            tables["document"].append(
                {
                    "document_id": ids.doc(claim_id, k),
                    "claim_id": claim_id,
                    "doc_type": doc_type,
                    "received_date": received,
                    "status": "received",
                }
            )
    for i in order:
        s = specs[i]
        if s.scenario:
            detail = claim_of[id(s.source)] if s.source else s.detail
            planted.append({"claim_id": claim_of[id(s)], "scenario": s.scenario, "detail": detail})
    return tables, planted


def generate(master: dict, pol: dict, scale: float) -> tuple[dict[str, list[dict]], list[dict]]:
    n = config.counts(scale).claims - config.inject_rows(scale)
    counts = config.scenario_counts(n)
    ctx, rng = make_ctx(master, pol), config.rng("claims")
    seen: set = set()
    copied: set = set()
    specs = [_draw(rng, ctx, "normal", seen) for _ in range(n - sum(counts.values()))]
    normals = list(specs)
    for scenario, k in counts.items():
        for _ in range(k):
            specs.append(
                _duplicate(rng, ctx, normals, copied)
                if scenario == "duplicate_incident"
                else _draw(rng, ctx, scenario, seen)
            )
    return _assemble(specs)
