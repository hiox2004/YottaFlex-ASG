# dataset_docs (`src/claimsgen/dataset_docs.py`)

**Purpose:** writes the documentation that travels with a dataset: `validation_summary.md`, `manifest.json`, `README.md`, copies of the data dictionary, schema and source manifest, and `checksums.sha256`.
**Brief items:** step 9 (README, schema, generator command, seed, source manifest, validation summary), step 8 (report), step 10 (reproducibility result saved in the summary), review a (distribution summary) and e (each case counted).

| Section of validation_summary.md | Content |
|---|---|
| validation checks | the 12 checks with rows checked and failures |
| integrity defects | defect rows in ground_truth vs ids flagged by the validator, exact match |
| edge cases | label, origin, kind and count for every planted case |
| distributions | claimed-amount median/mean/p90/max, claim-type mix, policy status, final claim status |
| reproducibility | two same-seed builds: row counts and SHA-256 per file, run 1 vs run 2 |

`write_docs` returns `ok` = validator flags exactly the defects AND the two runs are identical. The manifest stores the command with `<DIR>` (not the real path) so two builds into different folders stay byte-identical.
Source docs are copied from `docs/` so there is one source of truth.

## Tests
`tests/test_export.py` (summary headings, checksums, manifest fields, byte-identical rebuild).
