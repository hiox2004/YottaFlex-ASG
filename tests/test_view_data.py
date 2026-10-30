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


def test_metrics_panel_includes_sensitivity_and_new_metrics(full):
    tables, gt, checks = full
    panel = view_data.metrics_panel(tables, gt, checks)
    sens = panel["sensitivity"]
    assert len(sens["approver"]) == 4 and len(sens["fraud"]) == 4
    assert sum(r["current"] for r in sens["fraud"]) == 1
    op = panel["operational"]
    assert {"by_rule", "touchless", "approver_workload", "docs_pending_aging"} <= set(op)
    assert view_data.metrics_panel(tables, gt, checks, sens)["sensitivity"] is sens


def test_checksum_is_stable_and_sensitive(full):
    tables = full[0]
    first = view_data.dataset_checksum(tables)
    assert first == view_data.dataset_checksum(tables) and len(first) == 64
    changed = {k: [dict(r) for r in v] for k, v in tables.items()}
    changed["claim"][0]["claimed_amount"] += 1
    assert view_data.dataset_checksum(changed) != first


def test_rebuild_and_compare_is_identical_at_starter_scale():
    same, one, two = view_data.rebuild_and_compare(0.05)
    assert same and one == two and len(one) == 64


def test_realism_numbers_add_up(full):
    tables = full[0]
    r = view_data.realism(tables)
    n = len(tables["claim"])
    assert sum(b["count"] for b in r["claimed_histogram"]) == n
    assert sum(b["count"] for b in r["lag_days"]) == n
    assert sum(r["claim_type_mix"].values()) == n
    assert sum(r["policy_status"].values()) == len(tables["policy"])
    s = r["claimed_stats_usd"]
    assert 0 < s["median"] <= s["p90"] and s["mean"] > 0
    assert [b["bin_days"] for b in r["lag_days"]] == ["0", "1", "2", "3", "4-7", "8-14", "15+"]


def test_app_runs_headless_and_shows_every_panel():
    pytest.importorskip("streamlit")
    from streamlit.testing.v1 import AppTest

    app = AppTest.from_file(str(ROOT / "app.py"), default_timeout=180).run()
    assert not app.exception, app.exception
    assert app.title[0].value.startswith("Claims workflow")
    assert len(app.tabs) == 8
    assert len(app.dataframe) >= 5
    assert app.text_input(key="seed").disabled
    app.button(key="rebuild").click().run()
    assert not app.exception, app.exception
    assert any(s.value.startswith("Identical rebuild") for s in app.success)
    assert not app.error
    app.selectbox(key="dataset").select("Medium (500 policies, 250 claims)").run()
    assert not app.exception, app.exception
    app.selectbox(key="exception").select("Documents pending (R-DOC-01)").run()
    assert not app.exception
    ids = [o for o in app.selectbox(key="claim").options]
    app.selectbox(key="claim").select(ids[-1]).run()
    assert not app.exception
    app.selectbox(key="dataset").select("Full (2,000 policies, 1,000 claims)").run()
    assert not app.exception
