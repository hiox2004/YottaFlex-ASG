# Prompts sent to subagents and helper models

Prompts Claude wrote and sent to other models on the user's behalf.

## Subagents

### Session 1, 2026-10-30T07:15:15.690Z: general-purpose on opus (Opus design review)

```text
You are a strict READ-ONLY reviewer (do not edit, write or run anything except Read/Grep/Glob). Repo: C:\Users\<user>\Desktop\YottaFlex_ASG. Read docs/DESIGN.md (draft), docs/SPEC.md, docs/BRIEF_VS_PLAN.md and CLAUDE.md. Review DESIGN.md against the brief's requirements in SPEC.md: the 10 deliverables, review points a-g, six edge cases, and the pitfalls (label leakage, random outcomes, status overwrite, orphan FKs from injection, clock/unseeded randomness).
Report tersely: (1) concrete defects or contradictions (cite the DESIGN.md section), (2) missing items vs the brief, (3) answers to the three 'Known open questions', (4) any rule or injection that would make validation ambiguous or break reproducibility. No praise, no restating. Max ~40 lines.
```

### Session 1, 2026-10-30T08:38:26.563Z: general-purpose on opus (Opus ROI checkpoint review)

```text
You are a strict, read-only reviewer for the YottaFlex-ASG claims data challenge. Never edit files; use only Read/Grep/Glob.

Think first about what is actually wrong or risky, not what could be polished. Check against docs/SPEC.md, docs/DESIGN.md and CLAUDE.md: the 10 deliverables, review points a-g, and the pitfalls (label leakage into input tables, random outcomes instead of rule-derived, status overwrite, orphan FKs from injection, clock/unseeded randomness, byte-unstable output). Do not read raw output data files.

Scope: checkpoint review of the generation code built so far in C:\Users\<user>\Desktop\YottaFlex_ASG: src/claimsgen/{config,ids,vocab,schema,masterdata,policies,claim_build,claims}.py and tests/. The rules engine (next step) will build directly on these tables, so focus on anything that would make the engine, validation, injection, determinism, or ground_truth wrong or ambiguous: e.g. planted scenarios the rules would not decide as intended, boundary/limit semantics, date windows, the ID renumbering plan, leakage, anything affecting byte-stable export.

Report format (terse, no praise, no restating the spec, max ~45 lines):
1. Findings, most severe first. For each: where (file:line), what fails which brief item, a one-line fix.
2. For each finding give: quality impact (high/med/low, tied to graded review points), cost to fix (tokens and minutes: S/M/L), and verdict = DO NOW (high impact, S/M), DO LATER (before final audit), or SKIP (low ROI).
3. A short "do now" list in the order to fix. If nothing clears the ROI bar, say "no changes needed" instead of padding.
Prefer fixes that cost little and protect graded criteria; skip stylistic or speculative work.
```

### Session 1, 2026-10-30T08:51:43.096Z: general-purpose on opus (Opus ROI review of engine)

```text
You are a strict, read-only reviewer for the YottaFlex-ASG claims data challenge. Never edit files; use only Read/Grep/Glob. Do not read raw output data files.

Think first about what is actually wrong or risky, not what could be polished. Check against docs/SPEC.md, docs/DESIGN.md (including the 'Reviewer checkpoint 1 decisions' and 'Engine decisions' sections) and CLAUDE.md: the 10 deliverables, review points a-g, and the pitfalls (label leakage into input tables, random outcomes instead of rule-derived, status overwrite, orphan FKs, clock/unseeded randomness, byte-unstable output).

Scope: the rules step in C:\Users\<user>\Desktop\YottaFlex_ASG: src/claimsgen/rules.py, src/claimsgen/engine.py, tests/test_engine.py (and how they use claims.py output and config.py). Next steps are baseline validation, then injection of the six labelled cases (claim_before_policy_start, cancelled_before_incident, duplicate_incident, settlement_exceeds_limit, missing_mandatory_doc, paid_twice) with ground_truth. Focus on anything that would make validation, injection, ground_truth precision/recall, lifecycle consistency, or derived-value reconciliation wrong or ambiguous: e.g. status/transition gaps, date ordering across assessment/reserve/settlement/history, limit and committed-amount semantics, approver-role logic, duplicate and fraud rule edge cases, whether injected cases could be re-decided correctly by re-running the engine for one claim, performance of per-claim re-runs (World is built from all tables), and whether tests actually prove what they claim.

Report format (terse, no praise, no restating the spec, max ~45 lines):
1. Findings, most severe first. For each: where (file:line), what fails which brief item, a one-line fix.
2. For each finding give: quality impact (high/med/low, tied to graded review points), cost to fix (tokens and minutes: S/M/L), and verdict = DO NOW (high impact, S/M), DO LATER (before final audit), or SKIP (low ROI).
3. A short "do now" list in the order to fix. If nothing clears the ROI bar, say "no changes needed" instead of padding.
Prefer fixes that cost little and protect graded criteria; skip stylistic or speculative work.
```

### Session 1, 2026-10-30T10:06:27.264Z: general-purpose on opus (Opus ROI review of injection)

