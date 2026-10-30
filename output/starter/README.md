# Claims dataset (scale 0.05, seed 20261022)

Fully synthetic insurance claims data (see SOURCE_MANIFEST.md). Regenerate with `python -m claimsgen build --scale 0.05 --out <DIR>`.

- `csv/`, `json/`: the 16 input and event tables (same rows, same columns, parent-first order in `seed.sql`).
- `seed.sql`: SQLite DDL plus INSERTs for those tables (`PRAGMA foreign_keys=ON`). `schema.sql`: DDL for all tables including ground_truth.
- `ground_truth.csv|json|sql`: the separate answer key (labels, origin, kind, expected decision, rule). Never join it into inputs.
- `DATA_DICTIONARY.md`: every field with type, required, allowed values, unit, uniqueness, rule.
- `validation_summary.md`: checks, row counts, injected cases, distributions and the same-seed reproducibility proof.
- `metrics.md`: operational metrics (outcome rates, cycle times, amounts blocked, reserve vs final) and precision/recall of the engine and validator vs ground_truth.
- `manifest.json`, `checksums.sha256`: seed, scale, as-of date and SHA-256 of every file.

Money is USD with two decimals. Dates are ISO. All "today" logic uses AS_OF 2026-10-22, never the system clock.
Joins: claim.policy_id -> policy, claim.incident_id -> incident, claim_item/document/assessment/reserve/settlement/claim_status_history/claim_adjuster_assignment .claim_id -> claim.
