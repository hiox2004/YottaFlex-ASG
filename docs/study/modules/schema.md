# schema (`src/claimsgen/schema.py`)

**Purpose:** one place that defines every table, field, enum and ID pattern. Docs and SQL are rendered from it by `schema_docs.py`; enums come from `vocab.py`.
**Pipeline stage:** before step 1 (everything else reads it). Deliverable 1 (data dictionary), 3 (ID formats), part of 9 (schema).
**Brief items served:** step 1 dictionary; review b (IDs/joins) and f (no leakage, since only `ground_truth` has label fields).

## Inputs and outputs
- Takes: nothing (pure declarations).
- Produces: `TABLES` (17, parents first), enum tuples (`PRODUCTS`, `CLAIM_STATUSES`, `LABELS`...), `docs/DATA_DICTIONARY.md`, `docs/schema.sql`.

## Key items
| Item | What it does | Gotcha |
|---|---|---|
| `Field` / `Table` | Frozen dataclasses describing one column / one table | `fk` names the referenced table; `unique` marks the PK |
| helper `_pk/_fk/_enum/_date/_money/_text/_int` | Short constructors so the spec stays readable | Money is `NUMERIC` in SQL but integer cents inside the generator |
| `TABLES` | Order = generation order, so FKs always point to earlier tables | A test enforces this |
| `TABLE_BY_NAME`, `_SQL_TYPE` | Lookup by name; field type -> SQLite type | used by `schema_docs.py` |

After any spec change run `python -m claimsgen.schema_docs`, or `test_generated_docs_are_current` fails.
`ground_truth` has no PK/FK on purpose (polymorphic entity_id).

## Invariants
- No label/answer fields in input tables (test checks a leak-word list).
- PK patterns match the five brief formats exactly (`DOC-CLM-2026-000001-001` etc.).

## Worked example
`claim.policy_id` is `_fk("policy_id","policy")` -> dictionary row "must exist in policy" and DDL `FOREIGN KEY (policy_id) REFERENCES policy(policy_id)`.

## How to test / inspect
`pytest tests/test_schema.py`; open `docs/DATA_DICTIONARY.md`.

## Open questions / next
Allowed enum lists (incident/item/doc types) may be tuned when the generator needs them.