```text
You are a strict, read-only reviewer for the YottaFlex-ASG claims data challenge. Never edit files; use only Read/Grep/Glob. Do not read raw output data files.

Think first about what is actually wrong or risky, not what could be polished. Check against docs/SPEC.md, docs/DESIGN.md (all decision sections) and CLAUDE.md: the 10 deliverables, review points a-g, and the pitfalls (label leakage into input tables, random outcomes instead of rule-derived, status overwrite, orphan FKs from injection, clock/unseeded randomness, byte-unstable output).

Scope: the injection step in C:\Users\<user>\Desktop\YottaFlex_ASG: src/claimsgen/inject.py, finalize.py, ground_truth.py, generate.py, and tests/test_inject.py (plus how they use engine.py, claims.py, validate/checks_*.py). The six mandatory cases are claim_before_policy_start, cancelled_before_incident, duplicate_incident, settlement_exceeds_limit, missing_mandatory_doc, paid_twice. Focus on what a grader would catch: ground_truth correctness (right entity, kind, expected decision, rule), whether injected rows can be identified from the input tables themselves (ID position, document shifts, dates, patterned amounts, gaps), whether injections break unrelated rows or leave orphans, whether the six cases truly exercise the intended rule, whether the ground_truth/validator/engine agreement is real or only holds by construction, whether tests prove what they claim (e.g. tautologies), reproducibility/byte-stability risks, small-scale (starter 0.05) fragility, and anything the next steps (export CSV/JSON/SQL, metrics precision/recall, verify) will trip over.

Report format (terse, no praise, no restating the spec, max ~45 lines):
1. Findings, most severe first. For each: where (file:line), what fails which brief item, a one-line fix.
2. For each finding give: quality impact (high/med/low, tied to graded review points), cost to fix (tokens and minutes: S/M/L), and verdict = DO NOW (high impact, S/M), DO LATER (before final audit), or SKIP (low ROI).
3. A short "do now" list in the order to fix. If nothing clears the ROI bar, say "no changes needed" instead of padding.
Prefer fixes that cost little and protect graded criteria; skip stylistic or speculative work.
```

### Session 1, 2026-10-30T12:19:06.724Z: claude on sonnet (Worker A: isolation, payable, mutation tests)

```text
You are worker A on the YottaFlex-ASG repo at C:\Users\<user>\Desktop\YottaFlex_ASG (Python 3.12, Windows, pytest, ruff). Read CLAUDE.md, docs/DESIGN.md (decision sections at the end), docs/study/IMPROVEMENTS.md (IMP-002, IMP-003, IMP-004) and docs/study/modules/{inject,finalize,engine,rules,scoring,validate}.md first.

TASK: add NEW TEST FILES ONLY (tests/test_injection_isolation.py, tests/payable_reference.py, tests/test_payable_independent.py, tests/test_mutation.py). Do not edit anything under src/ (if you find a bug there, report it, do not fix it). Do not edit docs/study/README.md, LOG.md, docs/DESIGN.md, docs/SPEC.md, IMPROVEMENTS.md, or any existing test.

1) IMP-004 (tests/test_injection_isolation.py): prove injection leaves non-target claims untouched. Rebuild the pipeline in the test using public functions: masterdata.generate, policies.generate, claims.generate, engine.run (baseline outputs on {**master, **pol, **claim_tables}), then inject.inject(...) and finalize.finalize(...) to obtain the old->new idmap. For every claim that is not an injected target (injected entries carry provisional entity ids; settlement entities map to their claim; the duplicate's source claim is NOT a target) assert that all of its rows in claim, incident, claim_item, document, claim_adjuster_assignment, assessment, reserve, settlement and claim_status_history are identical between the baseline and the final tables after translating ids through idmap (claim_id, incident_id and each row pk). Also assert policy, customer, coverage, adjuster, document_requirement and policy_coverage rows are unchanged and that policy_event differs only by the added cancelled events. Run at scale 0.05 and 1.0.

2) IMP-002: tests/payable_reference.py = an INDEPENDENT reimplementation of the payable rule written from the spec text (per coverage: payable = min(max(0, eligible - deductible), remaining limit), remaining = limit minus amounts already committed on earlier claims for that policy_coverage; eligible excludes item types listed in the coverage exclusion_codes; claims processed in (submission_date, incident_date, policy_id, claim_id) order). It must not import or copy src/claimsgen/rules.py. tests/test_payable_independent.py: (a) hand-computed fixtures with explicit numbers in cents (simple deductible, zero floor when eligible < deductible, capped at remaining limit, claimed exactly at the limit, committed amounts reducing remaining, two coverages summed, remaining limit zero) asserting both rules.payable and your reference give the hand-computed value; (b) on the generated full-scale dataset, replay every claim whose last assessment decision is approve in processing order with your reference (committing the reference's own amounts) and assert the result equals the assessment payable_amount and, for settlements that are not planted defects, recommended_amount.

3) IMP-003 (tests/test_mutation.py): mutation tests proving the evaluation can fail. Use monkeypatch to break one rule at a time, re-run engine.run on the final input tables (tables minus the five engine output tables), recompute validate.run_all and scoring.score against the UNCHANGED ground_truth and assert the numbers move: (i) make rules.in_force ignore lapse/cancel events so recall of cancelled_before_incident and lapsed_policy drops clearly below the unmutated value; (ii) make rules.payable ignore the deductible so scoring recall for boundary_amount_at_deductible drops AND your independent reference from step 2 disagrees with the mutated engine amounts; (iii) one more mutation of your choice (for example config.DOC_WINDOW_DAYS or the duplicate rule) with a clear assertion. Each test first asserts the unmutated metric is high, then the mutated one is lower. Keep runtime reasonable (build the dataset once per module).

RULES: seeded randomness only, no clock, files under about 300 lines, no label columns anywhere. Never use rm -rf; do not read anything under output/; no pip install; do NOT commit or run git commands other than read-only status/diff. The project's edit hook runs ruff and the whole pytest suite after each Python edit; other workers are editing other files at the same time, so ignore hook failures that are not in your files, but at the end run `python -m ruff check . && python -m ruff format --check .` and `python -m pytest tests/test_injection_isolation.py tests/test_payable_independent.py tests/test_mutation.py -q` and make them pass. Final reply (max 15 lines): files created, test results, anything you could not do, any src bug found.
```

