from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]


def test_quality_tab_renders_every_section_headless():
    pytest.importorskip("streamlit")
    from streamlit.testing.v1 import AppTest

    app = AppTest.from_string(_page_source(), default_timeout=180).run()
    assert not app.exception, app.exception
    headers = [h.value for h in app.subheader]
    for title in (
        "Validation checks",
        "Planted defects vs flagged",
        "Edge cases present and counted",
        "Answer key",
        "Data dictionary",
        "Rule catalogue",
        "Table browser",
    ):
        assert any(title in h for h in headers), title
    assert len(app.dataframe) >= 6  # the defects-vs-flagged section is text, not a table
    app.selectbox(key="q_table").select("settlement").run()
    app.selectbox(key="q_browse").select("claim").run()
    assert not app.exception


def _page_source() -> str:
    return (
        "import sys\n"
        f"sys.path.insert(0, {str(ROOT)!r})\n"
        "import app_quality\n"
        "from claimsgen import view_data\n"
        "tables, ground_truth, checks = view_data.load(0.05)\n"
        "app_quality.render(tables, ground_truth, checks)\n"
    )
