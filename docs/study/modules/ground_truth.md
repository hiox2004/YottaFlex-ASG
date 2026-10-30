# ground_truth (`src/claimsgen/ground_truth.py`)

**Purpose:** builds the separate answer key from planted baseline scenarios and injected cases.
**Brief items:** step 7 (separate ground truth, expected decisions and labels), review f.

- Columns: entity_id, entity_type, label, origin (baseline/injected), kind (business_outcome/integrity_defect/boundary), expected_decision, rule_id.
- `BASELINE` maps each planted scenario to its kind, rule and expected decision written from the documented rules, NOT copied from engine output, so the engine can be scored against it (precision/recall in the metrics step).
- `expected_decision` starts with a machine-readable word (`deny`, `refer_review`, `pend_docs`, `approve`, `covered`, `flag`; see `EXPECTED_WORDS`) followed by prose, so metrics can match on (word, rule_id) per label.
- Entity is a claim, except the two integrity defects which label the offending settlement row.
- `build(planted, injected, idmap)` translates provisional ids once through the finalize map and sorts rows by (entity_id, label).
- Never merged into input tables; a test checks inputs carry exactly their schema columns.
