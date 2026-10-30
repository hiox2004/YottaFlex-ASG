# YottaFlex-ASG

A working claims workflow plus its test bed. A rules engine takes insurance claims through intake, coverage validation,
document request, eligibility and settlement routing, with a rule ID, a reason and an append-only history behind every
decision. A deterministic generator produces the 11-entity dataset (2,000 policies, 1,000 claims, 5 claim types) with six
labelled edge cases and a separate answer key, so the workflow can be checked end to end. A minimal view exposes the
decisions, exceptions, per-claim timeline and metrics.

All data is fully synthetic ([SOURCE_MANIFEST.md](SOURCE_MANIFEST.md)). Scope and decisions: [docs/SPEC.md](docs/SPEC.md),
[docs/DESIGN.md](docs/DESIGN.md), [docs/BRIEF_VS_PLAN.md](docs/BRIEF_VS_PLAN.md).

## Five-minute tour
```
pip install -e ".[dev,ui]"
pytest -q                                   # tests incl. a headless run of the app
python scripts/verify.py                    # builds twice, compares every file (rows + SHA-256)
streamlit run app.py                        # the view
```
1. Open `output/starter/` (small, committed): `README.md`, `validation_summary.md`, `metrics.md`, `ground_truth.csv`.
2. Run the view. Tabs: Decisions (rule, reason, actor per claim), Exceptions, Claim timeline (append-only history, a rule trace showing where a claim stopped and why, and what would make it payable), Metrics (rates, cycle times, amounts blocked, money effect by rule, touchless rate, approver workload, docs-pending aging, reserve vs final, threshold sensitivity, precision/recall), Realism (distributions) and Reproducibility (fixed seed, dataset checksum, rebuild-and-compare).
3. Regenerate anything with the command below; the same seed always gives byte-identical files.

## Generate data
```
python -m claimsgen build --scale 1.0 --out output/full      # 2,000 policies / 1,000 claims (gitignored)
python -m claimsgen build --scale 0.05 --out output/starter  # starter: 100 policies / 50 claims (committed)
python -m claimsgen all --out output                          # both
```
Seed fixed at 20261022, "today" fixed at 2026-10-22 (never the system clock), currency USD. Each package contains CSV and
JSON for the 16 input tables, `seed.sql` (SQLite, foreign keys), `ground_truth.*` (separate answer key), data dictionary,
schema, validation summary, metrics, manifest and checksums. The exit code is non-zero if validation does not flag exactly
the planted defects or a same-seed rerun differs.

## How the workflow decides
Decision order (first failing step ends the path): coverage (R-COV-01 claim after start, R-COV-02 policy in force,
R-COV-03 incident inside coverage dates) -> duplicate (R-ELG-03) -> documents (R-DOC-01, pend until received) ->
fraud flags (R-FRD-05, score >= 0.5 goes to review) -> exclusions (R-ELG-02) -> payable per coverage
(R-PAY-01: eligible minus deductible, capped at the remaining limit) -> reserve (R-RSV-01) -> approval authority
(R-APR-01: above 10,000 USD needs the approver). Every state change is a new row in `claim_status_history` with actor role,
rule ID and reason. The catalogue is `src/claimsgen/rules.py`.

## Where to verify the review points
| Point | Evidence |
|---|---|
| a. Distributions | `validation_summary.md` distributions section; `tests/test_claims.py` |
| b. IDs and joins | `tests/test_ids.py`; validation checks (ID format, foreign keys) |
| c. Lifecycle | validation date-order and lifecycle checks; `rules.TRANSITIONS` |
| d. Derived values | validation arithmetic replay (`checks_business.py`) |
| e. Normal, boundary, failure, exception | six injected cases and four boundary cases, counted in `validation_summary.md`; `tests/test_inject.py` |
| f. Ground truth separate | `ground_truth.*` at the top level; inputs carry schema columns only (`tests/test_inject.py`, leakage check) |
| g. Reproducibility and provenance | `python scripts/verify.py`; reproducibility table in `validation_summary.md`; `checksums.sha256`; SOURCE_MANIFEST.md |

Evaluation metrics (outcome rates, cycle times, amounts blocked, reserve vs final, precision/recall of the engine and the
validator against the answer key) are in each package's `metrics.md` and the view's Metrics tab.

## Assumptions we made explicit
- Product codes AUTO, HOME, HLTH, TRVL, LIAB, one per claim type. `ASN` is read as the adjuster assignment record;
  Assessment is `ASM-...`. `DOC-<claim-id>-001` is literal: `DOC-CLM-2026-000001-001`.
- Claim date means submission date; the incident date is separate. The 1,000 claims include duplicates and anomalies.
- Injected rows are 15 per case at full scale (within the 10-30 target); the starter has 2 per case.
- Baseline conditions (lapsed, outside coverage, incomplete evidence, over limit, fraud indicators, duplicates) are produced
  by the rules and labelled `origin=baseline`; the six mandatory cases are `origin=injected`.

## Known limits (stated, not hidden)
- The validator replays derived amounts through the same `rules.payable` function the engine uses: it is an independent
  replay of the inputs, not an independent implementation of the formula.
- Very recent claims are honestly left in an earlier status when the next step would fall after the as-of date, and count as
  misses in recall. `claim_over_limit` precision is below 1 because organic claims also exhaust a limit.
- `under_review` is terminal in this dataset, and reserves are not revised in the baseline.
- The `SET-...-002` second payment is an unavoidable marker of the paid-twice case.
- The optional LLM extension is not built; the dataset and workflow are fully deterministic.
- The approver threshold (10,000 USD), fraud cutoff (score 0.5), the 30/90/60-day fraud windows and the document window (5 days) are hand-chosen constants in `src/claimsgen/config.py`, not fitted to data.
- There is no reopen or appeal flow: `denied` and `under_review` claims are final in this dataset.
- The four fraud flags (early claim, repeated claims, amount near the limit, late reporting) are simple heuristics, combined as flags divided by 4, not a trained model.

## AI use and prompt history
`ai-transparency/` records which AI tools and models were used, where they helped, what was verified, and the limits of that record;
`ai-transparency/prompt-history/` holds the prompts (generated by `python scripts/export_prompts.py`, redacted for paths, e-mails and tokens).

## Repository map
`src/claimsgen/` generator, rules engine, validation, injection, export, metrics, view data · `app.py` the view ·
`scripts/` verify and helpers · `tests/` · `docs/` spec, design, data dictionary, schema · `docs/study/` a living study
guide (one note per module, glossary, an end-to-end claim walk-through, change log) · `CONTRIBUTING.md` commit format.
