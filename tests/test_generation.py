import re
from collections import Counter

import pytest

from claimsgen import config, masterdata, policies, schema
from claimsgen.vocab import ITEM_TYPES, PRODUCTS


@pytest.fixture(scope="module")
def data():
    master = masterdata.generate(1.0)
    return {**master, **policies.generate(master, 1.0)}


def test_counts(data):
    c = config.counts(1.0)
    assert (len(data["policy"]), len(data["customer"]), len(data["adjuster"])) == (
        c.policies,
        c.customers,
        c.adjusters,
    )
    assert len(data["policy"]) == 2000


def test_deterministic():
    a = masterdata.generate(0.2)
    b = masterdata.generate(0.2)
    assert a == b
    assert policies.generate(a, 0.2) == policies.generate(b, 0.2)


def test_all_ids_match_schema_and_are_unique(data):
    for table, rows in data.items():
        pk = schema.TABLE_BY_NAME[table].pk
        pattern = next(f for f in schema.TABLE_BY_NAME[table].fields if f.name == pk).allowed
        values = [r[pk] for r in rows]
        assert len(values) == len(set(values)), table
        assert all(re.match(pattern, v) for v in values), table


def test_foreign_keys_resolve(data):
    for table, rows in data.items():
        for f in schema.TABLE_BY_NAME[table].fields:
            if f.fk and table in data:
                parent = {r[schema.TABLE_BY_NAME[f.fk].pk] for r in data[f.fk]}
                assert {r[f.name] for r in rows} <= parent, (table, f.name)


def test_every_row_has_exactly_the_schema_fields(data):
    for table, rows in data.items():
        assert {tuple(sorted(r)) for r in rows} == {
            tuple(sorted(f.name for f in schema.TABLE_BY_NAME[table].fields))
        }, table


def test_customers_and_adjusters(data):
    years = lambda d: (config.AS_OF - d).days / 365.25
    assert all(18 <= years(c["dob"]) <= 85 for c in data["customer"])
    assert {a["specialty"] for a in data["adjuster"]} == set(PRODUCTS)
    held = {p["customer_id"] for p in data["policy"]}
    assert held == {c["customer_id"] for c in data["customer"]}


def test_coverage_catalogue_and_requirements(data):
    for c in data["coverage"]:
        assert c["default_deductible"] < c["default_limit"]
        assert set(filter(None, c["exclusion_codes"].split("|"))) <= set(ITEM_TYPES)
    for claim_type in PRODUCTS:
        mandatory = [
            r
            for r in data["document_requirement"]
            if r["claim_type"] == claim_type and r["mandatory"] == "Y"
        ]
        assert len(mandatory) >= 2, claim_type


def test_policy_dates_and_status_mix(data):
    events = {}
    for e in data["policy_event"]:
        events.setdefault(e["policy_id"], []).append(e)
    mix = Counter()
    for p in data["policy"]:
        assert p["policy_id"].split("-")[1] == p["product"]
        assert p["start_date"] < p["end_date"]
        assert p["start_date"] <= config.AS_OF
        evs = events[p["policy_id"]]
        assert evs[0]["event_type"] == "issued" and evs[0]["event_date"] == p["start_date"]
        dates = [e["event_date"] for e in evs]
        assert dates == sorted(dates)
        assert all(p["start_date"] <= d <= min(p["end_date"], config.AS_OF) for d in dates)
        mix[evs[-1]["event_type"]] += 1
    share = {k: v / len(data["policy"]) for k, v in mix.items()}
    assert 0.70 <= share["issued"] <= 0.80
    assert 0.09 <= share["expired"] <= 0.17
    assert 0.04 <= share["lapsed"] <= 0.12
    assert 0.01 <= share["cancelled"] <= 0.08
    in_force = [p for p in data["policy"] if events[p["policy_id"]][-1]["event_type"] == "issued"]
    assert all(p["end_date"] >= config.AS_OF for p in in_force)


def test_policy_coverage_terms(data):
    by_id = {p["policy_id"]: p for p in data["policy"]}
    cov = {c["coverage_id"]: c for c in data["coverage"]}
    for pc in data["policy_coverage"]:
        p = by_id[pc["policy_id"]]
        assert cov[pc["coverage_id"]]["product"] == p["product"]
        assert 0 <= pc["deductible"] < pc["limit_amount"]
        assert p["start_date"] <= pc["effective_start"] <= pc["effective_end"] == p["end_date"]
    late = sum(
        pc["effective_start"] > by_id[pc["policy_id"]]["start_date"]
        for pc in data["policy_coverage"]
    )
    assert 0.05 <= late / len(data["policy_coverage"]) <= 0.15
