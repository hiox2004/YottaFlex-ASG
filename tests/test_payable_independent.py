"""IMP-002: hand-computed payable fixtures and an independent replay, so the engine and validator are not checked
only against their own formula. Amounts are cents."""

import pytest

from claimsgen import generate, rules
from payable_reference import claim_payable, last_approved, replay


def _both(items, limit, deductible, committed=0, excluded=()):
    """items: [(item_type, cents)] on one coverage 'C'. Returns (rules.payable total, reference total)."""
    ours = claim_payable(
        [("C", t, c) for t, c in items], {"C": (limit, deductible, set(excluded))}, {"C": committed}
    )
    eligible = rules.eligible_by_coverage(
        [{"coverage_id": "C", "item_type": t, "claimed_amount": c} for t, c in items],
        {"C": set(excluded)},
    )
    row = {"policy_id": "P", "limit_amount": limit, "deductible": deductible}
    theirs = rules.payable(eligible, {"C": row}, {("P", "C"): committed}).payable
    return theirs, sum(ours.values())


@pytest.mark.parametrize(
    ("items", "limit", "deductible", "committed", "excluded", "expected"),
    [
        ([("repair", 300_000)], 1_000_000, 50_000, 0, (), 250_000),  # simple deductible
        ([("repair", 40_000)], 1_000_000, 50_000, 0, (), 0),  # zero floor
        ([("repair", 50_000)], 1_000_000, 50_000, 0, (), 0),  # exactly the deductible
        ([("repair", 2_000_000)], 1_000_000, 50_000, 0, (), 1_000_000),  # capped at limit
        ([("repair", 1_050_000)], 1_000_000, 50_000, 0, (), 1_000_000),  # claimed exactly at limit
        (
            [("repair", 400_000)],
            1_000_000,
            50_000,
            800_000,
            (),
            200_000,
        ),  # committed reduces remaining
        ([("repair", 400_000)], 1_000_000, 50_000, 1_000_000, (), 0),  # remaining limit zero
        (
            [("repair", 100_000), ("tow", 70_000)],
            1_000_000,
            20_000,
            0,
            ("tow",),
            80_000,
        ),  # exclusion
    ],
)
def test_hand_computed_single_coverage(items, limit, deductible, committed, excluded, expected):
    assert _both(items, limit, deductible, committed, excluded) == (expected, expected)


def test_two_coverages_are_summed_per_coverage():
    terms = {"A": (500_000, 10_000, set()), "B": (100_000, 25_000, set())}
    items = [("A", "x", 200_000), ("B", "y", 90_000), ("B", "y", 60_000)]
    committed = {"A": 0, "B": 20_000}
    # A: 200000-10000 = 190000 ; B: 150000-25000 = 125000 capped at remaining 80000 ; total 270000
    assert claim_payable(items, terms, committed) == {"A": 190_000, "B": 80_000}
    pcv = {
        "A": {"policy_id": "P", "limit_amount": 500_000, "deductible": 10_000},
        "B": {"policy_id": "P", "limit_amount": 100_000, "deductible": 25_000},
    }
    elig = {"A": 200_000, "B": 150_000}
    got = rules.payable(elig, pcv, {("P", "B"): 20_000})
    assert got.payable == 270_000 and got.by_coverage == {"A": 190_000, "B": 80_000}


@pytest.fixture(scope="module")
def full():
    tables, gt = generate.build_dataset(1.0)
    return tables, gt


def test_reference_replay_matches_engine_on_generated_data(full):
    tables, gt = full
    approved = last_approved(tables)
    assert len(approved) > 300
    ref = replay(tables, approved)
    last = {}
    for a in tables["assessment"]:
        last[a["claim_id"]] = a
    assert {c: last[c]["payable_amount"] for c in approved} == ref
    defects = {r["entity_id"] for r in gt if r["label"] == "settlement_exceeds_limit"}
    first = {}
    for s in tables["settlement"]:
        first.setdefault(s["claim_id"], s)
    defect_claims = {
        first_claim for first_claim, s in first.items() if s["settlement_id"] in defects
    }
    checked = 0
    for cid, s in first.items():
        if cid in defect_claims:
            continue
        assert s["recommended_amount"] == ref[cid], cid
        checked += 1
    assert checked > 300 and len(defect_claims) > 0
