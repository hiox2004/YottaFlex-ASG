import pytest

from claimsgen import config, engine, generate, sensitivity
from claimsgen.sensitivity import OUTPUT_TABLES


@pytest.fixture(scope="module")
def starter():
    return generate.build_dataset(0.05)[0]


@pytest.fixture(scope="module")
def inputs(starter):
    return {k: v for k, v in starter.items() if k not in OUTPUT_TABLES}


@pytest.fixture(scope="module")
def default_out(inputs):
    return engine.run(inputs)


def test_defaults_match_dataset_and_explicit_defaults(starter, inputs, default_out):
    assert all(default_out[k] == starter[k] for k in default_out if k != "settlement")
    explicit = engine.run(
        inputs,
        fraud_threshold=config.FRAUD_THRESHOLD,
        approver_threshold_cents=config.APPROVER_THRESHOLD_CENTS,
    )
    assert explicit == default_out


def test_fraud_threshold_argument_equals_patched_config(inputs, default_out, monkeypatch):
    arg = engine.run(inputs, fraud_threshold=0.75)
    monkeypatch.setattr(config, "FRAUD_THRESHOLD", 0.75)
    assert engine.run(inputs) == arg
    assert arg != default_out


def test_approver_argument_equals_patched_config(inputs, default_out, monkeypatch):
    # 500,000 (5,000 USD), not 2,000,000: at scale 0.05 no settlement falls between 10k and 20k USD after the
    # R-ELG-01 data change, so only a threshold well below the default is guaranteed to change the output.
    arg = engine.run(inputs, approver_threshold_cents=500_000)
    monkeypatch.setattr(config, "APPROVER_THRESHOLD_CENTS", 500_000)
    assert engine.run(inputs) == arg
    assert arg != default_out


def test_arguments_do_not_touch_config(inputs):
    engine.run(inputs, fraud_threshold=0.25, approver_threshold_cents=500_000)
    assert config.FRAUD_THRESHOLD == 0.5
    assert config.APPROVER_THRESHOLD_CENTS == 2_500_000


def test_sweep_never_mutates_config_during_any_engine_run(starter, monkeypatch):
    fraud0, appr0 = config.FRAUD_THRESHOLD, config.APPROVER_THRESHOLD_CENTS
    real, calls = engine.run, []

    def recorder(*a, **kw):
        assert config.FRAUD_THRESHOLD == fraud0
        assert config.APPROVER_THRESHOLD_CENTS == appr0
        calls.append(kw)
        return real(*a, **kw)

    monkeypatch.setattr(engine, "run", recorder)
    result = sensitivity.sweep(starter, [])
    assert len(calls) == len(sensitivity.APPROVER_VALUES) + len(sensitivity.FRAUD_VALUES)
    assert [r["value"] for r in result["approver"]] == sensitivity.APPROVER_VALUES
    assert config.FRAUD_THRESHOLD == fraud0
    assert config.APPROVER_THRESHOLD_CENTS == appr0
    monkeypatch.undo()
    # arguments reproduce the old patch-the-global numbers
    for row in result["fraud"]:
        monkeypatch.setattr(config, "FRAUD_THRESHOLD", row["value"])
        old = real({k: v for k, v in starter.items() if k not in OUTPUT_TABLES})
        monkeypatch.undo()
        new = sensitivity._rerun(starter, fraud_threshold=row["value"])
        assert all(new[k] == old[k] for k in old)
