import inspect

import pytest

from claimsgen import config, generate, intake, intake_examples, whatif


@pytest.fixture(scope="module", params=[0.05, 0.25, 1.0], ids=["starter", "quarter", "full"])
def tables(request):
    return generate.build_dataset(request.param)[0]


def test_seven_unique_examples_in_order(tables):
    ex = intake_examples.build(tables)
    assert [e.key for e in ex] == list(intake_examples.EXPECTED)
    assert len(ex) == 7 and len({e.key for e in ex}) == 7
    assert all(e.title and e.expect for e in ex)


def test_each_example_reaches_its_rule(tables):
    for e in intake_examples.build(tables):
        assert e.draft.submission_date <= config.intake_horizon()
        last = whatif.evaluate(tables, e.draft)["assessments"][-1]
        got = (last["decision"], last["rule_id"], last["reason_code"])
        assert got == intake_examples.EXPECTED[e.key], e.key


def test_build_is_deterministic(tables):
    assert intake_examples.build(tables) == intake_examples.build(tables)


def test_build_takes_only_tables():
    assert list(inspect.signature(intake_examples.build).parameters) == ["tables"]


def test_examples_round_trip_through_intake(tables):
    for e in intake_examples.build(tables):
        draft, errors = intake.parse_and_validate(e.draft.to_json(), tables)
        assert errors == [] and draft == e.draft, e.key
