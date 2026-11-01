"""Stage strip and headline numbers (pure, starter scale)."""

import pytest

from claimsgen import intake_examples, metrics, view_data, view_stages, whatif


@pytest.fixture(scope="module")
def dataset():
    return view_data.load(0.05)


@pytest.fixture(scope="module")
def results(dataset):
    tables = dataset[0]
    return {e.key: whatif.evaluate(tables, e.draft) for e in intake_examples.build(tables)}


def _by(result):
    return {s["stage"]: s for s in view_stages.stages(result)}


def test_five_stages_in_order(results):
    names = [s["stage"] for s in view_stages.stages(results["clean_approve"])]
    assert names == ["Intake", "Coverage", "Documents", "Eligibility", "Routing"]


def test_approved_claim_passes_all_five(results):
    assert {s["status"] for s in view_stages.stages(results["clean_approve"])} == {"passed"}


def test_pend_docs_stops_at_documents(results):
    s = _by(results["missing_document"])
    assert (s["Documents"]["status"], s["Documents"]["rule_id"]) == ("stopped", "R-DOC-01")
    assert s["Documents"]["note"] == "missing_document"
    assert s["Coverage"]["status"] == "passed"
    assert s["Eligibility"]["status"] == s["Routing"]["status"] == "not reached"


def test_denials_stop_at_the_real_rule(results):
    s = _by(results["lapsed_policy"])
    assert (s["Coverage"]["status"], s["Coverage"]["rule_id"]) == ("stopped", "R-COV-02")
    assert s["Documents"]["status"] == s["Routing"]["status"] == "not reached"
    s = _by(results["within_deductible"])
    assert (s["Routing"]["status"], s["Routing"]["rule_id"]) == ("stopped", "R-PAY-01")
    assert s["Eligibility"]["status"] == "passed"


def test_duplicate_stops_at_eligibility(results):
    s = _by(results["duplicate"])
    assert (s["Eligibility"]["status"], s["Eligibility"]["rule_id"]) == ("stopped", "R-ELG-03")
    assert s["Routing"]["status"] == "not reached"


def test_at_most_one_stage_stopped(results):
    for r in results.values():
        assert [s["status"] for s in view_stages.stages(r)].count("stopped") <= 1


def test_headline_matches_metrics_and_exceptions(dataset):
    tables, _, checks = dataset
    h = view_stages.headline(tables, checks, "abc")
    through = metrics.operational(tables)["straight_through"]
    assert h["claims"] == len(tables["claim"]) == 50
    assert h["straight_through_rate"] == through["straight_through_rate"]
    assert h["open_exceptions"] == sum(
        len(v) for v in view_data.exceptions(tables, checks).values()
    )
    assert h["seed"] == 20261022 and h["checksum_present"] is True
    assert view_stages.headline(tables, checks, "")["checksum_present"] is False
