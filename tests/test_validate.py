import copy
from datetime import timedelta

import pytest

from claimsgen import config, validate

CATEGORIES = {
    "keys",
    "joins",
    "domain",
    "dates",
    "leakage",
    "arithmetic",
    "lifecycle",
    "duplicates",
}


def _fails(tables):
    return {c.name: c.ids for c in validate.run_all(tables) if c.failures}


@pytest.fixture
def tables(data):
    return copy.deepcopy(data)


def test_baseline_has_zero_failures_in_every_category(data):
    checks = validate.run_all(data)
    assert {c.category for c in checks} == CATEGORIES
    assert all(c.ok and c.checked > 0 for c in checks), [
        (c.name, c.failures[:3]) for c in checks if not c.ok
    ]
    s = validate.summary(checks)
    assert s["failed"] == 0 and s["failing_ids"] == 0 and s["rows_checked"] > 100_000


def test_duplicate_key_and_bad_id_format(tables):
    tables["customer"].append(dict(tables["customer"][0]))
    tables["customer"][1]["customer_id"] = "CUS-12"
    fails = _fails(tables)
    assert "primary key uniqueness" in fails and "ID format" in fails
    assert "CUS-12" in fails["ID format"]


def test_orphan_foreign_key_enum_and_missing_required(tables):
    tables["claim"][0]["policy_id"] = "POL-AUTO-2026-999999"
    tables["claim"][1]["claim_type"] = "PET"
    tables["claim"][2]["submission_date"] = None
    fails = _fails(tables)
    assert tables["claim"][0]["claim_id"] in fails["foreign key integrity"]
    assert tables["claim"][1]["claim_id"] in fails["enum values"]
    assert tables["claim"][2]["claim_id"] in fails["required fields present"]


def test_date_after_as_of_and_label_column(tables):
    tables["incident"][0]["incident_date"] = config.AS_OF + timedelta(days=1)
    tables["customer"][0]["is_fraud"] = "Y"
    fails = _fails(tables)
    assert tables["incident"][0]["incident_id"] in fails["event dates not after AS_OF"]
    assert "customer" in fails["no label or unexpected columns in input tables"]


def test_claim_total_mismatch(tables):
    tables["claim"][0]["claimed_amount"] += 100
    assert (
        tables["claim"][0]["claim_id"]
        in _fails(tables)["totals, payable, reserve and settlement reconcile"]
    )


def test_settlement_above_replayed_limit_is_flagged_alone(tables):
    s = tables["settlement"][0]
    s["recommended_amount"] += 5_000_000
    fails = _fails(tables)
    assert s["settlement_id"] in fails["totals, payable, reserve and settlement reconcile"]
    only_this = {i for ids in fails.values() for i in ids}
    assert only_this == {s["settlement_id"]}


def test_paid_twice_flags_only_the_second_settlement(tables):
    paid = next(s for s in tables["settlement"] if s["paid_date"])
    clone = dict(paid, settlement_id=paid["settlement_id"][:-3] + "002")
    tables["settlement"].append(clone)
    assert {i for ids in _fails(tables).values() for i in ids} == {clone["settlement_id"]}


def test_illegal_transition_and_payment_without_approval(tables):
    paid_event = next(e for e in tables["claim_status_history"] if e["to_status"] == "paid")
    paid_event["from_status"] = "assessed"
    assert (
        paid_event["claim_id"]
        in _fails(tables)["legal transitions, approval before payment, roles"]
    )


def test_wrong_approver_role(tables):
    s = next(s for s in tables["settlement"] if s["approved_date"])
    s["approver_role"] = "approver" if s["approver_role"] == "process_owner" else "process_owner"
    assert s["settlement_id"] in _fails(tables)["legal transitions, approval before payment, roles"]


def test_submission_before_start_is_only_allowed_when_denied_at_intake(tables):
    c = next(
        c
        for c in tables["claim"]
        if c["claim_id"]
        not in {e["claim_id"] for e in tables["claim_status_history"] if e["rule_id"] == "R-COV-01"}
    )
    p = next(p for p in tables["policy"] if p["policy_id"] == c["policy_id"])
    inc = next(i for i in tables["incident"] if i["incident_id"] == c["incident_id"])
    inc["incident_date"] = p["start_date"] - timedelta(days=3)
    assert c["claim_id"] in _fails(tables)["date order across the claim lifecycle"]


def test_unreferred_duplicate_is_flagged(tables):
    first = next(c for c in tables["claim"] if c["claim_id"])
    clone_inc = dict(
        next(i for i in tables["incident"] if i["incident_id"] == first["incident_id"])
    )
    clone_inc["incident_id"] = "INC-2026-900001"
    clone = dict(
        first,
        claim_id="CLM-2026-900001",
        incident_id="INC-2026-900001",
        submission_date=first["submission_date"] + timedelta(days=1),
    )
    tables["incident"].append(clone_inc)
    tables["claim"].append(clone)
    tables["claim_status_history"].append(
        {
            "event_id": "EVT-CLM-2026-900001-001",
            "claim_id": "CLM-2026-900001",
            "from_status": "",
            "to_status": "submitted",
            "event_date": clone["submission_date"],
            "actor_role": "requester",
            "rule_id": "",
            "reason_code": "submitted",
        }
    )
    tables["claim_adjuster_assignment"].append(
        {
            "assignment_id": "ASN-CLM-2026-900001-001",
            "claim_id": "CLM-2026-900001",
            "adjuster_id": tables["adjuster"][0]["adjuster_id"],
            "assigned_date": clone["submission_date"],
            "reason": "initial",
        }
    )
    tables["assessment"].append(
        {
            "assessment_id": "ASM-CLM-2026-900001-001",
            "claim_id": "CLM-2026-900001",
            "adjuster_id": tables["adjuster"][0]["adjuster_id"],
            "assessment_date": clone["submission_date"],
            "decision": "pend_docs",
            "rule_id": "R-DOC-01",
            "reason_code": "missing_document",
            "eligible_amount": 0,
            "deductible_applied": 0,
            "payable_amount": 0,
            "fraud_score": 0.0,
        }
    )
    assert (
        "CLM-2026-900001" in _fails(tables)["duplicate claims are referred; no duplicate documents"]
    )
