# DESIGN v2 (revised after Opus review): schema, rules, pipeline

Config constants (one `config.py`): SEED=20261022, AS_OF=2026-10-22 (fixed, never the system clock), CURRENCY=USD,
APPROVER_THRESHOLD=10000, FRAUD windows (30 d, 90 d, 60 d), `scale` (1.0 = 2,000 policies / 1,000 claims; starter 0.05).
Claim types = products: AUTO, HOME, HLTH, TRVL, LIAB. Money = integer cents internally, Decimal ROUND_HALF_UP, 2-dp text.
"2026" in IDs is the ID series year, not a start year; policies may start 2024-2026.

## Tables (input tables carry NO label/answer columns; no mutable status columns)
| Table | PK | FKs | Fields |
|---|---|---|---|
| customer | CUS-000001 | - | full_name, dob, region, created_date |
| policy | POL-AUTO-2026-000001 | customer_id | product, start_date, end_date, premium |
| policy_event | PEV-<policyid>-001 | policy_id | event_type(issued/lapsed/cancelled/expired), event_date |
| coverage | COV-AUTO-001 | - | product, name, default_limit, default_deductible, exclusion_codes(pipe list) |
| policy_coverage | PCV-<policyid>-001 | policy_id, coverage_id | limit_amount, deductible, effective_start, effective_end |
| incident | INC-2026-000001 | policy_id | incident_date, incident_type |
| claim | CLM-2026-000001 | policy_id, incident_id | claim_type, submission_date, claimed_amount(=sum items) |
| claim_item | ITM-CLM-2026-000001-001 | claim_id, coverage_id | item_type, claimed_amount |
| document_requirement | DRQ-<claimtype>-<doctype> | - | claim_type, doc_type, mandatory |
| document | DOC-CLM-2026-000001-001 | claim_id | doc_type, received_date, status(received/rejected) |
| adjuster | ADJ-001 | - | full_name, region, specialty(product), max_open_claims |
| claim_adjuster_assignment | ASN-CLM-2026-000001-001 | claim_id, adjuster_id | assigned_date, reason(initial/reassigned/workload) |
| assessment | ASM-CLM-2026-000001-001 | claim_id, adjuster_id | assessment_date, decision(approve/deny/pend_docs/refer_review), rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score |
| reserve | RSV-CLM-2026-000001-001 | claim_id | reserve_date, amount, basis(preliminary/revised), rule_id |
| settlement | SET-CLM-2026-000001-001 | claim_id | recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date |
| claim_status_history | EVT-CLM-2026-000001-001 | claim_id | from_status, to_status, event_date, actor_role, rule_id, reason_code |
| ground_truth (separate file) | entity_id+label | - | entity_type, label, origin, kind, expected_decision, rule_id |

- settlement is write-once: stage = which dates are non-null; transitions are recorded in claim_status_history. Never updated.
- Claim status = last history event: submitted, denied, docs_pending, under_review, assessed, approved, paid.
  Policy status on any date derives from policy_event + dates. Customer has no status column.
- Claim IDs are assigned LAST, after injection, by sorting all claims on (submission_date, incident_date, policy_id); child IDs follow.
  Internal integer keys are used until export, so injected rows are not identifiable by ID position and the total stays exactly 1,000.
  (SET-...-002 for paid_twice is an unavoidable tell; documented.)
- Actor roles: requester (submits), operations_analyst (intake, docs request, assessment, reserve), process_owner (approves <= threshold),
  approver (approves > threshold), administrator (reassignments, payment recording).

