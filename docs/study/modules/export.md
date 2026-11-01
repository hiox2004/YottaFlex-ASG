# export (`src/claimsgen/export.py`)

**Purpose:** serialises the dataset to CSV, JSON and SQL with byte-stable formatting.
**Brief items:** step 9 / deliverable 9 (CSV, JSON, SQL seed), step 10 (checksums must match across runs), review f (ground_truth separate), g.

| Rule | Why |
|---|---|
| rows keep dataset order, never re-sorted by key | injected rows must not be revealed by position; same order every run |
| columns follow the schema field order | stable headers and JSON keys |
| money = exact `dollars.cents` text from integer cents; ratio = fixed 2 decimals; dates ISO | no float formatting, so SHA-256 is stable |
| LF line endings, UTF-8, bytes written with `lineterminator="
"` for csv | identical bytes on Windows and Linux |
| `ground_truth` goes only to `ground_truth.csv|json|sql` at the top level | never mixed into input tables |

| Function | Role |
|---|---|
| `text(field, value)` | canonical text for a value (`None` stays `None`: empty in CSV, `null` in JSON, `NULL` in SQL) |
| `write_tables(out, tables, ground_truth)` | writes `csv/`, `json/`, `seed.sql`, ground_truth files; returns `{path: (rows, sha256)}` |

`seed.sql` has the DDL for the 16 input tables (parent-first) plus INSERTs in one transaction; load with `PRAGMA foreign_keys=ON`.
Checksums are taken on text files (the SQL text, not a `.db`, which is not byte-stable).

## Tests
`tests/test_export.py`: layout, CSV/JSON order and headers, decimal text, SQL loads with foreign keys, no label columns, checksums, byte-identical rebuild.