### Session 1, 2026-10-30T12:19:06.742Z: claude on sonnet (Worker B: business metrics and sensitivity)

```text
You are worker B on the YottaFlex-ASG repo at C:\Users\<user>\Desktop\YottaFlex_ASG (Python 3.12, Windows, pytest, ruff). Read CLAUDE.md, docs/DESIGN.md (decision sections at the end), docs/study/IMPROVEMENTS.md (IMP-007, IMP-008) and docs/study/modules/{metrics,scoring,engine,config}.md first. Read src/claimsgen/metrics.py, scoring.py, engine.py, config.py and tests/test_metrics.py.

TASK (files you may create or edit: src/claimsgen/metrics.py, src/claimsgen/sensitivity.py (new), tests/test_metrics_business.py (new), tests/test_sensitivity.py (new), docs/study/modules/metrics.md (edit), docs/study/modules/sensitivity.md (new); you may adapt tests/test_metrics.py only if a change of yours requires it). Do NOT edit app.py, view_data.py, dataset_docs.py, docs/study/README.md, LOG.md, docs/DESIGN.md, docs/SPEC.md or IMPROVEMENTS.md. Keep every existing key of `metrics.operational()` unchanged; only add keys. A separate worker will later show your new metrics in the Streamlit view, so keep them plain dicts with integers/floats/strings and document the keys in docs/study/modules/metrics.md.

1) IMP-007 business-outcome metrics, added to `metrics.operational(tables)` and rendered by `metrics.to_markdown` (new sections, existing sections kept):
 - `by_rule`: money effect per rule from each claim's FINAL assessment: denied claims = blocked (claimed amount), approved claims = reduced (claimed minus payable, attributed to R-PAY-01 or R-ELG-02), pended/referred = held. Shape {rule_id: {"effect": ..., "claims": n, "amount_cents": x}} (one entry per rule_id/effect pair is fine; choose a clear key like "R-COV-02/blocked").
 - `touchless`: among assessed claims, the share that reached assessed/approved/paid without ever having a pend_docs or refer_review assessment (no human step); give counts and rate.
 - `approver_workload`: settlements and amounts by approver_role (process_owner vs approver), counting each claim's first settlement once.
 - `docs_pending_aging`: for claims whose final status is docs_pending, age in days at AS_OF (count, mean, median, p90, max, count older than 14 days).
 - `cycle_by_claim_type`: days submission to paid, median and p90 per claim type.
 Use only the dataset tables (no ground_truth). Money in integer cents internally, USD text in the markdown.

2) IMP-008 new module src/claimsgen/sensitivity.py: `sweep(tables, ground_truth) -> dict` re-runs engine.run on the input tables (the tables minus claim_adjuster_assignment, assessment, reserve, settlement, claim_status_history) while temporarily patching config.APPROVER_THRESHOLD_CENTS over [500_000, 1_000_000, 2_000_000, 5_000_000] and config.FRAUD_THRESHOLD over [0.25, 0.5, 0.75, 1.0]; ALWAYS restore the original values in a finally block. For each setting report: fraud-referred claims (R-FRD-05), claimed amount flagged for review, settlements routed to the approver (count and amount), and for the fraud sweep precision and recall of the suspected_fraud label against ground_truth (use scoring.predictions on the re-run tables with an empty checks list and the suspected_fraud truth ids from ground_truth). Render it in `metrics.to_markdown` as a "Threshold sensitivity" section with the current settings clearly marked. Deterministic; no randomness; no clock.

Tests: new metrics keys are consistent (rates in 0..1, touchless + reviewed = assessed, by_rule amounts add up to the matching totals), sweep is deterministic, config values are restored afterwards, the row for the current settings (10,000 USD and 0.5) reproduces the live numbers, and monotonicity holds (higher approver threshold means fewer approver settlements; higher fraud cutoff means fewer fraud referrals).

RULES: seeded randomness only, no clock, files under about 300 lines (split if needed, and every new src module needs docs/study/modules/<name>.md because a test enforces it), no label columns in input tables, ground_truth is used only for scoring. Never use rm -rf; do not read anything under output/; no pip install; do NOT commit or run git commands other than read-only status/diff. The project's edit hook runs ruff and the whole pytest suite after each Python edit; other workers are editing other files at the same time, so ignore hook failures that are not in your files, but at the end run `python -m ruff check . && python -m ruff format --check .` and `python -m pytest tests/test_metrics.py tests/test_metrics_business.py tests/test_sensitivity.py tests/test_export.py -q` and make them pass. Final reply (max 15 lines): files changed, the new metrics keys and function signatures, test results, anything you could not do.
```

