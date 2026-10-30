"""Building blocks shared by claim scenarios: Spec/Ctx, windows, items, documents, ordinary claims."""

import math
from collections import defaultdict
from dataclasses import dataclass
from datetime import date, timedelta
from random import Random

from claimsgen import config
from claimsgen.masterdata import COVERAGE_PROFILE, rand_date

LAGS = (0, 1, 2, 3, 5, 7, 10, 14)
LAG_WEIGHTS = (25, 20, 15, 12, 10, 8, 6, 4)
DAY = timedelta(days=1)


@dataclass
class Spec:
    policy: dict
    incident_date: date
    incident_type: str
    submission_date: date
    items: list  # (coverage_id, item_type, cents)
    docs: list  # (doc_type, received_date)
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
    )


def draw_lag(rng: Random) -> int:
    return rng.choices(LAGS, weights=LAG_WEIGHTS)[0]


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


def _items(rng: Random, ctx: Ctx, pcv: dict, incident: date, only_primary: bool) -> list:
    covered = [
        r
        for r in ctx.pcvs[pcv["policy_id"]]
        if r["effective_start"] <= incident <= r["effective_end"]
    ]
    items = []
    for _ in range(rng.choices((1, 2, 3), weights=(55, 30, 15))[0]):
        row = (
            pcv if only_primary or len(covered) < 2 or rng.random() < 0.85 else rng.choice(covered)
        )
        cents = max(5000, int(rng.lognormvariate(math.log(0.04 * row["limit_amount"]), 0.9)))
        items.append([row["coverage_id"], _item_type(rng, ctx, row), cents])
    limits = {r["coverage_id"]: r["limit_amount"] for r in ctx.pcvs[pcv["policy_id"]]}
    totals = defaultdict(int)
    for cov_id, _, cents in items:
        totals[cov_id] += cents
    for item in items:  # ordinary claims stay under 90% of each coverage limit
        cap = int(0.9 * limits[item[0]])
        if totals[item[0]] > cap:
            item[2] = max(5000, item[2] * cap // totals[item[0]])
    return [tuple(i) for i in items]


def make_docs(
    rng: Random, ctx: Ctx, product: str, submission: date, omit: str = "", late: bool = False
) -> list:
    docs = []
    for doc_type, mandatory in ctx.required[product]:
        if mandatory == "N" and rng.random() < 0.5:
            continue
        if doc_type == omit and not late:
            continue
        gap = rng.randint(10, 30) if doc_type == omit else rng.randint(0, 3)
        docs.append((doc_type, min(config.AS_OF, submission + timedelta(days=gap))))
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
    if cents is None:
        items = _items(rng, ctx, pcv, incident, only_primary)
    else:
        items = [(pcv["coverage_id"], _item_type(rng, ctx, pcv, cosmetic), cents)]
    omit, late, detail = "", False, ""
    if incomplete:
        omit = rng.choice([d for d, m in ctx.required[p["product"]] if m == "Y"])
        late = rng.random() < 0.5 and submission + timedelta(days=30) <= config.AS_OF
        detail = "late" if late else "absent"
    incident_type = rng.choice(COVERAGE_PROFILE[ctx.names[pcv["coverage_id"]]][0])
    return Spec(
        p,
        incident,
        incident_type,
        submission,
        items,
        make_docs(rng, ctx, p["product"], submission, omit, late),
        scenario,
        detail,
    )


def normal_spec(rng, ctx, scenario="", cents=None, **kw):
    p = ctx.policies[rng.choice(ctx.ids)]
    pcv, lag = rng.choice(ctx.pcvs[p["policy_id"]]), draw_lag(rng)
    lo, hi = max(p["start_date"], pcv["effective_start"]), latest_incident(ctx, p, lag)
    if lo > hi:
        return None
    fixed = cents(rng, pcv) if cents else None
    if cents and fixed is None:
        return None
    return build_spec(rng, ctx, pcv, rand_date(rng, lo, hi), lag, scenario, fixed, **kw)
