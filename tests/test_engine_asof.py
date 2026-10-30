from datetime import timedelta

import pytest

from claimsgen import config, engine, generate
from claimsgen.sensitivity import OUTPUT_TABLES


def _inputs(tables):
    return {k: v for k, v in tables.items() if k not in OUTPUT_TABLES}


@pytest.fixture(scope="module")
def starter():
    return generate.build_dataset(0.05)[0]


def test_default_as_of_is_byte_identical_starter(starter):
    t = _inputs(starter)
    out = engine.run(t)
    assert all(out[k] == starter[k] for k in out if k != "settlement")


def test_default_as_of_is_byte_identical_full(data):
    t = _inputs(data)
    out = engine.run(t)
    assert max(a["assessment_date"] for a in out["assessment"]) <= config.AS_OF
    assert all(out[k] == data[k] for k in OUTPUT_TABLES)


def test_later_as_of_lets_recent_claims_progress(data):
    t = _inputs(data)
    base = engine.run(t)
    later = engine.run(t, as_of=config.AS_OF + timedelta(days=60))
    assert len(later["claim_status_history"]) > len(base["claim_status_history"])
    assert max(e["event_date"] for e in base["claim_status_history"]) <= config.AS_OF


def test_earlier_as_of_stops_everything_after_it(data):
    cut = config.AS_OF - timedelta(days=200)
    out = engine.run(_inputs(data), as_of=cut)
    assert (
        max(e["event_date"] for e in out["claim_status_history"] if e["to_status"] != "submitted")
        <= cut
    )