## Rule catalogue (every decision stores rule_id + reason_code)
Processing order fixed: claims sorted by (submission_date, incident_date, policy_id); "earlier claim" and remaining_limit look only at earlier claims.
1. R-COV-01 submission_date >= policy start, else deny `before_policy_start`
2. R-COV-02 policy in force on incident_date, else deny `policy_not_in_force`
3. R-COV-03 incident_date within policy_coverage effective dates (inclusive), else deny `outside_coverage_period`
4. R-ELG-03 duplicate: same policy, incident_date, claim_type as an earlier claim, then under_review `duplicate_claim`
5. R-DOC-01 mandatory doc types present and not rejected, else docs_pending `missing_document` (no payout; ~50% of natural cases receive docs later and re-run steps 6-10; the reserve is set at that approving assessment)
6. R-FRD flags (any claim reaching this step): F1 submitted within 30 d of policy start; F2 >= 3 claims by the customer in prior 90 d; F3 claimed amount on any coverage >= 95% of its limit; F4 reported > 60 d after incident. fraud_score = flags/4; >= 0.5 -> under_review `suspected_fraud`
7. R-ELG-01 item's coverage is on the policy; R-ELG-02 item_type not in coverage exclusions; failing items contribute 0 eligible
8. R-PAY-01 per coverage c: payable_c = min(max(0, eligible_c - deductible_c), remaining_limit_c); remaining_limit_c = limit_c - recommended amounts already committed on earlier claims for that policy_coverage, replayed in processing order (not by date); payable = sum payable_c; deductible_applied = sum min(eligible_c, deductible_c)
9. R-RSV-01 preliminary reserve = payable at first assessment; revised reserve = new row only if a later re-run changes it (none in the baseline)
10. R-APR-01 payable > APPROVER_THRESHOLD needs approver role else process_owner; paid only after approved; payable 0 -> no settlement
First failing step ends the path (later rules not evaluated). under_review is terminal in this dataset (documented); docs_pending may resume as above.

## Pipeline (determinism)
Per-module RNG: `random.Random(f"{SEED}:{module}")`, fixed call order, sort before any choice, never iterate sets.
1. customers, adjusters, coverage catalogue, document_requirement
2. policies + policy_event + policy_coverage (in-force ~75%, expired ~13%, lapsed ~8%, cancelled ~4%)
3. (claims.py; returns planted scenarios separately; the injection step renumbers IDs in a finalize step) incidents, claims (uneven type mix, ~35% AUTO), claim_items (lognormal), documents (~8% naturally incomplete); deliberate boundary cases
4. rules engine per claim: history, assignment, assessment, reserve, settlement
5. baseline validation must show zero failures
6. injection (below), ground_truth written
7. assign final IDs, export CSV/JSON/SQL, validation report, metrics, checksums
Commands: `python -m claimsgen build --scale S --out DIR`; `python -m claimsgen all` builds starter (0.05) and full (1.0); `scripts/verify.py` builds twice and diffs row counts + SHA-256.
Byte stability: CSV `newline=''` with `\n`; JSON sorted keys, fixed separators; no float formatting; checksum the SQL seed text, not the .db.
Outputs: CSVs, JSON, seed.sql, ground_truth.csv, README, schema + data dictionary (generated from one field-spec), SOURCE_MANIFEST, validation summary, reproducibility result.

## Boundary cases (deliberate, baseline, labelled kind=boundary in ground_truth, ~10 each)
incident on policy start date; incident on end date; claimed amount exactly at coverage limit; claimed amount equal to deductible (payable 0).

## Injection (disjoint target sets; only policies with exactly one claim; mutates only target rows)
Business-outcome cases re-run the engine for that claim only; integrity-defect cases are patched AFTER the engine and never re-run.
- claim_before_policy_start (business): submission_date < start (incident also before start); engine denies R-COV-01. Label: claim
- cancelled_before_incident (business): add policy_event cancelled before incident_date; engine denies R-COV-02. Label: claim
- duplicate_incident (business): new claim + incident cloning an existing single-claim policy's incident; engine flags R-ELG-03 on the later one. Label: the later claim
- missing_mandatory_doc (business): delete one required document; engine docs_pending, no settlement. Label: claim
- settlement_exceeds_limit (integrity): after engine on an approved/paid claim, raise approved/paid amount above limit. Label: SET row
- paid_twice (integrity): add SET-...-002 paid row to a paid claim. Label: second SET row

