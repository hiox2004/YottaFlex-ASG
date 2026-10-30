# checks_structure (`src/claimsgen/checks_structure.py`)

**Purpose:** structural validation: key uniqueness, ID formats, FK integrity, enum values, required fields, money type, event dates not after AS_OF, label or unexpected columns in input tables (checked on the actual row keys).
**Brief items:** step 8 (PK, FK, enums), review b (IDs and joins) and f (no leakage).

| Item | What it does | Gotcha |
|---|---|---|
| `Check` | one validation check: category, name, rows checked, failures `(id, why)` | failures are keyed by the row id so they can be compared with ground_truth later |
| `row_id` | row id; ground_truth uses `entity_id:label` | |
| `structure_checks(t)` | returns 8 checks | works on any subset of tables present |
| `DATE_FIELDS` | event/transaction dates checked against AS_OF | term end dates (`end_date`, `effective_*`) are exempt because in-force policies end after AS_OF |

## Tests
`tests/test_validate.py` corrupts a copy of the data (duplicate key, bad id, orphan FK, bad enum, missing value, future date, label column) and checks each is caught on the right row.
