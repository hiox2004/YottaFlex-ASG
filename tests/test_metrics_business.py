import pytest

from claimsgen import generate, metrics


@pytest.fixture(scope="module")
def op():
    tables, _ = generate.build_dataset(1.0)
    return tables, metrics.operational(tables)


def test_touchless_counts_are_consistent(op):
    _, o = op
    t = o["touchless"]
    assert t["touchless"] + t["reviewed"] == t["assessed"]
    assert 0 < t["touchless_rate"] <= 1
    assert t["human_step"] <= t["reviewed"]
    assert abs(t["touchless_rate"] - t["touchless"] / t["assessed"]) < 1e-4


def test_by_rule_adds_up_to_the_totals(op):
    _, o = op
    a = o["amounts_cents"]
    total = {"blocked": 0, "reduced": 0, "held": 0}
    for v in o["by_rule"].values():
        total[v["effect"]] += v["amount_cents"]
    assert total["blocked"] == a["blocked_by_denial"]
    assert total["reduced"] == a["reduced_by_rules"]
    assert total["held"] == a["held_for_docs_or_review"]


def test_approver_workload_covers_every_approved_claim(op):
    tables, o = op
    first = {}
    for s in tables["settlement"]:
        first.setdefault(s["claim_id"], s)
    approved = [s for s in first.values() if s["approver_role"]]
    w = o["approver_workload"]
    assert sum(v["settlements"] for v in w.values()) == len(approved)
    assert sum(v["amount_cents"] for v in w.values()) == sum(s["approved_amount"] for s in approved)
    assert set(w) <= {"process_owner", "approver"}


def test_aging_and_cycle_by_type(op):
    _, o = op
    g = o["docs_pending_aging"]
    assert g["count"] == o["counts"]["docs_pending"]
    assert 0 <= g["median_days"] <= g["p90_days"] <= g["max_days"]
    assert g["older_than_14_days"] <= g["count"]
    for v in o["cycle_by_claim_type"].values():
        assert 0 < v["median_days"] <= v["p90_days"]


def test_markdown_has_new_sections():
    tables, gt = generate.build_dataset(0.2)
    text = metrics.to_markdown(tables, gt, [])
    for h in (
        "## Money effect by rule",
        "## Touchless",
        "## Approver workload",
        "## Documents pending",
        "## Cycle time by claim type",
        "## Threshold sensitivity",
    ):
        assert h in text
    assert "(current)" in text
