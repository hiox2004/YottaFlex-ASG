"""The scale parameter accepts only values the generator can build (config.check_scale), with one clean message."""

import subprocess
import sys
from pathlib import Path

import pytest

from claimsgen import __main__ as cli
from claimsgen import config, generate

ROOT = Path(__file__).resolve().parent.parent
BAD = [0, -1, 0.01, 0.06, 0.07, 5.01, float("nan"), float("inf")]


@pytest.mark.parametrize("scale", BAD)
def test_unsupported_scales_raise_value_error_with_the_range(scale):
    with pytest.raises(ValueError, match="scale must be 0.05"):
        generate.build_dataset(scale)


@pytest.mark.parametrize("scale", [config.STARTER_SCALE, config.MIN_SCALE, 1.0, config.MAX_SCALE])
def test_supported_scales_pass_the_check(scale):
    assert config.check_scale(scale) == scale


@pytest.mark.parametrize("scale", ["0", "-1", "0.01", "5.01", "abc"])
def test_cli_prints_one_error_line_and_exits_2(scale, tmp_path, capsys):
    with pytest.raises(SystemExit) as exc:
        cli.main(["build", "--scale", scale, "--out", str(tmp_path / "x")])
    assert exc.value.code == 2
    err = capsys.readouterr().err
    assert "Traceback" not in err
    assert len([ln for ln in err.splitlines() if "error:" in ln]) == 1
    assert "scale must be 0.05 (the starter) or between 0.075 and 5.0" in err
    assert not (tmp_path / "x").exists()


def test_verify_script_fails_with_the_same_message():
    run = subprocess.run(
        [sys.executable, str(ROOT / "scripts" / "verify.py"), "0.01"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert run.returncode == 2
    assert "Traceback" not in run.stderr
    assert run.stderr.strip().startswith("error: scale must be 0.05 (the starter) or between 0.075")


def test_the_minimum_scale_builds_with_every_scenario_present(tmp_path):
    result = generate.build(tmp_path, scale=config.MIN_SCALE)
    assert result["ok"]
    _, truth = generate.build_dataset(config.MIN_SCALE)
    labels = {g["label"] for g in truth}
    expected = set(config.SCENARIO_RATES) | {
        "claim_before_policy_start",
        "cancelled_before_incident",
        "settlement_exceeds_limit",
        "paid_twice",
        "missing_mandatory_doc",
    }
    assert expected <= labels
