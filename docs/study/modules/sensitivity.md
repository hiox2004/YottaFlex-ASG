# sensitivity (`src/claimsgen/sensitivity.py`)

**Purpose:** show the trade-off behind the two thresholds (IMP-008): re-run the engine while sweeping one threshold at a time.
**Brief items:** "meaningful evaluation metrics"; shown as the "Threshold sensitivity" section of `metrics.md`.

`sweep(tables, ground_truth) -> dict`:
- Drops the engine output tables (assignment, assessment, reserve, settlement, status history) and calls `engine.run` on the inputs.
- Patches `config.APPROVER_THRESHOLD_CENTS` over 500,000 / 1,000,000 / 2,000,000 / 5,000,000 cents, then `config.FRAUD_THRESHOLD` over 0.25 / 0.5 / 0.75 / 1.0. The original values are restored in a `finally` block.
- Deterministic: the engine is seeded and nothing reads the clock.

Result: `{"current": {"approver_threshold_cents", "fraud_threshold"}, "approver": [row...], "fraud": [row...]}`. Each row:
`value`, `current` (bool, the live setting), `fraud_referred` (claims with an R-FRD-05 assessment), `flagged_amount_cents` (their claimed total), `approver_settlements` and `approver_amount_cents` (settlements whose recommended amount is above the swept approver threshold), `precision` and `recall` (suspected_fraud vs ground_truth via `scoring.predictions` with no validator checks; `None` in the approver sweep).

Note: the sweep re-runs the clean engine, so approver counts exclude defect rows injected into the dataset's settlement table (e.g. the duplicate settlement); fraud numbers match the dataset exactly.

Reading it: a higher approver threshold sends fewer settlements to the approver; a higher fraud cutoff refers fewer claims, so flagged amount and review workload fall while precision usually rises and recall falls.

## Tests
`tests/test_sensitivity.py`: deterministic, config restored (also after an error), current row equals the live numbers, both monotonicity directions.
