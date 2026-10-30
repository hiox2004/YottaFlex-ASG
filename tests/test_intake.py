"""Intake validation: structure and format only. Business outcomes must be accepted, not rejected."""

import json
from datetime import date, datetime, timedelta

import pytest

from claimsgen import config, generate, masterdata, vocab
from claimsgen.draft import Doc, Draft, Item
from claimsgen.intake import parse_and_validate

REQUIRED = ("policy_id", "incident_date", "incident_type", "submission_date", "items")


@pytest.fixture(scope="module")
def tables():
    return generate.build_dataset(0.05)[0]


def _policy(tables):
    return tables["policy"][0]


def _coverage_ids(tables, policy_id):
    return [pc["coverage_id"] for pc in tables["policy_coverage"] if pc["policy_id"] == policy_id]


def _policy_coverage(tables, policy_id, coverage_id):
    return next(
        pc
        for pc in tables["policy_coverage"]
        if pc["policy_id"] == policy_id and pc["coverage_id"] == coverage_id
    )


def _incident_type_for(tables, coverage_id):
    name = next(c["name"] for c in tables["coverage"] if c["coverage_id"] == coverage_id)
    return masterdata.COVERAGE_PROFILE[name][0][0]


def _valid(tables) -> dict:
    policy = _policy(tables)
    cov = _coverage_ids(tables, policy["policy_id"])[0]
    return {
        "policy_id": policy["policy_id"],
        "incident_date": "2026-10-01",
        "incident_type": _incident_type_for(tables, cov),
        "submission_date": "2026-10-10",
        "items": [{"coverage_id": cov, "item_type": "repair", "amount": "4200.50"}],
        "documents": [{"doc_type": "photo", "received_date": "2026-10-10"}],
    }


def _errs(raw, tables) -> list[dict]:
    draft, errors = parse_and_validate(raw, tables)
    assert draft is None
    assert errors
    return errors


def _fields(errors) -> list[str]:
    return [e["field"] for e in errors]


def _product_types(tables, product) -> set[str]:
    return {
        t
        for c in tables["coverage"]
        if c["product"] == product
        for t in masterdata.COVERAGE_PROFILE[c["name"]][0]
    }


def test_dict_and_json_string_give_equal_drafts(tables):
    raw = _valid(tables)
    d1, e1 = parse_and_validate(raw, tables)
    d2, e2 = parse_and_validate(json.dumps(raw), tables)
    assert e1 == e2 == []
    assert d1 is not None and d1 == d2


def test_valid_submission_builds_draft_with_integer_cents(tables):
    raw = _valid(tables)
    cov = raw["items"][0]["coverage_id"]
    draft, errors = parse_and_validate(raw, tables)
    assert errors == []
    assert draft == Draft(
        raw["policy_id"],
        date(2026, 10, 1),
        raw["incident_type"],
        date(2026, 10, 10),
        (Item(cov, "repair", 420050),),
        (Doc("photo", date(2026, 10, 10)),),
    )


def test_documents_are_optional(tables):
    raw = _valid(tables)
    del raw["documents"]
    draft, errors = parse_and_validate(raw, tables)
    assert errors == [] and draft.documents == ()


def test_missing_required_keys_are_all_reported(tables):
    raw = _valid(tables)
    for key in REQUIRED:
        del raw[key]
    assert _fields(_errs(raw, tables)) == list(REQUIRED)


def test_unknown_top_level_key_is_an_error(tables):
    raw = _valid(tables)
    raw["adjuster_note"] = "x"
    assert _fields(_errs(raw, tables)) == ["adjuster_note"]


def test_claim_type_is_rejected_with_derivation_message(tables):
    raw = _valid(tables)
    raw["claim_type"] = "HLTH"
    assert _errs(raw, tables) == [
        {
            "field": "claim_type",
            "message": "claim_type is derived from the policy and must be removed",
        }
    ]


def test_unknown_policy_is_an_error(tables):
    raw = _valid(tables)
    raw["policy_id"] = "POL-AUTO-2026-999999"
    assert _fields(_errs(raw, tables)) == ["policy_id"]


def test_malformed_incident_date_is_an_error(tables):
    raw = _valid(tables)
    raw["incident_date"] = "10/01/2026"
    assert _fields(_errs(raw, tables)) == ["incident_date"]


def test_incident_after_submission_is_an_error(tables):
    raw = _valid(tables)
    raw["incident_date"] = "2026-10-11"
    assert _fields(_errs(raw, tables)) == ["incident_date"]