### Session 1, 2026-10-30T12:19:06.757Z: claude on haiku (Worker C: README limits and backlog housekeeping)

```text
You are worker C (mechanical docs only) on the repo at C:\Users\<user>\Desktop\YottaFlex_ASG. Edit ONLY README.md and docs/study/IMPROVEMENTS.md. Do not edit any code, tests, or other docs. Do not run git commands except read-only status/diff. Never use rm -rf.

1) README.md: in the section titled "Known limits (stated, not hidden)" add three short bullets in the same style: (a) the approver threshold (10,000 USD), the fraud cutoff (score 0.5), the 30/90/60-day fraud windows and the document window (5 days) are hand-chosen constants in src/claimsgen/config.py, not fitted to data; (b) there is no reopen or appeal flow: denied and under_review claims are final in this dataset; (c) the four fraud flags are simple heuristics (early claim, repeated claims, amount near the limit, late reporting) combined as flags divided by 4, not a trained model. Do not change anything else in the README.

2) docs/study/IMPROVEMENTS.md: move three entries from the "## Open" section to the "## Done" section, keeping each entry's original text exactly and appending one line "- Resolution: ..." to each:
 - IMP-005: "README rewritten as a reviewer's guide with the review-point evidence table, status and the 10-30 rows per case note (commit a62674e, docs(readme))."
 - IMP-012: "CI runs ruff, pytest and scripts/verify.py 0.05 on every push (commits 1cbb481 and 6241e72)."
 - IMP-010: "README 'Known limits' section extended with hand-chosen thresholds, no reopen/appeal flow and heuristic fraud flags (commit: to be filled by the orchestrator)."
Leave every other entry (IMP-002, 003, 004, 006, 007, 008, 009, 011) in Open untouched, and keep the "Suggested order" line and the Rejected section as they are. Keep the Done section ordered IMP-001 first, then the three you moved in numeric order.

Final reply (max 6 lines): what you changed.
```

### Session 1, 2026-10-30T12:22:14.507Z: claude on sonnet (Worker D: view trace, checksum, realism)

