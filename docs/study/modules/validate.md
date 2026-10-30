# validate (`src/claimsgen/validate.py`)

**Purpose:** runs all checks and renders the report. Baseline must show zero failures; after injection the set of failing ids must equal the integrity-defect ids in ground_truth.
**Brief items:** deliverable 8 (validation report), pitfall list (non-zero exit on baseline failure comes with the CLI/export step).

| Function | Role |
|---|---|
| `run_all(tables)` | structure + business checks (12 on the baseline) |
| structural gate | business checks are skipped (and reported as a failing `business-checks-skipped` check) if keys, joins, required fields or enums fail | prevents crashes on malformed input |
| `failing_ids(checks)` | union of failing ids (compared with ground_truth after injection) |
| `summary(checks)` | counts: checks, passed, failed, rows checked, failing ids |
| `to_markdown(checks, row_counts)` | the report table plus up to 25 failures per failed check |

Distribution summaries and precision/recall come from the metrics step.
