"""Building blocks shared by claim scenarios: Spec/Ctx, windows, items, documents, ordinary claims."""

import math
from collections import defaultdict
from dataclasses import dataclass
from datetime import date, timedelta
from itertools import accumulate
from random import Random

from claimsgen import config
from claimsgen.masterdata import COVERAGE_PROFILE, SEVERITY, rand_date

# days from incident to submission: mostly short with a long tail (a few claims are reported months late)
LAGS = (0, 1, 2, 3, 5, 7, 10, 14, 21, 30, 45, 75, 120)
LAG_WEIGHTS = (25, 20, 15, 12, 10, 8, 6, 4, 3, 2, 1.5, 1, 0.5)
# liability is reported late more often
LIAB_LAG_WEIGHTS = (8, 8, 8, 8, 10, 10, 10, 10, 8, 7, 6, 5, 2)
DAY = timedelta(days=1)


@dataclass
class Spec:
    policy: dict
    incident_date: date
    incident_type: str
    submission_date: date
    items: list  # (coverage_id, item_type, cents)
    docs: list  # (doc_type, received_date, status)
    scenario: str = ""
    detail: str = ""
    source: "Spec | None" = None


@dataclass
class Ctx:
    policies: dict
    pcvs: dict
    names: dict
    ends: dict  # policy_id -> (event_type, date) for lapsed/cancelled
    required: dict  # product -> ((doc_type, mandatory), ...)
    ids: list
    lapsed: list
    late: list  # policies with a coverage that starts after the policy
    expired: list  # policies that simply ran to their end date
    exposure: list  # days in force before AS_OF per policy, aligned with ids (at least 1)
    cum_exposure: list  # running total of exposure, for weighted policy choice


def make_ctx(master: dict, pol: dict) -> Ctx:
    pcvs = defaultdict(list)
    for r in pol["policy_coverage"]:
        pcvs[r["policy_id"]].append(r)
    ends = {
        e["policy_id"]: (e["event_type"], e["event_date"])
        for e in pol["policy_event"]
        if e["event_type"] in ("lapsed", "cancelled")
    }
    required = defaultdict(list)
    for r in master["document_requirement"]:
        required[r["claim_type"]].append((r["doc_type"], r["mandatory"]))
    policies = {p["policy_id"]: p for p in pol["policy"]}
    pids = sorted(policies)
    exposure = []
    for i in pids:
        last = min(config.AS_OF, policies[i]["end_date"], ends.get(i, (0, config.AS_OF))[1])
        exposure.append(max(1, (last - policies[i]["start_date"]).days))
    return Ctx(
        policies=policies,
        pcvs=pcvs,
        names={c["coverage_id"]: c["name"] for c in master["coverage"]},
        ends=ends,
        required=required,
        ids=pids,
        lapsed=[i for i in pids if ends.get(i, ("",))[0] == "lapsed" and ends[i][1] < config.AS_OF],
        late=[
            i
            for i in pids
            if any(r["effective_start"] > policies[i]["start_date"] for r in pcvs[i])
        ],
        expired=[i for i in pids if i not in ends and policies[i]["end_date"] < config.AS_OF],
        exposure=exposure,
        cum_exposure=list(accumulate(exposure)),
    )


def draw_lag(rng: Random, product: str, max_lag: int | None = None) -> int:
    """Report lag in days for a policy product; max_lag keeps flag-isolated scenarios below the F4 window."""
    weights = LIAB_LAG_WEIGHTS if product == "LIAB" else LAG_WEIGHTS
    pairs = [(d, w) for d, w in zip(LAGS, weights) if max_lag is None or d <= max_lag]
    return rng.choices([d for d, _ in pairs], weights=[w for _, w in pairs])[0]


def latest_incident(ctx: Ctx, p: dict, lag: int) -> date:
    """Latest incident date that keeps the claim submittable by AS_OF and the policy in force."""
    hi = min(p["end_date"], config.AS_OF - timedelta(days=lag))
    if p["policy_id"] in ctx.ends:
        hi = min(hi, ctx.ends[p["policy_id"]][1] - DAY)
    return hi


def _item_type(rng: Random, ctx: Ctx, row: dict, allow_cosmetic: bool = True) -> str:
    types = COVERAGE_PROFILE[ctx.names[row["coverage_id"]]][1]
    main = [t for t in types if t != "cosmetic"]
    if allow_cosmetic and "cosmetic" in types and rng.random() < 0.08:
        return "cosmetic"
    return rng.choice(main)