```text
You are worker D on the YottaFlex-ASG repo at C:\Users\<user>\Desktop\YottaFlex_ASG (Python 3.12, Windows, pytest, ruff, Streamlit installed). Read CLAUDE.md, docs/SPEC.md (deliverable 11), docs/DESIGN.md (decision sections at the end), docs/study/IMPROVEMENTS.md (IMP-006, IMP-009, IMP-011) and docs/study/modules/{view_data,metrics,sensitivity,scoring,rules,engine}.md. Read src/claimsgen/view_data.py, app.py, tests/test_view_data.py, src/claimsgen/rules.py, metrics.py and sensitivity.py.

FILES YOU MAY EDIT: src/claimsgen/view_data.py, app.py, tests/test_view_data.py (extend), new tests/test_view_trace.py, docs/study/modules/view_data.md, docs/study/scripts.md (only the app.py row). Treat src/claimsgen/metrics.py, sensitivity.py, dataset_docs.py, rules.py, engine.py as READ-ONLY (report if you need a change). Do NOT edit docs/study/README.md, LOG.md, docs/DESIGN.md, docs/SPEC.md, IMPROVEMENTS.md or README.md. If you add a new src module you must add docs/study/modules/<name>.md (a test enforces it); keep every file under about 300 lines.

1) IMP-006 per-claim rule trace and counterfactual (view_data.py + app.py "Claim timeline" tab). Add `rule_trace(tables, claim_id)`: the ordered decision path (R-COV-01, R-COV-02, R-COV-03, R-ELG-03, R-DOC-01, R-FRD-05, R-ELG-02, R-PAY-01, then R-RSV-01 and R-APR-01 for approved claims) with, per step: rule_id, description from rules.RULES, outcome (passed / failed-and-stopped / not evaluated), date, actor role and reason_code, derived ONLY from the claim's assessments and status history (a docs_pending claim that resumed shows the later steps with the re-run date). Add `counterfactual(tables, claim_id)`: plain-language list of what would make a stopped claim payable, computed from data and rules functions (examples: R-COV-01 submission must be on or after policy start <date>; R-COV-02 coverage ended on <lapse/cancel date> before incident <date>; R-COV-03 incident outside coverage dates <start..end>; R-ELG-03 earlier claim <id> has the same policy, date and type; R-DOC-01 missing mandatory documents <types> via rules.missing_docs; R-FRD-05 active flags and score vs cutoff; R-ELG-02 all items are excluded types; R-PAY-01 within deductible: claimed <x> must exceed deductible <y>, or limit reached; approved claims say they are already payable). Neither function may receive ground_truth (a test checks the signatures). In app.py show the trace as a table (and the counterfactual as bullet text) under the timeline.

2) IMP-009 (view_data.py + app.py): `dataset_checksum(tables)` returning a SHA-256 hex digest over the canonical serialisation of the input tables in schema order (reuse export.text/export serialisation helpers so it is byte-stable; do not write files), and `rebuild_and_compare(scale)` that builds the dataset again with generate.build_dataset and returns (identical, checksum_1, checksum_2). In app.py: a scale selector (starter 0.05, 0.25, full 1.0), the fixed seed shown read-only (claimsgen.SEED; the seed stays fixed because the brief fixes it, do not add a seed input), the dataset checksum, and a button with key "rebuild" that runs rebuild_and_compare and shows success/failure. Use st.cache_data so the full dataset is not rebuilt on every interaction.

3) IMP-011 realism panel: `realism(tables)` returning plain data: claimed-amount histogram bins in USD with counts plus median/mean/p90, claim-type mix, policy status split at AS_OF, and the lag in days between incident and submission (bins 0,1,2,3,4-7,8-14,15+). New "Realism" tab in app.py with st.bar_chart / st.dataframe.

4) Show worker B's new metrics in the Metrics tab. B added to metrics.operational: `by_rule` {"R-COV-02/blocked": {effect, claims, amount_cents}}, `touchless` {assessed, touchless, reviewed, human_step, touchless_rate}, `approver_workload` {role: {settlements, amount_cents}}, `docs_pending_aging` {count, mean_days, median_days, p90_days, max_days, older_than_14_days}, `cycle_by_claim_type` {type: {paid_claims, median_days, p90_days}}; and sensitivity.sweep(tables, ground_truth) returns {"current": {...}, "approver": [rows], "fraud": [rows]} with rows {value, current, fraud_referred, flagged_amount_cents, approver_settlements, approver_amount_cents, precision, recall}. Extend view_data.metrics_panel to include `sensitivity` (the sweep re-runs the engine 8 times, so cache it in app.py per scale) and render all of these in the Metrics tab (amounts as USD).

TESTS: extend tests/test_view_data.py and add tests/test_view_trace.py: trace stop points equal the last assessment rule for claims of every stop type (denied by each COV rule, duplicate, docs pending, fraud, within deductible, limit reached, approved/paid), a resumed docs claim shows a re-run, counterfactual text mentions the right numbers for a deductible case and the missing document types for a docs case, checksum is stable and changes if a row changes, rebuild_and_compare is identical at scale 0.05, realism numbers add up (histogram counts sum to the claim count), and the headless AppTest (streamlit.testing.v1) exercises every tab, the scale selector, the rebuild button (app.button(key="rebuild").click().run()) with no exception. Use widget keys so AppTest can find them.

RULES: seeded randomness only, no clock, ground_truth only in the scoring panel (never for decisions, exceptions, trace or counterfactual), never use rm -rf, do not read anything under output/, no pip install, do NOT commit or run git commands other than read-only status/diff. The project's edit hook runs ruff and the whole pytest suite after each Python edit; ignore hook failures that are clearly not in your files, but at the end run `python -m ruff check . && python -m ruff format --check .` and `python -m pytest tests/test_view_data.py tests/test_view_trace.py -q` and make them pass. Final reply (max 15 lines): files changed, new function signatures, test results, anything you could not do.
```

### Session 1, 2026-10-30T16:48:36.609Z: claude on opus (Opus final audit of the repo)

```text
You are the FINAL AUDITOR (read-only) for the YottaFlex-ASG candidate project at C:\Users\<user>\Desktop\YottaFlex_ASG. Never edit, write, delete or commit anything. You may read files (Read/Grep/Glob), run `git log`, `git ls-files`, `git status`, `python -m pytest -q`, `python -m ruff check .` and `python scripts/verify.py 0.05`. Do not read anything under output/ (a permission rule blocks it anyway) and do not read ai-transparency/prompt-history/ if it exists.

Think first about what is actually wrong or risky for a reviewer, not what could be polished. Audit against three sources:
(1) docs/SPEC.md: deliverables 1-11, the six mandatory edge cases, review points a-g, pitfalls (label leakage, random outcomes, status overwrite, orphan FKs, clock/unseeded randomness, byte-unstable output).
(2) The organisation's submission guidelines: submit working executable code with clear steps to install, configure, run and verify; public GitHub repo with meaningful commits that show the evolution; transparent LLM use (prompt history required, where AI accelerated, what the human reviewed); visible reasoning (problem, assumptions, decisions, trade-offs, testing approach, limitations, how you know it works); FAQ: no secrets, credentials, personal or sensitive information, no proprietary code, document setup in the README, partial work is fine if stated.
(3) Honesty of claims: every number or claim in README.md, ai-transparency/README.md and docs/*.md should match the code and tests (for example test counts, row counts, scores, file names, commands). Look for stale or contradictory text left from earlier plan versions (docs/BRIEF_VS_PLAN.md, docs/DESIGN.md early sections, CLAUDE.md, docs/study/*), commands in the README that would fail on a fresh clone, and anything that breaks on Linux or in CI.
Also check: files over about 300 lines, secrets or personal data in tracked files (use git ls-files and Grep for e-mail addresses, tokens, local paths such as C:\Users, the machine username), tracked junk files, and whether the repo would run from a fresh clone with `pip install -e ".[dev,ui]"`.

Report format (terse, no praise, no restating the spec, max 50 lines):
1. Findings, most severe first. For each: where (file:line), what fails which source above, a one-line fix.
2. For each: quality impact (high/med/low), cost to fix (S/M/L tokens and minutes), verdict = DO NOW (high impact, S/M), DO LATER, or SKIP.
3. A short ordered "do now" list. If nothing clears the bar say "no changes needed" rather than padding.
Prefer cheap fixes that protect graded criteria.
```

