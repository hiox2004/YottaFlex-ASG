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


def test_first_run_has_no_exception_and_no_result(AppTest):
    app = _app(AppTest)
    assert len(app.tabs) == 8
    assert (
        not app.session_state["intake_results"] if "intake_results" in app.session_state else True
    )


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
    assert not app.session_state["intake_results"]


def test_request_docs_leads_to_second_assessment_and_approval(AppTest):
    app = _app(AppTest)
    first = _submit(app, "missing_document")
    assert first["decision"]["decision"] == "pend_docs"
    app.button(key="intake_request_docs").click().run()
    assert not app.exception, app.exception
    second = app.session_state["intake_results"][-1]["result"]
    assert len(second["assessments"]) == 2
    assert second["decision"]["decision"] == "approve"
    assert len(app.session_state["intake_results"]) == 2


def test_clear_empties_the_list(AppTest):
    app = _app(AppTest)
    _submit(app, "clean_approve")
    assert len(app.session_state["intake_results"]) == 1
    app.button(key="intake_clear").click().run()
    assert not app.exception, app.exception
    assert app.session_state["intake_results"] == []