def test_submission_beyond_intake_horizon_is_an_error(tables):
    raw = _valid(tables)
    raw["submission_date"] = (config.intake_horizon() + timedelta(days=1)).isoformat()
    assert "submission_date" in _fields(_errs(raw, tables))


def test_document_received_before_submission_is_an_error(tables):
    raw = _valid(tables)
    raw["documents"][0]["received_date"] = "2026-10-09"
    assert _fields(_errs(raw, tables)) == ["documents[0].received_date"]


def test_document_received_beyond_intake_horizon_is_an_error(tables):
    raw = _valid(tables)
    raw["documents"][0]["received_date"] = (config.intake_horizon() + timedelta(days=1)).isoformat()
    assert _fields(_errs(raw, tables)) == ["documents[0].received_date"]


def test_incident_type_must_belong_to_the_policy_product(tables):
    raw = _valid(tables)
    product = _policy(tables)["product"]
    raw["incident_type"] = next(
        t for t in vocab.INCIDENT_TYPES if t not in _product_types(tables, product)
    )
    assert _fields(_errs(raw, tables)) == ["incident_type"]


def test_empty_items_is_an_error(tables):
    raw = _valid(tables)
    raw["items"] = []
    assert _fields(_errs(raw, tables)) == ["items"]


def test_more_than_twenty_items_is_an_error(tables):
    raw = _valid(tables)
    raw["items"] = [dict(raw["items"][0]) for _ in range(21)]
    assert _fields(_errs(raw, tables)) == ["items"]


def test_twenty_items_is_accepted(tables):
    raw = _valid(tables)
    raw["items"] = [dict(raw["items"][0]) for _ in range(20)]
    draft, errors = parse_and_validate(raw, tables)
    assert errors == [] and len(draft.items) == 20


def test_coverage_must_be_on_the_policy(tables):
    raw = _valid(tables)
    policy_covs = _coverage_ids(tables, raw["policy_id"])
    other = next(
        c["coverage_id"] for c in tables["coverage"] if c["coverage_id"] not in policy_covs
    )
    raw["items"].append({"coverage_id": other, "item_type": "repair", "amount": "100"})
    assert _fields(_errs(raw, tables)) == ["items[1].coverage_id"]


def test_invalid_item_type_is_an_error(tables):
    raw = _valid(tables)
    raw["items"][0]["item_type"] = "bogus"
    assert _fields(_errs(raw, tables)) == ["items[0].item_type"]


@pytest.mark.parametrize(
    "value", ["0.001", "-5", "abc", "0", "10000000.01", "1e30", "NaN", True, None]
)
def test_bad_amounts_are_rejected(tables, value):
    raw = _valid(tables)
    raw["items"][0]["amount"] = value
    assert _fields(_errs(raw, tables)) == ["items[0].amount"]


@pytest.mark.parametrize(
    "value, cents",
    [("4200.50", 420050), (12.5, 1250), ("0.01", 1), (5, 500), ("10000000", 1_000_000_000)],
)
def test_good_amounts_become_integer_cents(tables, value, cents):
    raw = _valid(tables)
    raw["items"][0]["amount"] = value
    draft, errors = parse_and_validate(raw, tables)
    assert errors == []
    assert draft.items[0].cents == cents


def test_more_than_twenty_documents_is_an_error(tables):
    raw = _valid(tables)
    raw["documents"] = [{"doc_type": "photo", "received_date": "2026-10-10"}] * 21
    assert _fields(_errs(raw, tables)) == ["documents"]


def test_invalid_doc_type_is_an_error(tables):
    raw = _valid(tables)
    raw["documents"][0]["doc_type"] = "bogus"
    assert _fields(_errs(raw, tables)) == ["documents[0].doc_type"]


def test_invalid_doc_status_is_an_error(tables):
    raw = _valid(tables)
    raw["documents"][0]["status"] = "accepted"
    assert _fields(_errs(raw, tables)) == ["documents[0].status"]


def test_rejected_status_is_kept_and_duplicate_doc_types_are_allowed(tables):
    raw = _valid(tables)
    raw["documents"] = [
        {"doc_type": "photo", "received_date": "2026-10-10"},
        {"doc_type": "photo", "received_date": "2026-10-11", "status": "rejected"},
    ]
    draft, errors = parse_and_validate(raw, tables)
    assert errors == []
    assert [d.status for d in draft.documents] == ["received", "rejected"]


