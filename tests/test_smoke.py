import re
from pathlib import Path

import claimsgen

SRC = Path(__file__).resolve().parents[1] / "src" / "claimsgen"


def test_seed():
    assert claimsgen.SEED == 20261022


def test_no_clock_or_unseeded_random():
    bad = re.compile(
        r"datetime\.now|time\.time|date\.today|^\s*import random|random\.(?!Random)\w+\(",
        re.MULTILINE,
    )
    for f in SRC.rglob("*.py"):
        assert not bad.search(f.read_text(encoding="utf-8")), f"nondeterministic source in {f}"
