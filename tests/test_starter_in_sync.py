from pathlib import Path

import pytest

from claimsgen import generate

STARTER = Path(__file__).resolve().parents[1] / "output" / "starter"


def test_committed_starter_matches_a_fresh_build(tmp_path):
    """The committed starter must be exactly what the generator produces now (review point g)."""
    if not STARTER.is_dir():
        pytest.skip("output/starter is not present")
    generate.build(tmp_path, scale=0.05)
    fresh = (tmp_path / "checksums.sha256").read_text(encoding="utf-8")
    committed = (STARTER / "checksums.sha256").read_text(encoding="utf-8")
    assert fresh == committed, (
        "output/starter is stale; run: python -m claimsgen build --scale 0.05 --out output/starter"
    )
