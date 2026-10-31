# schema_docs (`src/claimsgen/schema_docs.py`)

**Purpose:** renders `docs/DATA_DICTIONARY.md` and `docs/schema.sql` from `schema.TABLES`.
**Pipeline stage:** tooling for deliverables 1 and 9 (dictionary, schema).

## Key functions
| Function | What it does | Gotcha |
|---|---|---|
| `render_dictionary_md()` | One markdown table per entity: type, required, allowed, unit, unique, FK, rule | escapes `\|` in enum lists |
| `render_relationships_md()` | Appended to the dictionary: FK cardinality table, effective dates, claim status transitions, ID formats | cardinality and notes live in `_CARDINALITY`, keyed by (table, fk column); a new FK without an entry raises KeyError, which keeps the section complete |
| `render_ddl()` | SQLite `CREATE TABLE` with PK and FK | `ground_truth` has no PK/FK (polymorphic entity_id) |
| `main()` | writes both files; run `python -m claimsgen.schema_docs` | `test_generated_docs_are_current` fails if the committed files are stale |

## How to test
`pytest tests/test_schema.py` (DDL loads in in-memory SQLite; files match the renderers).