### Session 3, 2026-10-30T10:43:58.961Z: Explore on haiku (Dig BenefitLens repo)

```text
Research task (read-only, web). Our project: a deterministic Python (stdlib-only) insurance claims workflow engine + synthetic dataset (intake -> coverage validation -> document request -> eligibility -> settlement routing; rule IDs like R-COV-02 with reason codes; append-only claim_status_history; duplicate-claim detection; payable = eligible - deductible, floor 0, capped at remaining limit; approver threshold). Dig into https://github.com/sumitmallick/BenefitLens (ClaimsIQ). Use WebFetch on github.com pages and raw.githubusercontent.com / api.github.com (e.g. https://api.github.com/repos/sumitmallick/BenefitLens, /contents, /commits?per_page=1). Report concisely (<350 words): license, last commit date, stars, language/stack, file layout of the rules engine, how rules/decisions/reason codes are structured, how deductible/limit/copay math is done, any test/metrics ideas, and 3-5 specific reusable ideas for us with file paths/URLs. Say clearly what you could not verify.
```

### Session 3, 2026-10-30T10:43:58.987Z: Explore on haiku (Dig ClaimOS repo)

```text
Research task (read-only, web). Our project: a deterministic Python (stdlib-only) insurance claims workflow engine + synthetic dataset (intake -> coverage validation -> document request -> eligibility -> settlement routing; rule IDs with reason codes; append-only claim_status_history; duplicate detection; exception list; per-claim timeline view; metrics). Dig into https://github.com/jamarius-fortson/ClaimOS. Use WebFetch on github.com pages, raw.githubusercontent.com and api.github.com (repo metadata, /contents, /commits?per_page=1). Report concisely (<350 words): license, last commit date, stars, stack, FNOL intake pipeline structure, document-request step, audit trail / traceability approach, exception handling, and 3-5 specific reusable ideas for us with file paths/URLs. Say clearly what you could not verify.
```

### Session 3, 2026-10-30T10:43:59.016Z: Explore on haiku (Dig SynthETIC and gen-syn)

```text
Research task (read-only, web). Our project: a deterministic Python (stdlib-only) synthetic insurance claims generator (2,000 policies, 1,000 claims, 5 claim types AUTO/HOME/HLTH/TRVL/LIAB) needing realistic right-skewed amounts, uneven claim-type mix, and realistic reporting/settlement delays. Dig into https://github.com/agi-lab/SynthETIC (R package) and https://www.github.com/kasaai/gen-syn. Use WebFetch on github.com, raw.githubusercontent.com, api.github.com. Report concisely (<350 words) for each: license, last commit, stars, language, which distributions/parameters are used for claim size, frequency, report delay, settlement delay (give concrete distribution names and parameter values we could port to Python `random.Random` e.g. lognormal mu/sigma), and 3-5 specific reusable ideas with file paths/URLs. Say clearly what you could not verify.
```

### Session 3, 2026-10-30T10:43:59.046Z: Explore on haiku (Find newer claims engine repos)

```text
Research task (read-only, web). Find NEWER GitHub repos (created or pushed since 2025-06; today is 2026-10-30) relevant to: insurance claims processing / adjudication / FNOL / claims workflow / rules engine with audit trail, in Python. Use WebFetch on the GitHub search API, e.g. https://api.github.com/search/repositories?q=insurance+claims+adjudication+language:python+pushed:%3E2025-06-01&sort=updated&per_page=15 and variants (fnol, "claims workflow", "claims rules engine", "claim settlement", "coverage verification"). Also try WebSearch. Return a table of the best 8-10 (url, stars, license, last push, one-line what it does, relevance 1-5 to a deterministic stdlib Python rules-driven claims workflow). Skip forks, empty repos, and anything already known: BenefitLens, ClaimOS. Flag any that look like AI-hype with no real code. <400 words.
```

### Session 3, 2026-10-30T10:43:59.073Z: Explore on haiku (Find newer synthetic claims repos)

