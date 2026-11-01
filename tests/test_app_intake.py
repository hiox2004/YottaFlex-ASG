"""Headless test of the Submit a claim tab at the starter scale."""

from pathlib import Path

import pytest

from claimsgen import intake_examples

ROOT = Path(__file__).resolve().parent.parent
TITLES = {k: v[0] for k, v in intake_examples.TITLES.items()}


@pytest.fixture(scope="module")
def AppTest():
    pytest.importorskip("streamlit")
    from streamlit.testing.v1 import AppTest

    return AppTest


def _app(AppTest):
    app = AppTest.from_file(str(ROOT / "app.py"), default_timeout=180).run()
    assert not app.exception, app.exception
    return app


def _submit(app, key):
    app.selectbox(key="intake_example").select(TITLES[key]).run()
    app.button(key="intake_load").click().run()
    app.button(key="intake_submit").click().run()
    assert not app.exception, app.exception
    return app.session_state["intake_results"][-1]["result"]


def test_first_run_auto_evaluates_one_result(AppTest):
    app = _app(AppTest)
    assert len(app.tabs) == 8
    results = app.session_state["intake_results"]
    assert len(results) == 1
    assert results[0]["result"]["decision"]["decision"] == "approve"
    app.run()
    assert len(app.session_state["intake_results"]) == 1


def test_stage_strip_is_shown(AppTest):
    app = _app(AppTest)
    text = " ".join(m.value for m in app.markdown)
    for name in ("Intake", "Coverage", "Documents", "Eligibility", "Routing"):
        assert f"**{name}**" in text
    assert any(s.value == "Workflow stages" for s in app.subheader)


def test_dataset_checksum_unchanged_by_autorun(AppTest):
    from claimsgen import view_data

    tables = view_data.load(0.05)[0]
    before = view_data.dataset_checksum(tables)
    _app(AppTest)
    assert view_data.dataset_checksum(tables) == before


def test_headline_strip_has_four_metrics(AppTest):
    app = _app(AppTest)
    labels = [m.label for m in app.metric[:4]]
    assert labels[:3] == ["Claims", "Straight-through", "Open exceptions"]
    assert labels[3].startswith("Seed ")


@pytest.mark.parametrize("key", list(intake_examples.EXPECTED))
def test_each_example_matches_expected(AppTest, key):
    result = _submit(_app(AppTest), key)
    d = result["decision"]
    assert (d["decision"], d["rule_id"], d["reason_code"]) == intake_examples.EXPECTED[key]


def test_invalid_json_gives_error_and_no_result(AppTest):
    app = _app(AppTest)
    app.text_area(key="intake_json").set_value("{not json").run()
    app.button(key="intake_submit").click().run()
    assert not app.exception, app.exception
    assert app.error
    assert len(app.session_state["intake_results"]) == 1  # only the auto-evaluated example


def test_request_docs_leads_to_second_assessment_and_approval(AppTest):
    app = _app(AppTest)
    first = _submit(app, "missing_document")
    assert first["decision"]["decision"] == "pend_docs"
    app.button(key="intake_request_docs").click().run()
    assert not app.exception, app.exception
    second = app.session_state["intake_results"][-1]["result"]
    assert len(second["assessments"]) == 2
    assert second["decision"]["decision"] == "approve"
    assert (
        len(app.session_state["intake_results"]) == 3
    )  # auto example, pended claim, resumed claim


def test_clear_empties_the_list(AppTest):
    app = _app(AppTest)
    _submit(app, "clean_approve")
    assert len(app.session_state["intake_results"]) == 1
    app.button(key="intake_clear").click().run()
    assert not app.exception, app.exception
    assert app.session_state["intake_results"] == []
    app.run()
    assert app.session_state["intake_results"] == []


def test_switching_dataset_clears_results(AppTest):
    app = _app(AppTest)
    _submit(app, "clean_approve")
    assert len(app.session_state["intake_results"]) == 1
    options = app.sidebar.selectbox(key="dataset").options
    other = next(o for o in options if o != app.sidebar.selectbox(key="dataset").value)
    app.sidebar.selectbox(key="dataset").select(other).run()
    assert not app.exception, app.exception
    results = app.session_state["intake_results"]
    assert len(results) == 1  # a fresh auto result for the new dataset
    assert results[0]["scale"] != 0.05


def test_text_area_is_capped(AppTest):
    app = _app(AppTest)
    assert app.text_area(key="intake_json").max_chars == 50_000


def test_choosing_an_example_loads_it_without_clicking(AppTest):
    app = _app(AppTest)
    before = app.session_state["intake_json"]
    app.selectbox(key="intake_example").select(TITLES["lapsed_policy"]).run()
    assert not app.exception, app.exception
    assert app.session_state["intake_json"] != before
    assert app.session_state["intake_loaded"] == TITLES["lapsed_policy"]


def test_read_first_panel_states_the_units_from_config(AppTest):
    import app_basics

    from claimsgen import config

    text = app_basics.text()
    assert config.CURRENCY in text and str(config.AS_OF) in text
    assert f"{config.APPROVER_THRESHOLD_CENTS // 100:,}" in text
    assert f"{config.DOC_WINDOW_DAYS} days" in text
    app = _app(AppTest)
    assert any("Read first" in e.label for e in app.expander)


def test_readme_carries_the_same_units_table_as_the_app():
    import app_basics

    readme = (ROOT / "README.md").read_text(encoding="utf-8").replace("\r\n", "\n")
    assert app_basics.text().strip() in readme
