"""IMP-003: the evaluation can fail. Break one rule at a time, re-run the engine on the final inputs, and score the
result against the UNCHANGED ground_truth: the metrics must move."""

import pytest

from claimsgen import config, engine, generate, rules, scoring, validate
from payable_reference import last_approved, replay

OUTPUTS = (
    "claim_adjuster_assignment",
    "assessment",
    "reserve",
    "settlement",
    "claim_status_history",
)


@pytest.fixture(scope="module")
def built():
    tables, gt = generate.build_dataset(1.0)
    inputs = {k: v for k, v in tables.items() if k not in OUTPUTS}
    return tables, inputs, gt


def _scores(tables, gt):
    rows = scoring.score(tables, gt, validate.run_all(tables))
    return {r["class"]: r for r in rows}


def _rerun(inputs, gt):
    tables = {**inputs, **engine.run(inputs)}
    return tables, _scores(tables, gt)


def test_baseline_metrics_are_high(built):
    tables, inputs, gt = built
    again, rows = _rerun(inputs, gt)
    assert again["assessment"] == tables["assessment"]
    for name in (
        "cancelled_before_incident",
        "lapsed_policy",
        "boundary_amount_at_deductible (decided as expected)",
    ):
        assert rows[name]["recall"] >= 0.9, name


def test_ignoring_cancel_and_lapse_events_drops_recall(built, monkeypatch):
    _, inputs, gt = built
    _, good = _rerun(inputs, gt)
    monkeypatch.setattr(
        rules,
        "in_force",
        lambda policy, ends, day: policy["start_date"] <= day <= policy["end_date"],
    )
    _, bad = _rerun(inputs, gt)
    for name in ("cancelled_before_incident", "lapsed_policy"):
        assert good[name]["recall"] >= 0.9
        assert bad[name]["recall"] <= good[name]["recall"] - 0.5, name


def test_ignoring_deductible_is_caught_by_scoring_and_by_the_reference(built, monkeypatch):
    _, inputs, gt = built
    good_tables, good = _rerun(inputs, gt)
    name = "boundary_amount_at_deductible (decided as expected)"
    original = rules.payable

    def no_deductible(eligible, pcv_by_cov, committed):
        return original(
            eligible, {k: dict(v, deductible=0) for k, v in pcv_by_cov.items()}, committed
        )

    monkeypatch.setattr(rules, "payable", no_deductible)
    bad_tables, bad = _rerun(inputs, gt)
    assert good[name]["recall"] >= 0.9
    assert bad[name]["recall"] <= good[name]["recall"] - 0.5

    def disagreements(tables):
        approved, last = last_approved(tables), {}
        for a in tables["assessment"]:
            last[a["claim_id"]] = a
        ref = replay(tables, approved)
        return sum(last[c]["payable_amount"] != ref[c] for c in approved)

    assert disagreements(good_tables) == 0
    assert disagreements(bad_tables) > 50


def test_zero_day_document_window_hurts_document_precision(built, monkeypatch):
    _, inputs, gt = built
    _, good = _rerun(inputs, gt)
    cls = "documents (shared class)"
    monkeypatch.setattr(config, "DOC_WINDOW_DAYS", 0)
    _, bad = _rerun(inputs, gt)
    assert good[cls]["precision"] >= 0.9
    assert bad[cls]["precision"] < good[cls]["precision"] - 0.1