def test_invalid_json_gives_one_error_on_the_root(tables):
    draft, errors = parse_and_validate("{not json", tables)
    assert draft is None
    assert [e["field"] for e in errors] == ["$"]


def test_non_object_json_gives_one_error_on_the_root(tables):
    draft, errors = parse_and_validate("[]", tables)
    assert draft is None
    assert [e["field"] for e in errors] == ["$"]


def test_all_errors_are_collected_not_just_the_first(tables):
    raw = _valid(tables)
    raw["claim_type"] = "AUTO"
    raw["items"][0]["amount"] = "-1"
    raw["items"].append({"coverage_id": "COV-XXX-999", "item_type": "repair", "amount": "10"})
    raw["documents"][0]["doc_type"] = "bogus"
    assert _fields(_errs(raw, tables)) == [
        "claim_type",
        "items[0].amount",
        "items[1].coverage_id",
        "documents[0].doc_type",
    ]


# Workflow outcomes that validation must NOT reject: the rules engine decides them.


def test_incident_before_coverage_effective_date_is_accepted(tables):
    raw = _valid(tables)
    pc = _policy_coverage(tables, raw["policy_id"], raw["items"][0]["coverage_id"])
    raw["incident_date"] = (pc["effective_start"] - timedelta(days=1)).isoformat()
    raw["submission_date"] = pc["effective_start"].isoformat()
    raw["documents"][0]["received_date"] = raw["submission_date"]
    draft, errors = parse_and_validate(raw, tables)
    assert errors == [] and draft is not None


def test_incident_before_policy_start_is_accepted(tables):
    raw = _valid(tables)
    start = _policy(tables)["start_date"]
    raw["incident_date"] = (start - timedelta(days=10)).isoformat()
    raw["submission_date"] = (start + timedelta(days=5)).isoformat()
    raw["documents"][0]["received_date"] = raw["submission_date"]
    draft, errors = parse_and_validate(raw, tables)
    assert errors == [] and draft is not None


def test_incident_after_lapse_or_cancellation_is_accepted(tables):
    raw = _valid(tables)
    end = _policy(tables)["end_date"]
    raw["incident_date"] = (end + timedelta(days=1)).isoformat()
    raw["submission_date"] = (end + timedelta(days=2)).isoformat()
    raw["documents"][0]["received_date"] = raw["submission_date"]
    draft, errors = parse_and_validate(raw, tables)
    assert errors == [] and draft is not None


def test_submission_before_policy_start_is_accepted(tables):
    raw = _valid(tables)
    start = _policy(tables)["start_date"]
    raw["incident_date"] = (start - timedelta(days=2)).isoformat()
    raw["submission_date"] = (start - timedelta(days=1)).isoformat()
    raw["documents"][0]["received_date"] = raw["submission_date"]
    draft, errors = parse_and_validate(raw, tables)
    assert errors == [] and draft is not None


def test_excluded_item_type_is_accepted(tables):
    raw = _valid(tables)
    raw["items"][0]["item_type"] = "cosmetic"
    draft, errors = parse_and_validate(raw, tables)
    assert errors == [] and draft.items[0].item_type == "cosmetic"


def test_amount_over_the_policy_limit_is_accepted(tables):
    raw = _valid(tables)
    raw["items"][0]["amount"] = "9999999.99"
    draft, errors = parse_and_validate(raw, tables)
    assert errors == [] and draft.items[0].cents == 999_999_999


def test_amount_within_the_deductible_is_accepted(tables):
    raw = _valid(tables)
    raw["items"][0]["amount"] = "1.00"
    draft, errors = parse_and_validate(raw, tables)
    assert errors == [] and draft.items[0].cents == 100


def test_to_json_round_trips_to_an_equal_draft(tables):
    raw = _valid(tables)
    raw["items"].append(
        {"coverage_id": raw["items"][0]["coverage_id"], "item_type": "cosmetic", "amount": 12.5}
    )
    raw["documents"].append(
        {"doc_type": "invoice", "received_date": "2026-10-12", "status": "rejected"}
    )
    draft, errors = parse_and_validate(raw, tables)
    assert errors == []
    again, errors = parse_and_validate(draft.to_json(), tables)
    assert errors == [] and again == draft
    again_from_text, _ = parse_and_validate(draft.canonical(), tables)
    assert again_from_text == draft


# Hostile or odd input: never raises, always returns (None, errors) with {"field", "message"} entries.