```text
Research task (read-only, web). Find NEWER GitHub repos (created or pushed since 2025-06; today is 2026-10-30) relevant to: synthetic insurance claims datasets/generators (multi-table, joinable, deterministic/seeded), fraud/anomaly datasets WITH separate ground-truth labels, data-validation suites (PK/FK/enum/date-order/arithmetic checks), and reproducibility proofs (checksums). Use WebFetch on the GitHub search API, e.g. https://api.github.com/search/repositories?q=synthetic+insurance+claims+pushed:%3E2025-06-01&sort=updated&per_page=15 and variants (insurance fraud synthetic dataset, synthetic claims generator, claims data generator seed). Also try WebSearch. Return a table of the best 8-10 (url, stars, license, last push, one-line what it does, relevance 1-5 to a stdlib-only Python deterministic generator). Skip forks and empty repos; skip SDV, Synthea, SynthETIC, gen-syn (known). Flag hype/no-code repos. <400 words.
```

### Session 3, 2026-10-30T10:45:15.609Z: Explore on haiku (Dig plum and benefitPilot)

```text
Research task (read-only, web). Our project: deterministic stdlib-only Python claims workflow engine (intake -> coverage -> documents -> eligibility -> settlement routing; rule IDs like R-COV-02 + reason codes; append-only status history; exceptions list; metrics incl. precision/recall vs ground truth). Dig into https://github.com/Sneha-17660/plum-opd-adjudicator and https://github.com/yasaswinpalukuri/benefitPilot using api.github.com (repo, /git/trees/HEAD?recursive=1, /commits?per_page=1) and raw.githubusercontent.com. For each report (<300 words): license, last push, stack, whether the rules engine is truly deterministic (no LLM in the decision path), how rules/reason codes/audit trail are structured (file paths), test approach, and 3 concrete reusable ideas. Flag anything unverified or fake-looking.
```

### Session 3, 2026-10-30T10:45:15.625Z: Explore on haiku (Dig policyforge and blueeconomy)

```text
Research task (read-only, web). Our project: deterministic stdlib-only Python claims engine + synthetic dataset where derived values (totals, balances, reserves, payable = eligible - deductible floored at 0, capped at remaining limit) must reconcile exactly, and settlements above a threshold need an approver role. Dig into https://github.com/Mohith26/policyforge (integer-cents money, property tests) and https://github.com/munisp/blueeconomy-insurance (maker-checker, double-entry settlement, Apache-2.0) using api.github.com (repo, /git/trees/HEAD?recursive=1, /commits?per_page=1) and raw.githubusercontent.com. For each report (<300 words): license, last push, how money is represented and rounded, how reconciliation/invariants are tested, how maker-checker/approval thresholds are modelled (file paths), and 3 concrete reusable ideas. Flag anything unverified.
```

### Session 3, 2026-10-30T10:45:15.639Z: Explore on haiku (Dig openIMIS claim module)

```text
Research task (read-only, web). Our project: a synthetic claims dataset (11 entities: Customer, Policy, Coverage, Incident, Claim, ClaimItem, Document, Adjuster, Assessment, Reserve, Settlement + claim_status_history) and a rules engine. Dig into the openIMIS claim backend: https://github.com/openimis/openimis-be-claim_py (and openimis-be-claim_ai_py if it exists) using api.github.com (repo, /git/trees/HEAD?recursive=1) and raw.githubusercontent.com. Report (<350 words): license, last push, claim data model/status enum and lifecycle states, how claim review/rejection reasons (rejection codes) are modelled, how claim items/services are validated against coverage/limits, any duplicate detection, and 4 concrete ideas we can mirror in our schema/rule catalogue (with file paths). Flag anything unverified.
```

### Session 3, 2026-10-30T10:45:22.139Z: Explore on haiku (Dig Susmita claims generator)

```text
Research task (read-only, web). Our project: deterministic stdlib-only Python generator of an 11-entity joinable insurance claims dataset (2,000 policies, 1,000 claims, 5 claim types) with a SEPARATE ground_truth file of labelled edge cases (claim_before_policy_start, cancelled_before_incident, duplicate_incident, settlement_exceeds_limit, missing_mandatory_doc, paid_twice), validation report (PK/FK/enum/date-order/arithmetic) and same-seed reproducibility proof. Dig into https://github.com/Susmita-Dev-04/insurance-claims-synthetic-data-generator and also check https://github.com/SaiMokshagna/Insurance-claims-synthetic-data using api.github.com (repo, /git/trees/HEAD?recursive=1, /commits?per_page=1) and raw.githubusercontent.com. For each report (<350 words): license, last push, dependencies (requirements.txt contents), the 15 tables / entities, the 8 edge cases and how ground_truth.csv is structured, whether labels leak into input tables, how seeding/determinism is done, any validation script, and 3-4 concrete ideas for us (entities or edge cases we lack). Flag anything unverified or template-padded.
```

### Session 3, 2026-10-30T11:05:55.231Z: Explore on haiku (Find entries by distinctive IDs)

