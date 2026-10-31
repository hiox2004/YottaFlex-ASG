# YottaFlex-ASG

A working claims workflow plus its test bed. A rules engine takes insurance claims through intake, coverage validation,
document request, eligibility and settlement routing, with a rule ID, a reason and an append-only history behind every
decision. A deterministic generator produces the dataset (11 core entities plus five event and link tables make 16 input tables, and a separate ground-truth table makes 17; 2,000 policies, 1,000 claims, 5 claim types) with six
labelled edge cases and a separate answer key, so the workflow can be checked end to end. A minimal view exposes the
decisions, exceptions, per-claim timeline and metrics.

All data is fully synthetic ([SOURCE_MANIFEST.md](SOURCE_MANIFEST.md)). Scope and decisions: [docs/SPEC.md](docs/SPEC.md),
[docs/DESIGN.md](docs/DESIGN.md), [docs/BRIEF_VS_PLAN.md](docs/BRIEF_VS_PLAN.md).

## Results at a glance

Full scale (seed 20261022, 2,000 policies, 1,000 claims, 23,545 rows in the 16 input tables; derived from a fresh build and `metrics.md`):

- **Outcomes:** 71.3% approved, 14.3% denied, 4.0% waiting for documents, 6.4% under review, 4.0% not yet assessed at the as-of date.
- **Proof:** validation flags exactly the 30 planted defects (4 in the starter), a same-seed rebuild is byte-identical, and `pytest -q` runs 315 tests.
- **Workflow:** 70.3% of assessed claims are straight-through (no pend, no review); 30 claims (3.0%) are referred as suspected fraud; 11.9% of approved settlements need the approver.
- **Honest misses:** recall is 0.90 to 0.97 for lapsed policy, outside coverage period, duplicate, incomplete evidence and boundary-on-start (recent claims are not assessed yet); `claim_over_limit` precision is 0.81. Fraud scores 1.00 only because its labels are planted ([why](docs/DESIGN.md)).

## Five-minute tour

```
git clone https://github.com/hiox2004/YottaFlex-ASG && cd YottaFlex-ASG
python -m venv .venv                           # create it once
# then activate it:
#   macOS/Linux:        . .venv/bin/activate
#   Windows PowerShell: .\.venv\Scripts\Activate.ps1   (if scripts are blocked: Set-ExecutionPolicy -Scope Process Bypass)
#   Windows cmd:        .venv\Scripts\activate.bat
pip install -e ".[dev,ui]"                     # needs Python 3.11+ (CI uses 3.12)
pytest -q                                   # tests incl. a headless run of the app
python scripts/verify.py                    # builds twice, compares every file (rows + SHA-256)
streamlit run app.py                        # the view
```

1. Open `output/starter/` (small, committed): `README.md`, `validation_summary.md`, `metrics.md`, `ground_truth.csv`.
2. Run the view. Tabs: Submit a claim (fill in a form or load one of seven examples, watch the whole workflow decide it, request missing documents; template in [docs/CLAIM_INPUT.md](docs/CLAIM_INPUT.md)), Decisions (rule, reason, actor per claim), Exceptions, Claim timeline (append-only history, a rule trace showing where a claim stopped and why, and what would make it payable), Metrics (rates, cycle times, amounts blocked, money effect by rule, straight-through (no exception) rate, approver workload, docs-pending aging, reserve vs final, threshold sensitivity, precision/recall), Realism (distributions) and Reproducibility (fixed seed, dataset checksum, rebuild-and-compare) and Quality and data (validation checks, planted defects vs flagged, answer key, data dictionary, rule catalogue, table browser).
3. Regenerate anything with the command below; the same seed always gives byte-identical files.

## Run it in a container (no Python setup)

```
docker build -t yottaflex-asg .
docker run --rm -p 8501:8501 yottaflex-asg                 # the view at http://localhost:8501
docker run --rm yottaflex-asg pytest -q                    # the tests
docker run --rm yottaflex-asg python scripts/verify.py     # the reproducibility proof
```

CI builds this image on every push, runs the proof inside it and checks that the view serves. The image installs the optional extras
(Streamlit and the test tools), so it is larger than the core, which has no third-party runtime dependencies. There is no hosted demo: the
project runs locally or in this container, and the starter dataset and its reports are committed in `output/starter/`.

## Generate data

```
python -m claimsgen build --scale 1.0 --out output/full      # 2,000 policies / 1,000 claims (gitignored)
python -m claimsgen build --scale 0.05 --out output/starter  # starter: 100 policies / 50 claims (committed)
python -m claimsgen all --out output                          # both
```

