"""The copy-paste prompt only offers ids that exist, and a claim written from it validates."""

import json

import pytest

from claimsgen import claim_prompt, generate, intake


@pytest.fixture(scope="module")
def tables():
    return generate.build_dataset(0.05)[0]


def test_every_listed_policy_and_coverage_exists_and_belongs(tables):
    text = claim_prompt.build(tables)
    policies = {p["policy_id"] for p in tables["policy"]}
    listed = [w.strip("(),;") for w in text.split() if w.startswith("POL-")]
    assert listed and set(listed) <= policies
    for pid in listed:
        for cov in intake.policy_coverages(tables, pid):
            assert cov in text


def test_one_policy_per_product_and_scenario_slot(tables):
    text = claim_prompt.build(tables, scenario="my case")
    assert {p for p in ("AUTO", "HOME", "HLTH", "TRVL", "LIAB") if f"({p})" in text} == {
        "AUTO",
        "HOME",
        "HLTH",
        "TRVL",
        "LIAB",
    }
    assert text.rstrip().endswith("my case")


def test_a_claim_built_from_the_first_listed_policy_validates(tables):
    pid = min(p["policy_id"] for p in tables["policy"] if p["product"] == "AUTO")
    cov = intake.policy_coverages(tables, pid)[0]
    claim = {
        "policy_id": pid,
        "incident_date": "2026-09-01",
        "incident_type": intake.incident_types(tables, "AUTO")[0],
        "submission_date": "2026-09-02",
        "items": [
            {
                "coverage_id": cov,
                "item_type": intake.coverage_item_types(tables, cov)[0],
                "amount": 500.0,
            }
        ],
    }
    draft, errors = intake.parse_and_validate(json.dumps(claim), tables)
    assert draft is not None and errors == []