## Validation
PK uniqueness; ID regexes for ALL patterns (POL, CLM, DOC, ASN, SET, CUS, COV, INC, ITM, PEV, PCV, DRQ, ADJ, ASM, RSV, EVT); FK integrity; enums;
every date <= AS_OF; date order policy start <= incident <= submission <= assessment <= settlement, EXEMPT only for claims whose history shows denial by
R-COV-01 with no assessment/settlement (keyed on input data, never on labels); arithmetic (items sum to claim; R-PAY-01 recompute; latest reserve = final
payable; no reserve unless assessed); lifecycle (legal transitions, approved before paid, role matches R-APR-01); duplicates; label-leakage test; determinism.
Baseline: zero failures. After injection: set of failing entity_ids == set of integrity-defect ground_truth entity_ids (not a failure count).
Metrics: precision/recall per label vs ground_truth; approval/denial rates, docs-pending rate, days submission->settlement, amount blocked, reserve vs final;
share of settlements above threshold must land ~5-15% (tune lognormal) so the approver path is exercised.

## Reviewer checkpoint 1 decisions (generation step)
- R-COV-02: policy is in force on date d iff start_date <= d <= end_date AND no lapsed/cancelled event with event_date <= d. The
  `expired` event (dated end_date) is informational and does not end coverage early, so boundary_incident_on_end is covered.
- R-DOC-01: a document counts only if received_date <= submission_date + DOC_WINDOW_DAYS (5). Late docs arrive 10-30 days after.
- Fraud constants live in config: F1 submission within 30 days of start (inclusive); F2 at least 3 EARLIER claims by the customer
  in the prior 90 days (inclusive window, current claim excluded); F3 any coverage claimed >= 95% of its limit; F4 reported > 60 days after
  the incident; score = flags/4, review at >= 0.5.
- Over-limit and at-limit claims are generated without F1 and without excluded (cosmetic) items so the rules decide them as capped payments.
- Normal and planted claims never share (policy, incident_date); only labelled duplicates do.
- DO LATER (logged): finalize(tables, planted, ground_truth) remaps all claim-derived IDs through one old->new dict with FK and
  ground_truth remap tests (injection step); the AS_OF date check applies to event/transaction dates only, not term end dates
  (validator step); settlement_exceeds_limit targets single-coverage paid claims and compares to policy_coverage.limit_amount (injection);
  fraud_score exported as a fixed 2-dp string (export).

## Engine decisions (rules step)
- remaining limit = policy_coverage limit minus the sum of `recommended_amount` already committed on earlier claims (not only paid), so in-flight claims cannot jointly exceed a limit.
- Fraud decision rule is R-FRD-05 (R-FRD-01..04 are the flags). New reason code `eligible` for an uncapped approval; `limit_reached` for a capped or exhausted limit.
- A claim whose next step would fall after AS_OF stays in its earlier status; docs_pending claims with a late document resume on its received date (second assessment); claims with no such document stay docs_pending.
- Preliminary reserve is set only at an approving assessment, so `revised` reserves do not occur in the baseline (enum kept for later use).
- Adjusters: at least 10 (two per product) so a 5% reassignment is always possible; initial assignment is least-loaded by specialty.

## Reviewer checkpoint 2 decisions (rules step)
- Processing order is (submission_date, incident_date, policy_id, claim_id), never the provisional claim_id.
- Each claim's engine RNG is seeded from its own stable fields (policy, incident date, submission date, type); adjusters are chosen from that stream, not by shared load. Re-running the full engine after injection therefore changes only claims coupled to the target by policy_coverage limits, same-policy duplicates, or the customer's 90-day F2 window; injection targets must avoid such coupling (single-claim policies, customers with no other claim in the window).
- fraud_score is written only for claims that reach the fraud step (R-FRD); earlier COV/duplicate/doc decisions store 0.0.
- An assessment is never dated before the in-window documents have arrived; reassignment never falls after AS_OF.
- DO LATER: validator replays rules.payable in processing order and compares recommended_amount; reconcile reserves to assessment payable; key every settlement failure on settlement_id; strengthen test_engine (per-scenario checked counts, all five tables in the determinism test).