def _text_errors(text, tables) -> list[dict]:
    draft, errors = parse_and_validate(text, tables)
    assert draft is None
    assert errors and all(set(e) == {"field", "message"} for e in errors)
    return errors


def test_integer_literal_over_the_digit_limit_is_one_root_error(tables):
    errors = _text_errors('{"policy_id": ' + "1" * 5000 + "}", tables)
    assert [e["field"] for e in errors] == ["$"]


def test_deeply_nested_json_is_one_root_error(tables):
    errors = _text_errors("[" * 100000, tables)
    assert [e["field"] for e in errors] == ["$"]


def test_json_text_over_the_size_cap_is_refused_before_parsing(tables):
    errors = _text_errors('"' + "a" * 60000 + '"', tables)
    assert errors == [{"field": "$", "message": "claim text is too long (max 50,000 characters)"}]


def test_long_string_inside_a_dict_gives_errors_not_a_crash(tables):
    raw = _valid(tables)
    raw["adjuster_note"] = "a" * 60000
    assert _fields(_errs(raw, tables)) == ["adjuster_note"]


def test_duplicate_keys_in_json_text_are_rejected(tables):
    errors = _text_errors(
        '{"policy_id": "POL-AUTO-2026-000001", "policy_id": "POL-AUTO-2026-000002"}', tables
    )
    assert [e["field"] for e in errors] == ["$"]
    assert "duplicate key" in errors[0]["message"]


def test_top_level_list_of_claims_is_one_root_error(tables):
    errors = _text_errors(json.dumps([_valid(tables)]), tables)
    assert errors == [{"field": "$", "message": "must be a JSON object"}]


def test_huge_integer_amount_in_a_dict_is_an_error(tables):
    raw = _valid(tables)
    raw["items"][0]["amount"] = 10**5000
    assert _fields(_errs(raw, tables)) == ["items[0].amount"]


def test_non_string_key_in_a_dict_is_an_error_not_a_crash(tables):
    raw = _valid(tables)
    raw[1] = "x"
    assert _fields(_errs(raw, tables)) == ["1"]


def test_twenty_five_items_give_one_count_error_and_skip_element_checks(tables):
    raw = _valid(tables)
    raw["items"] = [{"coverage_id": "X", "item_type": "bogus", "amount": "-1"}] * 25
    assert _fields(_errs(raw, tables)) == ["items"]


def test_twenty_five_documents_give_one_count_error_and_skip_element_checks(tables):
    raw = _valid(tables)
    raw["documents"] = [{"doc_type": "bogus", "received_date": "1800-01-01"}] * 25
    assert _fields(_errs(raw, tables)) == ["documents"]


@pytest.mark.parametrize(
    "field, value", [("submission_date", "0001-01-05"), ("incident_date", "1899-12-31")]
)
def test_date_before_1900_is_an_error(tables, field, value):
    raw = _valid(tables)
    raw[field] = value
    errors = _errs(raw, tables)
    assert _fields(errors) == [field]
    assert errors[0]["message"] == "date is before 1900-01-01"


def test_document_date_before_1900_is_an_error(tables):
    raw = _valid(tables)
    raw["documents"][0]["received_date"] = "0001-01-06"
    errors = _errs(raw, tables)
    assert _fields(errors) == ["documents[0].received_date"]
    assert errors[0]["message"] == "date is before 1900-01-01"


@pytest.mark.parametrize(
    "value", ["20261022", "2026-W43-4", "2026/10/22", "2026-1-5", "2026-10-22T00:00"]
)
def test_non_iso_date_strings_are_rejected(tables, value):
    raw = _valid(tables)
    raw["submission_date"] = value
    assert _fields(_errs(raw, tables)) == ["submission_date"]


@pytest.mark.parametrize("value", [datetime(2026, 10, 1), date(2026, 10, 1)])
def test_date_objects_inside_a_dict_are_rejected(tables, value):
    raw = _valid(tables)
    raw["incident_date"] = value
    errors = _errs(raw, tables)
    assert _fields(errors) == ["incident_date"]
    assert errors[0]["message"] == "must be an ISO date string YYYY-MM-DD"


def test_claim_with_dates_exactly_on_the_1900_bound_is_accepted(tables):
    raw = _valid(tables)
    raw["incident_date"] = "1900-01-01"
    raw["submission_date"] = "1900-01-01"
    raw["documents"][0]["received_date"] = "1900-01-01"
    draft, errors = parse_and_validate(raw, tables)
    assert errors == [] and draft is not None
