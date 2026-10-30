import pytest

from claimsgen import config, engine, generate, metrics, scoring, sensitivity


@pytest.fixture(scope="module")
def built():
    tables, gt = generate.build_dataset(0.3)
    return tables, gt, sensitivity.sweep(tables, gt)


def test_sweep_is_deterministic(built):
    tables, gt, result = built
    assert sensitivity.sweep(tables, gt) == result


def test_config_is_restored(built):
    assert config.APPROVER_THRESHOLD_CENTS == 1_000_000
    assert config.FRAUD_THRESHOLD == 0.5


def test_config_is_restored_after_an_error(built):
    with pytest.raises(KeyError):
        sensitivity._rerun({"claim": []}, fraud_threshold=0.9)
    assert config.FRAUD_THRESHOLD == 0.5


def test_current_rows_reproduce_the_live_numbers(built):
    tables, _gt, result = built
    cur = [r for r in result["approver"] + result["fraud"] if r["current"]]
    assert len(cur) == 2 and result["current"]["fraud_threshold"] == 0.5
    fraud = scoring.predictions(tables, [])["suspected_fraud"]
    inputs = {k: v for k, v in tables.items() if k not in sensitivity.OUTPUT_TABLES}
    claimed = {c["claim_id"]: c["claimed_amount"] for c in tables["claim"]}
    routed = [
        s["recommended_amount"]
        # the dataset also holds injected defect rows (e.g. a second settlement); the sweep re-runs the clean engine
        for s in engine.run(inputs)["settlement"]
        if s["recommended_amount"] > config.APPROVER_THRESHOLD_CENTS
    ]
    for r in cur:
        assert r["fraud_referred"] == len(fraud)
        assert r["flagged_amount_cents"] == sum(claimed[c] for c in fraud)
        assert r["approver_settlements"] == len(routed)
        assert r["approver_amount_cents"] == sum(routed)


def test_monotonicity(built):
    _, _, result = built
    a = [r["approver_settlements"] for r in result["approver"]]
    f = [r["fraud_referred"] for r in result["fraud"]]
    assert a == sorted(a, reverse=True)
    assert f == sorted(f, reverse=True)
    assert all(0 <= r["precision"] <= 1 for r in result["fraud"] if r["precision"] is not None)


def test_markdown_section_marks_current(built):
    _, _, result = built
    text = "\n".join(sensitivity.to_markdown_section(result))
    assert text.count("(current)") == 2
    assert metrics.usd(1_000_000) in text
