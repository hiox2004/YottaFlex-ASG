"""Realism bounds on the full-scale dataset (docs/DESIGN.md "Realism"). Each bound is a plausibility range from public
benchmarks, not a fitted target; the dataset is built once per module (about 5 s)."""

from collections import defaultdict
from statistics import mean, median

import pytest

from claimsgen import metrics
from claimsgen.generate import build_dataset


@pytest.fixture(scope="module")
def full():
    tables, _ = build_dataset(1.0)
    return tables


def _claimed_by_type(full):
    out = defaultdict(list)
    for c in full["claim"]:
        out[c["claim_type"]].append(c["claimed_amount"] / 100)
    return out


MEDIAN_RANGES_USD = {
    "AUTO": (2_000, 6_000),
    "HOME": (4_000, 15_000),
    "LIAB": (5_000, 20_000),
    "HLTH": (1_000, 6_000),
    "TRVL": (400, 2_500),
}


@pytest.mark.parametrize("claim_type", sorted(MEDIAN_RANGES_USD))
def test_claimed_amount_median_is_in_a_plausible_range(full, claim_type):
    values = _claimed_by_type(full)[claim_type]
    lo, hi = MEDIAN_RANGES_USD[claim_type]
    assert lo <= median(values) <= hi
    assert mean(values) > median(values)  # right-skewed


def test_within_deductible_denials_are_a_small_share(full):
    final = {}
    for a in full["assessment"]:
        final[a["claim_id"]] = a
    share = sum(a["reason_code"] == "within_deductible" for a in final.values()) / len(
        full["claim"]
    )
    assert share <= 0.07


def test_approver_share_of_approved_settlements_is_8_to_15_percent(full):
    assert 0.08 <= metrics.operational(full)["approver_share"] <= 0.15


def test_claim_coverage_totals_do_not_pile_up_below_the_cap(full):
    limits = {
        (r["policy_id"], r["coverage_id"]): r["limit_amount"] for r in full["policy_coverage"]
    }
    policy = {c["claim_id"]: c["policy_id"] for c in full["claim"]}
    totals: dict = defaultdict(int)
    for i in full["claim_item"]:
        totals[(i["claim_id"], i["coverage_id"])] += i["claimed_amount"]
    near_cap = sum(
        0.85 <= v / limits[(policy[cid], cov)] <= 0.90 for (cid, cov), v in totals.items()
    )
    assert near_cap / len(totals) <= 0.03
