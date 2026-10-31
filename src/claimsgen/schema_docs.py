"""Render the data dictionary and SQL schema from schema.TABLES. Run: python -m claimsgen.schema_docs"""

import sys
from pathlib import Path

from claimsgen import rules
from claimsgen.schema import _SQL_TYPE, TABLE_BY_NAME, TABLES

# (child table, fk column) -> (cardinality parent:child, note). The FK list itself comes from TABLES.
_CARDINALITY = {
    ("policy", "customer_id"): ("1:N", "a customer holds many policies"),
    ("policy_event", "policy_id"): ("1:N", "append-only; the first event is `issued`"),
    ("policy_coverage", "policy_id"): (
        "1:N",
        "with coverage_id this is the N:M bridge policy-coverage",
    ),
    ("policy_coverage", "coverage_id"): ("1:N", "limit and deductible live on the bridge row"),
    ("incident", "policy_id"): ("1:N", "a policy can have several incidents"),
    ("claim", "policy_id"): ("1:N", "claim_type equals the policy product"),
    ("claim", "incident_id"): ("1:N", "one claim per incident; more only for duplicate claims"),
    ("claim_item", "claim_id"): ("1:N", "claimed_amount of the claim = sum of its items"),
    ("claim_item", "coverage_id"): ("1:N", "each item is paid under one coverage"),
    ("document", "claim_id"): ("1:N", "metadata only; 0 rows allowed (missing documents)"),
    ("claim_adjuster_assignment", "claim_id"): ("1:N", "reassignment is a new row"),
    ("claim_adjuster_assignment", "adjuster_id"): ("1:N", "with claim_id: N:M claim-adjuster"),
    ("assessment", "claim_id"): ("1:N", "a re-run adds a row; the latest decides"),
    ("assessment", "adjuster_id"): ("1:N", "the adjuster who assessed"),
    ("reserve", "claim_id"): ("1:N", "FNOL row, then revised rows"),
    ("settlement", "claim_id"): (
        "0..1:1",
        "none before a decision; 2 only for the paid_twice defect",
    ),
    ("claim_status_history", "claim_id"): ("1:N", "append-only; status = last event"),
}
# Optional link: a parent may have no child rows
_OPTIONAL_CHILD = {"document", "settlement", "policy_event", "reserve", "assessment"}
_EFFECTIVE = {
    "policy": "start_date .. end_date",
    "policy_coverage": "effective_start .. effective_end",
    "policy_event": "event_date",
    "claim": "submission_date",
    "incident": "incident_date",
}


def render_relationships_md() -> str:
    out = [
        "## Relationships and lifecycle",
        "",
        "Generated from the FK declarations in `schema.TABLES`, `rules.TRANSITIONS` and `ids.py`.",
        "",
        "### Foreign keys and cardinality",
        "Cardinality is parent:child. An FK column that is required (`Y`) is never null.",
        "",
        "| Child | FK column | Parent | Cardinality | FK required | Parent may have no child | Note |",
        "|---|---|---|---|---|---|---|",
    ]
    for t in TABLES:
        for f in t.fields:
            if not f.fk:
                continue
            card, note = _CARDINALITY[(t.name, f.name)]
            opt = "Y" if t.name in _OPTIONAL_CHILD else "N"
            out.append(
                f"| {t.name} | {f.name} | {f.fk} | {card} | {'Y' if f.required else 'N'} | {opt} "
                f"| {note} |"
            )
    out += [
        "",
        (
            "`ground_truth.entity_id` is deliberately not a foreign key: it points at any entity by id "
            "and is never joined into the input tables."
        ),
        "",
        "### Effective dates",
        "| Table | Date column(s) |",
        "|---|---|",
    ]
    out += [f"| {k} | {v} |" for k, v in _EFFECTIVE.items()]
    out += [
        "",
        (
            "Coverage is checked at the incident date: the policy window, "
            "the policy_coverage window, and no earlier `lapsed` or `cancelled` event (R-COV-01..03)."
        ),
        "",
        "### Claim status lifecycle",
        "Legal transitions (`rules.TRANSITIONS`); the first event has an empty from_status.",
        "",
        "| From | To (allowed) |",
        "|---|---|",
    ]
    for src, dst in rules.TRANSITIONS.items():
        out.append(f"| {src or '(none)'} | {', '.join(sorted(dst)) or '(terminal)'} |")
    out += [
        "",
        (
            "Other lifecycles: policy events `issued`, then `lapsed`, `cancelled` or `expired`; reserve "
            "basis `preliminary` (FNOL, R-RSV-01) then `revised` (R-RSV-02); settlement stage is which "
            "dates are filled (recommended, approved, paid)."
        ),
        "",
        "### ID formats",
        "| Entity | Format |",
        "|---|---|",
    ]
    out += [f"| {t.name} | `{t.pk_pattern.replace('|', chr(92) + '|')}` |" for t in TABLES]
    out += [
        "",
        (
            "The policy serial is one counter shared by all products: `POL-HOME-2026-000004` can be the "
            "first HOME policy. `2026` is the series year, not a date; policy dates run 2024-2026. Child "
            "ids carry the parent id and a 3-digit sequence."
        ),
        "",
    ]
    return "\n".join(out)


def render_dictionary_md() -> str:
    out = [
        "# Data dictionary",
        "",
        "Generated from `src/claimsgen/schema.py`; do not edit by hand.",
        "Dates are ISO `YYYY-MM-DD`; money is USD with 2 decimals.",
        "",
    ]
    for t in TABLES:
        out += [
            f"## {t.name}",
            f"{t.description}. PK `{t.pk}` pattern `{t.pk_pattern}`.",
            "",
            "| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |",
            "|---|---|---|---|---|---|---|---|",
        ]
        for f in t.fields:
            allowed = f.allowed.replace("|", "\\|")
            out.append(
                f"| {f.name} | {f.type} | {'Y' if f.required else 'N'} | {allowed} | {f.unit} "
                f"| {'Y' if f.unique else 'N'} | {f.fk} | {f.rule} |"
            )
        out.append("")
    return "\n".join(out) + "\n" + render_relationships_md()


def render_ddl(names: set | None = None) -> str:
    out = ["-- Generated from src/claimsgen/schema.py; do not edit by hand."]
    for t in (t for t in TABLES if names is None or t.name in names):
        cols = [
            f"  {f.name} {_SQL_TYPE[f.type]}{' NOT NULL' if f.required else ''}" for f in t.fields
        ]
        if t.name != "ground_truth":
            cols.append(f"  PRIMARY KEY ({t.pk})")
        cols += [
            f"  FOREIGN KEY ({f.name}) REFERENCES {f.fk}({TABLE_BY_NAME[f.fk].pk})"
            for f in t.fields
            if f.fk
        ]
        out.append(f"CREATE TABLE {t.name} (\n" + ",\n".join(cols) + "\n);")
    return "\n".join(out) + "\n"


def main() -> int:
    docs = Path(__file__).resolve().parents[2] / "docs"
    (docs / "DATA_DICTIONARY.md").write_text(render_dictionary_md(), encoding="utf-8", newline="\n")
    (docs / "schema.sql").write_text(render_ddl(), encoding="utf-8", newline="\n")
    print(f"wrote {len(TABLES)} tables to docs/DATA_DICTIONARY.md and docs/schema.sql")
    return 0


if __name__ == "__main__":
    sys.exit(main())
