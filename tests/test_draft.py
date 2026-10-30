from datetime import date

from claimsgen import config
from claimsgen.draft import Doc, Draft, Item


def _draft(cents=420000):
    return Draft(
        "POL-AUTO-2026-000123",
        date(2026, 6, 10),
        "collision",
        date(2026, 6, 12),
        (Item("COV-AUTO-001", "repair", cents),),
        (Doc("photo", date(2026, 6, 12)),),
    )


def test_to_json_uses_exact_decimal_text_and_no_claim_type():
    j = _draft(420005).to_json()
    assert j["items"][0]["amount"] == "4200.05" and "claim_type" not in j
    assert j["documents"][0] == {
        "doc_type": "photo",
        "received_date": "2026-06-12",
        "status": "received",
    }


def test_canonical_is_stable_and_distinguishes_drafts():
    assert _draft().canonical() == _draft().canonical()
    assert _draft(100).canonical() != _draft(200).canonical()


def test_intake_horizon_is_after_the_dataset_date():
    assert config.intake_horizon() > config.AS_OF
