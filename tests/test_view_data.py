import inspect
from collections import Counter
from pathlib import Path

import pytest

from claimsgen import config, view_data

ROOT = Path(__file__).resolve().parents[1]


@pytest.fixture(scope="module")
def full():
    return view_data.load(1.0)


def test_decisions_table_has_one_row_per_claim_with_rule_and_actor(full):
    tables, _, _ = full
    rows = view_data.decisions_table(tables)
    assert [r["claim_id"] for r in rows] == [c["claim_id"] for c in tables["claim"]]
    assert all(
        {"status", "decision", "rule_id", "reason_code", "actor_role"} <= set(r) for r in rows
    )
    decided = [r for r in rows if r["decision"] != "not_assessed"]
    assert all(r["rule_id"] and r["reason_code"] for r in decided)
    assert all(r["actor_role"] for r in rows)
    status = Counter(r["status"] for r in rows)
    assert status["submitted"] == sum(r["decision"] == "not_assessed" for r in rows)


def test_exceptions_cover_the_required_categories(full):
    tables, _, checks = full
    found = view_data.exceptions(tables, checks)
    assert set(found) == set(view_data.EXCEPTION_TITLES.values())
    n = config.inject_rows(1.0)
    by = {title: rows for title, rows in found.items()}
    assert len(by["Paid twice (integrity defect)"]) == n
    assert len(by["Settlement above the replayed limit (integrity defect)"]) == n
    assert len(by["Claim before policy start (R-COV-01)"]) == n
    assert len(by["Policy cancelled before incident (R-COV-02)"]) == n
    for key in (
        "Documents pending (R-DOC-01)",
        "Duplicate claim referred (R-ELG-03)",
        "Over limit, paid at the cap or nothing (R-PAY-01)",
    ):
        assert by[key], key
    claims = {c["claim_id"] for c in tables["claim"]}
    assert all(r["claim_id"] in claims for rows in found.values() for r in rows)


def test_decisions_and_exceptions_never_see_ground_truth():
    assert list(inspect.signature(view_data.decisions_table).parameters) == ["tables"]
    assert list(inspect.signature(view_data.exceptions).parameters) == ["tables", "checks"]
    assert list(inspect.signature(view_data.claim_detail).parameters) == ["tables", "claim_id"]


def test_claim_detail_timeline_matches_history(full):
    tables, _, checks = full
    twice = view_data.exceptions(tables, checks)["Paid twice (integrity defect)"][0]
    detail = view_data.claim_detail(tables, twice["claim_id"])
    assert len(detail["settlement"]) == 2
    history = [e for e in tables["claim_status_history"] if e["claim_id"] == twice["claim_id"]]
    assert len(detail["timeline"]) == len(history) and detail["timeline"][0]["to"] == "submitted"
    assert detail["timeline"][-1]["to"] == "paid"
    denied = next(r for r in view_data.decisions_table(tables) if r["status"] == "denied")
    assert view_data.claim_detail(tables, denied["claim_id"])["timeline"][-1]["to"] == "denied"
    assert all(t["actor_role"] for t in detail["timeline"])


def test_display_formats_money_dates_and_nulls(full):
    tables, _, _ = full
    rows = view_data.display("settlement", tables["settlement"][:5])
    assert all(
        "." in r["recommended_amount"] and r["recommended_amount"].replace(".", "").isdigit()
        for r in rows
    )
    assert all(set(r.values()) and None not in r.values() for r in rows)


def test_metrics_panel_has_operational_and_scoring(full):
    tables, gt, checks = full
    panel = view_data.metrics_panel(tables, gt, checks)
    assert panel["operational"]["claims"] == 1000
    assert len(panel["scoring"]) >= 14


def test_app_runs_headless_and_shows_every_panel():
    pytest.importorskip("streamlit")
    from streamlit.testing.v1 import AppTest

    app = AppTest.from_file(str(ROOT / "app.py"), default_timeout=180).run()
    assert not app.exception, app.exception
    assert app.title[0].value.startswith("Claims workflow")
    assert len(app.tabs) == 4
    assert len(app.dataframe) >= 5
    app.selectbox(key="exception").select("Documents pending (R-DOC-01)").run()
    assert not app.exception
    ids = [o for o in app.selectbox(key="claim").options]
    app.selectbox(key="claim").select(ids[-1]).run()
    assert not app.exception
    app.selectbox(key="dataset").select("Full (2,000 policies, 1,000 claims)").run()
    assert not app.exception
