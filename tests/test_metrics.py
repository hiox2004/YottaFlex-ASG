import inspect

import pytest

from claimsgen import config, generate, metrics, scoring, validate


@pytest.fixture(scope="module")
def built():
    tables, gt = generate.build_dataset(1.0)
    return tables, gt, validate.run_all(tables)


def test_outcome_counts_and_rates_add_up(built):
    tables, _, _ = built
    op = metrics.operational(tables)
    assert op["claims"] == len(tables["claim"]) == 1000
    assert sum(op["counts"].values()) == op["claims"]
    assert abs(sum(op["rates"].values()) - 1.0) < 0.001
    assert op["counts"]["approved"] > op["counts"]["denied"] > 0
    assert op["counts"]["docs_pending"] > 0 and op["counts"]["under_review"] > 0


def test_cycle_times_and_amounts_are_consistent(built):
    tables, _, _ = built
    op = metrics.operational(tables)
    assert 0 < op["days_to_approval"]["median"] <= op["days_to_settlement"]["median"]
    assert op["days_to_settlement"]["p90"] >= op["days_to_settlement"]["median"]
    a = op["amounts_cents"]
    assert a["claimed_total"] == sum(c["claimed_amount"] for c in tables["claim"])
    assert 0 < a["blocked_by_denial"] < a["claimed_total"]
    assert a["paid_total"] <= a["recommended_total"]
    assert a["held_for_docs_or_review"] > 0


def test_reserve_vs_final_differs_only_for_the_planted_limit_defects(built):
    tables, gt, _ = built
    r = metrics.operational(tables)["reserve_vs_final"]
    planted = [x for x in gt if x["label"] == "settlement_exceeds_limit"]
    assert r["mismatched_claims"] == len(planted) == config.inject_rows(1.0)
    assert r["recommended_total"] > r["reserve_total"]


def test_by_claim_type_covers_all_types(built):
    tables, _, _ = built
    by_type = metrics.operational(tables)["by_claim_type"]
    assert set(by_type) == {"AUTO", "HOME", "HLTH", "TRVL", "LIAB"}
    assert sum(v["claims"] for v in by_type.values()) == 1000


def test_predictions_do_not_take_ground_truth():
    assert list(inspect.signature(scoring.predictions).parameters) == ["tables", "checks"]


def test_scoring_planted_defects_and_injected_cases_are_exact(built):
    tables, gt, checks = built
    rows = {r["class"]: r for r in scoring.score(tables, gt, checks)}
    for name in (
        "settlement_exceeds_limit",
        "paid_twice",
        "claim_before_policy_start",
        "cancelled_before_incident",
    ):
        assert rows[name]["precision"] == 1.0 and rows[name]["recall"] == 1.0, name


def test_scoring_covers_every_label_and_is_reasonable(built):
    tables, gt, checks = built
    rows = scoring.score(tables, gt, checks)
    labels = {x for r in rows for x in r["labels"].split(", ")}
    assert labels == {r["label"] for r in gt}
    for r in rows:
        assert r["truth"] > 0
        assert r["recall"] is not None and r["recall"] >= 0.8, r["class"]
        assert r["precision"] is None or r["precision"] >= 0.8, r["class"]
    boundary = [r for r in rows if "decided as expected" in r["class"]]
    assert len(boundary) == 4 and all(r["precision"] is None for r in boundary)


def test_markdown_report_has_every_section(built):
    tables, gt, checks = built
    text = metrics.to_markdown(tables, gt, checks)
    for heading in (
        "## Outcomes",
        "## Amounts (USD)",
        "## Reserve vs final settlement",
        "## By claim type",
        "## Precision and recall",
    ):
        assert heading in text
    assert "documents (shared class)" in text