## Validation decisions (validate step)
- Failures are keyed by the offending row id. The settlement replay (rules.payable in processing order, committing expected amounts) flags a corrupted settlement alone.
- The AS_OF check covers event/transaction dates only; term end dates and coverage effective dates are exempt.
- The only pre-start activity allowed is for claims whose history shows denial by R-COV-01.
- Injection must keep ground_truth entity ids aligned with failure keys: the settlement row for settlement_exceeds_limit and paid_twice (second settlement).

## Injection decisions (inject step)
- Targets: clean claims whose policy and customer each have exactly one claim and whose status is assessed/approved/paid; disjoint across cases; defects drawn first from paid single-coverage claims.
- Duplicate: a new claim (temporary id) cloning the source; the baseline reserves 15 claim slots so the total stays exactly 1,000.
- Business cases re-run the full engine; defects patch outputs afterwards. Result at full scale: the validator's failing ids equal the integrity-defect ground_truth ids.
- ground_truth expected decisions are written from the rules, not from engine output.

## Scope correction decisions (expose layer)
- Build order: export + reproducibility, metrics, then the view. The view is core scope (SPEC deliverable 11); the LLM extension is not started.
- Layers: `metrics.py` and `view_data.py` hold tested logic; `app.py` is single-file Streamlit rendering only. Data comes from `build_dataset(scale)` (cached), so the app reads no output files.
- Exceptions list and decisions come from engine output (assessment, history, validator failures). ground_truth is read only by the scoring panel.
- Scoring (precision/recall) uses predicted classes derived from engine output plus inputs, never from labels:
  claim_before_policy_start = denied R-COV-01; cancelled_before_incident = denied R-COV-02 and a `cancelled` policy event on/before the incident;
  lapsed_policy = denied R-COV-02 and a `lapsed` event; outside_coverage_period = denied R-COV-03; duplicate_incident = referred R-ELG-03;
  suspected_fraud = referred R-FRD-05; claim_over_limit = decision with reason limit_reached;
  DOC class (incomplete_evidence + missing_mandatory_doc share one prediction, pended R-DOC-01) is scored as one class and reported per label for recall;
  settlement_exceeds_limit and paid_twice = validator failing ids; boundary labels = recall of "decided as expected".
- Operational metrics: approval/denial/docs-pending rates, days submission to settlement, amount blocked by rules (claimed minus payable on decided claims), reserve vs final settlement.

## Reviewer checkpoint 3 decisions (injection step)
- Duplicate targets require submission + 15 days <= AS_OF so the clone is always assessed.
- finalize re-sorts policy_event so injected cancellations are not identifiable by row position; the export step must keep table order and not re-sort by primary key.
- ground_truth expected_decision starts with a decision word from EXPECTED_WORDS; metrics match on (word, rule_id) or a per-label predicate.
- DO LATER: before/after test that non-target claims are unchanged; hand-computed payable fixtures (the validator and engine share rules.payable); README note that 10-30 rows per case applies at full scale (starter has 2).

## Export decisions (export step)
- Package layout: csv/, json/, seed.sql, schema.sql, ground_truth.{csv,json,sql}, DATA_DICTIONARY.md, SOURCE_MANIFEST.md, validation_summary.md, manifest.json, README.md, checksums.sha256.
- Byte stability: dataset row order kept, schema column order, exact decimal text for money and ratios, ISO dates, LF/UTF-8, SQL text (not .db) is the checksummed artifact, manifest command uses `<DIR>`.
- `build` exports twice (second copy in a temp dir) and writes the comparison into validation_summary.md; `scripts/verify.py` additionally compares every file of two full builds.
- Only the fixed seed is accepted; exit code is non-zero if validation does not flag exactly the planted defects or the rerun differs.
- output/starter is committed for quick inspection; output/full is gitignored (regenerate with the CLI).