Supported scales: 0.05 (the starter) or 0.075 to 5.0. Anything else is refused with a one-line error (exit code 2): below that range the injected test cases cannot be placed (0.051, 0.055 and 0.07 fail too), and above it the build gets slow.

Lightweight path: the generator, engine, validation and metrics have no third-party runtime dependencies (`pip install -e .` is enough; the Streamlit view and the tests are optional extras `ui` and `dev`), so everything above runs without the UI.

Seed fixed at 20261022, "today" fixed at 2026-10-22 (never the system clock), currency USD. Each package contains CSV and
JSON for the 16 input tables, `seed.sql` (SQLite, foreign keys), `ground_truth.*` (separate answer key), data dictionary,
schema, validation summary, metrics, manifest and checksums. The exit code is non-zero if validation does not flag exactly
the planted defects or a same-seed rerun differs.

## How the workflow decides

Decision order (first failing step ends the path): coverage (R-COV-01 claim after start, R-COV-02 policy in force,
R-COV-03 incident inside coverage dates) -> duplicate (R-ELG-03) -> documents (R-DOC-01, pend until received) ->
fraud flags (R-FRD-05, score >= 0.5 goes to review) -> coverage terms (R-ELG-01: item and incident type must be covered by the item's coverage) -> exclusions (R-ELG-02) -> payable per coverage
(R-PAY-01: eligible minus deductible, capped at the remaining limit) -> reserve (R-RSV-01) -> approval authority
(R-APR-01: above 30,000 USD needs the approver). Every state change is a new row in `claim_status_history` with actor role,
rule ID and reason. The catalogue is `src/claimsgen/rules.py`.

## How we know it works

- **Validation:** 12 checks (about 290,000 row-level checks over the roughly 23,000-row dataset); zero failures on the clean baseline, and after injection the failing ids are exactly the planted integrity defects.
- **Independent payable check:** `tests/payable_reference.py` re-implements the payable rule from the spec text (it does not import `rules.py`) and is compared with the engine on hand-computed cases and on every approving claim.
- **Fraud row caveat:** the fraud labels are the planted indicator pattern (an early claim near the limit), so the `suspected_fraud` precision and recall check rule consistency; they are not a fraud-detection accuracy.
- **The evaluation can fail:** mutation tests (`tests/test_mutation.py`) break one rule at a time and assert that recall, precision or amounts move.
- **Injection is contained:** every non-target claim is identical before and after injection (`tests/test_injection_isolation.py`).
- **Intake is exercised through the real app:** seven example claims, each tested to reach its intended rule at starter and full scale (`tests/test_intake_examples.py`, `tests/test_app_intake.py`); validation checks structure, format and sanity bounds (see [docs/CLAIM_INPUT.md](docs/CLAIM_INPUT.md)); every business outcome is decided by the rules.
- **No leakage, byte-stable output:** label columns are rejected in inputs, and two same-seed builds are byte-identical (`scripts/verify.py`, run in CI).

## Realism and calibration

Reference ranges are approximate, snippet-level public figures (sources and URLs in [docs/review/research/insurance-realism.md](docs/review/research/insurance-realism.md)); they set plausible ranges, they are not fitted targets. Every value below is from a fresh full-scale build.

| Metric | This dataset | Reference | Status |
|---|---|---|---|
| Claimed amount, median per claim (USD) | AUTO 6.3k, HOME 10.6k, LIAB 18.8k, HLTH 4.5k, TRVL 3.3k; 3.9% of claims denied as within the deductible | auto collision 3.8k to 10k; general liability mean about 78k; trip cancellation about 1.5k | calibrated per coverage (medians, not the liability mean) |
| Approver share of approved settlements | 11.9% above 30,000 USD | none; band of 8-15% chosen so the approver path is exercised | hand-chosen |
| Reporting lag (days) | median 2, p90 14, max 120; 1.9% over 60 days | none used | hand-chosen shape, long tail |
| Fraud flags (share of claims) | F1 16.6%, F2 0.4%, F3 7.0%, F4 1.9%; referrals 3.0% | special-investigation referral about 3-10% | in range; the labels are planted |
| Submission to paid, median days | HLTH 9, AUTO 11, TRVL 12 (10 claims), HOME 19, LIAB 20 | repairable auto about 19, homeowners about 41 | ranked like the benchmarks, faster than real life |
| Straight-through rate | 70.3% (no exception; every decision is automated) | 10-20% of a blended book (vendor figures) | not comparable |
| Claims per policy-year | 0.90 (1,000 claims over about 1,111 policy-years) | auto collision about 0.05 | fixed by the brief, more than 10x a real book |
| Policies not in force at the as-of date | 26.3% (13% lapsed or cancelled, the rest ended by term) | annual auto retention about 78-82% | plausible, not modelled further |
| Not modelled | investigation and negotiation time, document-chase closure, reopen and appeal, reserve development (the reserve equals the payable at approval) | | stated limits |

## Where to verify the review points

| Point                                   | Evidence                                                                                                                   |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| a. Distributions                        | `validation_summary.md` distributions section; `tests/test_claims.py`                                                  |
| b. IDs and joins                        | `tests/test_ids.py`; validation checks (ID format, foreign keys)                                                         |
| c. Lifecycle                            | validation date-order and lifecycle checks; `rules.TRANSITIONS`                                                          |
| d. Derived values                       | validation arithmetic replay (`checks_business.py`)                                                                      |
| e. Normal, boundary, failure, exception | six injected cases and four boundary cases, counted in `validation_summary.md`; `tests/test_inject.py`                 |
| f. Ground truth separate                | `ground_truth.*` at the top level; inputs carry schema columns only (`tests/test_inject.py`, leakage check)            |
| g. Reproducibility and provenance       | `python scripts/verify.py`; reproducibility table in `validation_summary.md`; `checksums.sha256`; SOURCE_MANIFEST.md |

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

- Intake accepts structured claims only (a form or JSON in the documented template). There is no free-text or document extraction, by choice: intake and the decision path are fully deterministic, so accuracy cannot drop at the intake step; the cost is that messy real-world input would need a separate adapter.
- The validator replays derived amounts through the same `rules.payable` function the engine uses: it is an independent
  replay of the inputs, not an independent implementation of the formula. `tests/payable_reference.py` is the independent
  reimplementation from the spec text, checked against the engine on hand-computed fixtures and on the full dataset.
- Very recent claims are honestly left in an earlier status when the next step would fall after the as-of date, and count as
  misses in recall. `claim_over_limit` precision is below 1 (0.81) because the limit is an annual total per coverage: a later ordinary claim on a policy whose limit an earlier claim already used up is also decided `limit_reached`.
- `under_review` is terminal in this dataset, and reserves are not revised in the baseline.
- There is no document-chase SLA or closure: a claim in `docs_pending` or `under_review` stays there unless documents arrive.
- Duplicate detection matches the exact incident date only; a copy with the date shifted by one day is not caught (real carriers match within a window).
- The `SET-...-002` second payment is an unavoidable marker of the paid-twice case.
- The optional LLM extension is not built; the dataset and workflow are fully deterministic.
- The approver threshold (30,000 USD), fraud cutoff (score 0.5), the 30/90/60-day fraud windows and the document window (5 days) are hand-chosen constants in `src/claimsgen/config.py`, not fitted to data.
- There is no reopen or appeal flow: `denied` and `under_review` claims are final in this dataset.
- The four fraud flags (early claim, repeated claims, amount near the limit, late reporting) are simple heuristics, combined as flags divided by 4, not a trained model.

## Where AI would go next

Not built: the dataset and workflow are deterministic by choice, so the evaluation is exact. Where a model would help, in order:
1. FNOL extraction: turn free text into a draft claim, shown to a person to confirm, and score it field by field against the generator's ground truth.
2. Adjuster summaries: a short narrative of each decision, checked against the rule trace so it cannot cite a rule that did not fire.
3. Document triage: classify uploads and flag likely rejections before the R-DOC-01 check.
4. Cost and privacy: a local model on the claim text, no personal data leaving the machine, a fixed prompt version logged per decision, and the rules (not the model) keep the final say.

## AI use and prompt history

`ai-transparency/` records which AI tools and models were used, where they helped, what was verified, and the limits of that record;
`ai-transparency/prompt-history/` holds the prompts (generated by `python scripts/export_prompts.py`, redacted for paths, e-mails and tokens).

## Repository map

`src/claimsgen/` generator, rules engine, validation, injection, export, metrics, view data · `app.py` the view ·
`scripts/` verify and helpers · `tests/` · `docs/` spec, design, data dictionary, schema · `docs/study/` a living study
guide (one note per module, glossary, an end-to-end claim walk-through, change log) · `CONTRIBUTING.md` commit format.
