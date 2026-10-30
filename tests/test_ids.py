import re

from claimsgen import ids, schema

CLAIM = ids.clm(1)
POLICY = ids.pol("AUTO", 1)


def _pattern(table: str) -> str:
    return next(f for f in schema.TABLE_BY_NAME[table].fields if f.unique).allowed


def test_every_formatter_matches_its_schema_pattern():
    samples = {
        "customer": ids.cus(1),
        "policy": POLICY,
        "coverage": ids.cov("HOME", 2),
        "adjuster": ids.adj(7),
        "document_requirement": ids.drq("AUTO", "police_report"),
        "policy_event": ids.pev(POLICY, 1),
        "policy_coverage": ids.pcv(POLICY, 3),
        "incident": ids.inc(9),
        "claim": CLAIM,
        "claim_item": ids.itm(CLAIM, 1),
        "document": ids.doc(CLAIM, 1),
        "claim_adjuster_assignment": ids.asn(CLAIM, 1),
        "assessment": ids.asm(CLAIM, 1),
        "reserve": ids.rsv(CLAIM, 1),
        "settlement": ids.settlement(CLAIM, 1),
        "claim_status_history": ids.evt(CLAIM, 1),
    }
    for table, value in samples.items():
        assert re.match(_pattern(table), value), (table, value)


def test_brief_examples_are_exact():
    assert ids.pol("AUTO", 1) == "POL-AUTO-2026-000001"
    assert ids.doc(ids.clm(1), 1) == "DOC-CLM-2026-000001-001"
    assert ids.settlement(ids.clm(12), 2) == "SET-CLM-2026-000012-002"
