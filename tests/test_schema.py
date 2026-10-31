import re
import sqlite3
from pathlib import Path

from claimsgen import rules, schema, schema_docs

DOCS = Path(__file__).resolve().parents[1] / "docs"
LEAK = {"label", "origin", "kind", "expected_decision", "is_fraud", "anomaly_type", "issue_type"}


def test_seventeen_tables_unique_names():
    names = [t.name for t in schema.TABLES]
    assert len(names) == len(set(names)) == 17


def test_every_table_has_pk_field_and_fks_resolve_to_earlier_tables():
    seen: set[str] = set()
    for t in schema.TABLES:
        assert t.pk in {f.name for f in t.fields}, t.name
        for f in t.fields:
            if f.fk:
                assert f.fk in seen, f"{t.name}.{f.name} -> {f.fk} not generated earlier"
        seen.add(t.name)


def test_pk_patterns_compile_and_match_examples():
    examples = {
        "customer": "CUS-000001",
        "policy": "POL-AUTO-2026-000001",
        "claim": "CLM-2026-000001",
        "document": "DOC-CLM-2026-000001-001",
        "claim_adjuster_assignment": "ASN-CLM-2026-000001-001",
        "settlement": "SET-CLM-2026-000001-001",
    }
    for table, ident in examples.items():
        pk = next(f for f in schema.TABLE_BY_NAME[table].fields if f.unique)
        assert re.match(pk.allowed, ident), (table, ident)


def test_no_label_columns_in_input_tables():
    for t in schema.TABLES:
        if t.name != "ground_truth":
            assert not LEAK & {f.name for f in t.fields}, t.name


def test_ddl_is_valid_sqlite():
    sqlite3.connect(":memory:").executescript(schema_docs.render_ddl())


def test_generated_docs_are_current():
    assert (DOCS / "DATA_DICTIONARY.md").read_text(
        encoding="utf-8"
    ) == schema_docs.render_dictionary_md()
    assert (DOCS / "schema.sql").read_text(encoding="utf-8") == schema_docs.render_ddl()


def test_relationships_section_covers_every_fk_and_transition():
    md = schema_docs.render_relationships_md()
    for t in schema.TABLES:
        for f in t.fields:
            if f.fk:
                assert f"| {t.name} | {f.name} | {f.fk} |" in md, (t.name, f.name)
        assert t.pk_pattern.replace("|", r"\|") in md
    for dst in rules.TRANSITIONS.values():
        for to in dst:
            assert to in md