## Metrics decisions (metrics step)
- predictions() takes (tables, checks) only; ground_truth is used solely to build truth sets in score().
- Document labels share one predicted class (R-DOC-01 pended); injected-vs-baseline cannot be told apart from the decision, so they are scored as a class and per label for recall.
- Claims not yet assessed at AS_OF count as misses; claim_over_limit precision is below 1 because organic claims also reach `limit_reached`. These are reported as they are, not tuned away.
- Every dataset package includes metrics.md; the view will reuse metrics.operational and scoring.score.

## View decisions (view step)
- `app.py` (repo root) is rendering only; logic and numbers live in `view_data.py` (tested). Run with `streamlit run app.py`; the dataset is built in memory (starter or full) and cached, so the app reads no output files.
- Exceptions list reuses `scoring.predictions`, so what the view shows as an exception and what the scoring table scores are the same definitions.
- A headless `streamlit.testing.v1.AppTest` run proves the app executes and every panel and selector works (skipped if the `ui` extra is not installed).

## Improvements decisions (backlog IMP-002 to IMP-012)
- Credibility: the payable rule has an independent reference implementation in tests (written from the spec, no import of rules.py); mutation tests show scoring and validation change when a rule is broken; injection is tested to leave non-target claims identical.
- Metrics: money effect by rule, touchless rate, approver workload, docs-pending aging and cycle time by type are computed from the dataset tables. The threshold sweep re-runs the clean engine, so it counts recommended settlements and can differ slightly from the approver workload table (recent unapproved settlements, planted amount defects); the report says so.
- View: the rule trace and counterfactual are derived from assessments, history and rule functions only (never ground truth). The dataset checksum is a SHA-256 over canonical CSV text (export.csv_text); rebuild-and-compare proves determinism live. The seed stays fixed and read-only because the brief fixes it.
- Process: improvements were built by Sonnet and Haiku workers on disjoint files; workers never committed; the orchestrator verified (ruff, tests, output spot-checks) and committed one group at a time.

## Intake decisions (claim submission from the front end)
- Intake is deterministic: a structured template (docs/CLAIM_INPUT.md) validated for structure, format and sanity bounds only; claim_type is derived from the policy; every business outcome is decided by the rules.
- A submitted claim is a what-if: inputs are copied, the claim is appended under provisional ids, and engine.run(tables, as_of=, fraud_threshold=, approver_threshold_cents=) runs with the as_of (the later of dataset date + 30 days and submission date + 21 days) and the thresholds passed as arguments. config is never patched at runtime, so concurrent Streamlit sessions cannot race. Claims are processed in (submission_date, incident_date, policy_id, claim_id) order; the provisional id only breaks complete ties. Only that claim's rows are read back. The whole dataset is advanced to the horizon, so real claims still pending at the dataset date can consume limits before the draft. Existing claims submitted after the draft are still processed, but their outcomes are not shown. The dataset and ground_truth are untouched.
- Example claims come from deterministic filters over the input tables (never ground truth) and are tested against their intended (decision, rule, reason) at 0.05, 0.25 and 1.0.
- No AI in intake: accuracy of the decision path is unchanged; the stated cost is that unstructured input would need an adapter (a deterministic parser for semi-structured text, or an optional human-confirmed assistant scored against ground truth).
- Process: Opus reviewed the design first (the dataset date being in the past was the key finding); Sonnet workers built the core and UI wiring, Haiku workers the validation, the display tab and the docs; the orchestrator verified each piece and committed one group at a time.