```text
Research task (read-only, web). Goal: find public GitHub repos that are OTHER people's submissions to the same take-home challenge as ours: a synthetic insurance claims dataset (11+ entities Customer/Policy/Coverage/Incident/Claim/ClaimItem/Document/Adjuster/Assessment/Reserve/Settlement; 2,000 policies, 1,000 claims, 5 claim types; IDs like POL-AUTO-2026-000001, CLM-2026-000001, DOC-CLM-2026-000001-001, SET-<claimid>-001, ASN-<claimid>-001; seed 20261022; six edge cases claim_before_policy_start, cancelled_before_incident, duplicate_incident, settlement_exceeds_limit, missing_mandatory_doc, paid_twice; ground_truth.csv; reproducibility checksums). Use WebFetch on the GitHub search API, e.g. https://api.github.com/search/repositories?q=<query>&sort=updated&per_page=20 with queries such as: "synthetic claims dataset generator", "claims synthetic data challenge", "insurance claims workflow synthetic", "claims ground_truth edge cases", "20261022", "claims edge cases paid twice", "duplicate incident settlement exceeds limit", and with topics. Also try https://api.github.com/search/code?q=... (may need auth; if 401/403 just say so) and WebSearch for the distinctive ID strings. Skip these already-known repos: Susmita-Dev-04/insurance-claims-synthetic-data-generator, SaiMokshagna/Insurance-claims-synthetic-data, hiox2004/YottaFlex-ASG, BenefitLens, ClaimOS, policyforge, blueeconomy-insurance, plum-opd-adjudicator, benefitPilot. Return a table (url, created, last push, license, stack, one-line description, how closely it matches the challenge 1-5), best 10, plus which search queries worked. <400 words. Flag unverified.
```

### Session 3, 2026-10-30T11:05:55.247Z: Explore on haiku (Find entries via workflow wording)

```text
Research task (read-only, web). Goal: find public GitHub repos (created since 2026-09-01; today is 2026-10-30) that are OTHER people's submissions to a take-home challenge whose objective is: "Build a working solution for this end-to-end workflow: Intake claims, validate policy coverage, request missing documents, assess eligibility and route for settlement. The solution should expose key decisions and exceptions, preserve traceability, and produce measurable outputs." Plus a synthetic dataset with a separate ground truth. Use WebFetch on the GitHub search API e.g. https://api.github.com/search/repositories?q=<query>+created:%3E2026-09-01&sort=updated&per_page=20 with queries like: "claims intake coverage documents eligibility settlement", "claims workflow dashboard exceptions decisions streamlit", "claims routing settlement rule engine synthetic data", "insurance claims workflow traceability metrics", "claims docs pending duplicate over-limit exceptions". Also WebSearch. Skip known repos: Susmita-Dev-04/insurance-claims-synthetic-data-generator, SaiMokshagna/Insurance-claims-synthetic-data, hiox2004/YottaFlex-ASG, BenefitLens, ClaimOS, policyforge, blueeconomy-insurance, plum-opd-adjudicator, benefitPilot. Return a table of the best 10 (url, created, last push, license, stack, one-line what it does, match 1-5; note if it has BOTH a dataset generator and a workflow engine/UI), and which queries worked. <400 words. Flag unverified.
```

### Session 3, 2026-10-30T11:05:55.268Z: Explore on haiku (Find entries on other platforms)

```text
Research task (read-only, web). Goal: find evidence of the take-home challenge itself and other people's entries beyond GitHub search. The challenge: build a deterministic synthetic insurance claims dataset (2,000 policies, 1,000 claims, 5 claim types, 11 entities, six mandatory edge cases e.g. claim date before policy start, policy cancelled before incident, duplicate incident, settlement exceeds limit, missing mandatory document, claim paid twice; separate ground truth; validation; reproducibility) plus a claims workflow solution. Use WebSearch (standard mode, several phrasings) for the challenge name/brief wording, and for blog posts, DEV.to/Medium/Hashnode/Kaggle/HuggingFace datasets/Gists/Streamlit apps/Notion write-ups of entries. Also WebFetch https://api.github.com/search/repositories?q=<q>&sort=updated with queries like "claims-synthetic", "synthetic-claims", "insurance-claims-dataset", "claims-workflow", topics, restricted to pushed:>2026-09-15, and https://api.github.com/search/users or gists if useful. Skip known repos: Susmita-Dev-04/insurance-claims-synthetic-data-generator, SaiMokshagna/Insurance-claims-synthetic-data, hiox2004/YottaFlex-ASG. Return: whether a public challenge page/brief exists (URL, who issues it, any published grading criteria or rubric — quote key criteria), plus up to 8 other entries found (url, platform, date, what it shows, match 1-5). <400 words. Flag unverified.
```

## WebFetch helper-model prompts

### Session 1, 2026-10-30T06:46:33.569Z: https://claude.ai/share/dfbc1c34-341f-4d2b-acf7-be71c13a9aad

```text
Return the full content of this shared conversation/artifact in detail: all requirements, specs, architecture, code, file structure, and any instructions.
```

### Session 1, 2026-10-30T07:39:07.439Z: https://code.claude.com/docs/en/model-config

```text
What environment variable or settings.json key sets the default model used by subagents (e.g. CLAUDE_CODE_SUBAGENT_MODEL)? Quote the exact name, accepted values, and where it goes (settings.json env block?). Also say whether a custom agent file can override a built-in agent like general-purpose.
```