def _items(
    rng: Random, ctx: Ctx, pcv: dict, incident: date, only_primary: bool, incident_type: str
) -> list:
    # a secondary coverage is only used when it covers this incident type (R-ELG-01)
    covered = [
        r
        for r in ctx.pcvs[pcv["policy_id"]]
        if r["effective_start"] <= incident <= r["effective_end"]
        and incident_type in COVERAGE_PROFILE[ctx.names[r["coverage_id"]]][0]
    ]
    items = []
    for _ in range(rng.choices((1, 2, 3), weights=(55, 30, 15))[0]):
        row = (
            pcv if only_primary or len(covered) < 2 or rng.random() < 0.85 else rng.choice(covered)
        )
        median_usd, sigma = SEVERITY[ctx.names[row["coverage_id"]]]
        cents = max(5000, int(rng.lognormvariate(math.log(median_usd * 100), sigma)))
        items.append([row["coverage_id"], _item_type(rng, ctx, row), cents])
    limits = {r["coverage_id"]: r["limit_amount"] for r in ctx.pcvs[pcv["policy_id"]]}
    totals = defaultdict(int)
    for cov_id, _, cents in items:
        totals[cov_id] += cents
    shrink = {}
    for cov_id, total in totals.items():  # ordinary claims stay under 90% of each coverage limit
        cap = int(0.9 * limits[cov_id])
        if total > cap:  # a random share of the cap, so totals do not pile up at 90%
            shrink[cov_id] = cap * rng.uniform(0.4, 1.0) / total
    for item in items:
        if item[0] in shrink:
            item[2] = max(5000, int(item[2] * shrink[item[0]]))
    return [tuple(i) for i in items]


def make_docs(
    rng: Random,
    ctx: Ctx,
    product: str,
    submission: date,
    omit: str = "",
    late: bool = False,
    rejected: bool = False,
) -> list:
    """The omitted type is absent, arrives late, or arrives on time but rejected (does not count)."""
    docs = []
    for doc_type, mandatory in ctx.required[product]:
        if mandatory == "N" and rng.random() < 0.5:
            continue
        if doc_type == omit and not (late or rejected):
            continue
        gap = rng.randint(10, 30) if doc_type == omit and late else rng.randint(0, 3)
        status = "rejected" if doc_type == omit and rejected else "received"
        docs.append((doc_type, min(config.AS_OF, submission + timedelta(days=gap)), status))
    return docs


def build_spec(
    rng,
    ctx,
    pcv,
    incident,
    lag,
    scenario="",
    cents=None,
    only_primary=False,
    incomplete=False,
    cosmetic=True,
):
    p = ctx.policies[pcv["policy_id"]]
    submission = incident + timedelta(days=lag)
    incident_type = rng.choice(COVERAGE_PROFILE[ctx.names[pcv["coverage_id"]]][0])  # drawn first
    if cents is None:
        items = _items(rng, ctx, pcv, incident, only_primary, incident_type)
    else:
        items = [(pcv["coverage_id"], _item_type(rng, ctx, pcv, cosmetic), cents)]
    omit, late, rejected, detail = "", False, False, ""
    if incomplete:
        omit = rng.choice([d for d, m in ctx.required[p["product"]] if m == "Y"])
        late = rng.random() < 0.5 and submission + timedelta(days=30) <= config.AS_OF
        rejected = not late and rng.random() < 0.5  # about a quarter of all omissions
        detail = "late" if late else "rejected" if rejected else "absent"
    return Spec(
        p,
        incident,
        incident_type,
        submission,
        items,
        make_docs(rng, ctx, p["product"], submission, omit, late, rejected),
        scenario,
        detail,
    )


def normal_spec(rng, ctx, scenario="", cents=None, after_start_days=0, **kw):
    """after_start_days > 0 forces submission to be more than that many days after policy start (no F1 flag)."""
    # policies are chosen by exposure (days in force), so recently started policies get fewer claims
    p = ctx.policies[rng.choices(ctx.ids, cum_weights=ctx.cum_exposure)[0]]
    # scenarios that must not trip F4 by accident (they already avoid F1) keep their lag inside its window
    max_lag = config.FRAUD_F4_DAYS if after_start_days else None
    pcv, lag = rng.choice(ctx.pcvs[p["policy_id"]]), draw_lag(rng, p["product"], max_lag)
    lo, hi = max(p["start_date"], pcv["effective_start"]), latest_incident(ctx, p, lag)
    if after_start_days:
        lo = max(lo, p["start_date"] + timedelta(days=after_start_days + 1 - lag))
    if lo > hi:
        return None
    fixed = cents(rng, pcv) if cents else None
    if cents and fixed is None:
        return None
    return build_spec(rng, ctx, pcv, rand_date(rng, lo, hi), lag, scenario, fixed, **kw)
