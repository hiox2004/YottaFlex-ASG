# Improvements backlog (teacher -> builder)

Ideas found while studying or reviewing. The `teacher` agent appends here; the builder triages. Nothing here is a decision
until it moves into `docs/DESIGN.md` or `docs/SPEC.md`. `docs/SPEC.md` stays the source of truth.

## How to use
- Teacher: add one entry per finding under **Open**, newest last. Do not edit code or other docs.
- Builder: read **Open** before each step. When handled, move the entry to **Done** with the commit or **Rejected** with a reason.

## Entry format
```
### IMP-001 <short title>
- Area: design | rules | schema | validation | tests | docs | interview-risk
- Source: file:line or doc the finding came from
- Finding: what is weak, unclear, missing or risky
- Suggestion: concrete change
- Why it matters: reviewer/interview impact
- Priority: high | med | low
```

## Open

## Done

### IMP-001 Treat "expose decisions and exceptions" as core, not an optional UI
- Area: design
- Source: CLAUDE.md ("UI = single-file Streamlit, built last"), docs/BRIEF_VS_PLAN.md section 2
- Finding: the brief asks for a working solution for intake -> coverage validation -> document request -> eligibility ->
  settlement routing that exposes key decisions and exceptions, keeps traceability, and produces measurable outputs. Our plan
  frames the UI as an extra and the dataset as the product, so the workflow may be judged as not demonstrable.
- Suggestion: keep the UI small but in scope: decisions table with rule ID/reason, exceptions list (docs_pending, duplicate,
  over-limit, paid twice), per-claim history view, metrics panel. Confirm scope against the original brief text.
- Why it matters: a reviewer may open the repo expecting to see the workflow running, not only CSVs.
- Priority: high
- Resolution: done in commit 864bc54 (docs(scope)); SPEC deliverable 11 added, view is core scope, build order export -> metrics -> view.

### IMP-005 Fill README review-point evidence table
- Area: docs
- Source: README.md ("Status: scaffold only"; points a-f are TODO)
- Finding: the README is the first thing a reviewer reads and still claims nothing is built.
- Suggestion: link each review point a-g to a concrete report line, test or script, and update Status. Note that 10-30 rows per case applies at full scale.
- Why it matters: reviewer-checkable proof is a stated deliverable requirement.
- Priority: high
- Resolution: README rewritten as a reviewer's guide with the review-point evidence table, status and the 10-30 rows per case note (commit a62674e, docs(readme)).

### IMP-010 Known limitations section
- Area: docs
- Source: docs/DESIGN.md (under_review terminal; hand-chosen constants)
- Finding: limits are scattered across DESIGN decisions.
- Suggestion: one README section: under_review is terminal, thresholds are hand-chosen, fully synthetic, no reopen/appeal flow, fraud flags are simple heuristics.
- Why it matters: stating limits first is stronger than being caught on them.
- Priority: med
- Resolution: README 'Known limits' section extended with hand-chosen thresholds, no reopen/appeal flow and heuristic fraud flags (commit 610284f).

### IMP-012 CI runs the proof
- Area: tests
- Source: .github, scripts/verify.py
- Finding: reproducibility is proven locally only.
- Suggestion: CI job runs `pytest -q`, ruff, and `scripts/verify.py`.
- Why it matters: reproducibility shown on every push.
- Priority: low
- Resolution: CI runs ruff, pytest and scripts/verify.py 0.05 on every push (commits 1cbb481 and 6241e72).

### IMP-002 Break validator/engine circularity
- Area: validation
- Source: docs/DESIGN.md "Reviewer checkpoint 2" DO LATER (validator shares rules.payable with the engine); src/claimsgen validator
- Finding: the validator replays `rules.payable`, the same function the engine uses. A wrong formula passes both, so "failing ids == integrity-defect ids" proves less than it appears.
- Suggestion: add hand-computed payable fixtures (deductible, cap, remaining limit, zero floor) and a small independent re-implementation in tests that is compared against `rules.payable` on the generated data.
- Why it matters: "isn't your validator just your engine?" is a likely reviewer/interview question.
- Priority: high
- Resolution: done in commit c37988e (test(validate)): independent payable reference written from the spec plus hand-computed fixtures; the full-scale replay matches every approving assessment and every non-defect settlement.

### IMP-003 Prove the evaluation can fail (mutation test)
- Area: tests
- Source: docs/DESIGN.md Validation/Metrics; ground_truth expected decisions are derived from the same rules as the engine
- Finding: precision/recall vs ground_truth can be perfect by construction; nothing shows the metrics would detect a bad engine.
- Suggestion: test that deliberately breaks one rule (e.g. R-COV-02 semantics or the deductible) and asserts precision/recall or validator failures change; report the result in the validation summary.
- Why it matters: shows the evaluation is meaningful, not tautological.
- Priority: high
- Resolution: done in commit 79f704c (test(metrics)): mutation tests; ignoring cancel/lapse, ignoring the deductible and a zero document window each move the scores.

### IMP-004 Non-target claims unchanged by injection
- Area: tests
- Source: docs/study/LOG.md fix(inject) DO LATER; CLAUDE.md ("without touching unrelated rows")
- Finding: the rule is stated but not tested as a before/after comparison.
- Suggestion: build baseline, snapshot rows for non-target claims and their children, inject, assert those rows are byte-identical.
- Why it matters: directly tests a stated hard rule; an unrelated-row change would fail a criterion.
- Priority: high
- Resolution: done in commit 2473765 (test(inject)): every non-target claim is identical before and after injection at starter and full scale.

### IMP-006 Per-claim "why" drill-down in the view
- Area: design
- Source: SPEC deliverable 11; docs/DESIGN.md rule catalogue
- Finding: the view shows decisions but not the path of rules a claim went through.
- Suggestion: for a selected claim show the rule trace (each R-xxx passed/failed in order, stop point, reason code, actor) from claim_status_history, plus the counterfactual (what would make it payable).
- Why it matters: makes traceability readable to a claims manager; strongest demo of "expose key decisions and exceptions".
- Priority: high
- Resolution: done in commit b8e1e8d (feat(view)): rule trace and counterfactual (src/claimsgen/view_trace.py) in the Claim timeline tab.

### IMP-007 Business-outcome metrics, not only accuracy
- Area: design
- Source: docs/DESIGN.md Metrics
- Finding: planned metrics lean on precision/recall; clients judge on money and time.
- Suggestion: add amount blocked/saved by rule, touchless rate (no human review), approver workload, docs_pending aging, cycle time by claim type.
- Why it matters: connects the technical output to the client's leakage and cycle-time pain.
- Priority: high
- Resolution: done in commit f6f3d48 (feat(metrics)): money effect by rule, touchless rate, approver workload, docs-pending aging, cycle time by claim type; shown in metrics.md and the Metrics tab (b8e1e8d).

### IMP-008 Threshold sensitivity table
- Area: design
- Source: config APPROVER_THRESHOLD, fraud cutoff 0.5
- Finding: thresholds are fixed with no trade-off shown.
- Suggestion: sweep approver threshold and fraud-score cutoff; show review workload vs flagged/blocked amount (and precision/recall where labels exist).
- Why it matters: shows judgement about trade-offs.
- Priority: med
- Resolution: done in commit f6f3d48 (feat(metrics)): src/claimsgen/sensitivity.py sweep in metrics.md; shown in the Metrics tab (b8e1e8d).

### IMP-009 Seed/scale controls and live checksum in the view
- Area: design
- Source: SPEC deliverable 10
- Finding: determinism is claimed in a script, not visible in the product.
- Suggestion: seed and scale inputs in the view, with the dataset checksum displayed and a "rebuild and compare" action.
- Why it matters: makes reproducibility demonstrable live.
- Priority: med
- Resolution: done in part in commit b8e1e8d: scale selector, live dataset checksum and a rebuild-and-compare button. The seed input was rejected (see Rejected).

### IMP-011 Realism panel
- Area: validation
- Source: review point (a)
- Finding: distributions are asserted in the summary but not shown.
- Suggestion: view panel with claimed-amount distribution, claim-type mix, policy status split, lag between incident and submission.
- Why it matters: makes review point (a) visible.
- Priority: low
- Resolution: done in commit b8e1e8d (feat(view)): Realism tab (amount histogram, type mix, policy status, incident-to-submission lag).

### IMP-013 Docs that disagree with the code (found while writing the code walkthrough)
- Area: docs
- Source: code walkthrough workers, 2026-10-31 (each item checked against the code)
- Finding: the code is right in every case below; the docs are stale or loose.
  - `docs/study/modules/rules.md` says the RULES catalogue has 14 IDs; `rules.py` has 16.
  - `docs/DESIGN.md` "Engine decisions" says initial assignment is "least-loaded by specialty"; `engine._assign` picks from the claim's own random stream (Reviewer checkpoint 2 says so).
  - `engine.py:218` comment says "three draws per claim, always"; `_process` makes six draws (three at :219, three at :220).
  - `docs/DESIGN.md` says `whatif` passes the fraud and approver thresholds to `engine.run`; `whatif.py` passes only `as_of`.
  - `docs/study/modules/intake.md` names `_incident_types`; the code function is the public `incident_types`.
  - `docs/study/modules/export.md` says CSV uses `newline=""`; the code writes bytes with `lineterminator="\n"` (same result).
  - `docs/DESIGN.md` and `view_data.md` name `export._csv`; the function is `export.csv_text`. `view_data.md` says the AppTest covers six tabs; `app.py` builds eight.
- Suggestion: correct each line (and add a LOG.md line). No behaviour change.
- Why it matters: a reviewer reading the notes and then the code will notice; the notes are what you study from.
- Priority: med
- Resolution: done in commit 797fa55 (docs(study)). Six of the seven claims were true. The `export._csv` claim was true for view_data.md only; DESIGN.md never named it. Comment-only engine change; verify.py checksums unchanged.

### IMP-014 Two boundary labels are scored with identical logic
- Area: validation
- Source: `src/claimsgen/scoring.py:57-62`
- Finding: `boundary_incident_on_start` and `boundary_incident_on_end` both use `a["rule_id"] not in COVERAGE_RULES`, so they always get the same predicted set; `boundary_amount_at_limit` checks only `decision == "approve"`, not the amount. Both are recall-only rows, so the numbers are not wrong, but they are weaker checks than the labels suggest.
- Suggestion: either document them as "decided as expected" checks, or make each check its own condition (incident date equals policy start or end; claimed amount equals the coverage limit).
- Why it matters: "boundary recall 1.00" is quoted in interviews; it should mean what it says.
- Priority: med
- Resolution: done in commit 4cb991e (fix(metrics)). Each boundary prediction now also tests its own input condition (incident date equals policy start/end; an item equals its coverage limit). Scores unchanged: full 9/10, 10/10, 10/10; starter 1/1, 1/1, 0/1. `boundary_amount_at_deductible` still checks the decision only; documented in scoring.md.

### IMP-015 Small robustness items
- Area: tests
- Source: `src/claimsgen/intake_examples.py` (`_normal` calls `next()` with no default, so no candidate raises `StopIteration` while the other drafters raise `LookupError`); `src/claimsgen/metrics.py` (`statistics.mean`/`median` in `operational()` have no guard for an empty list of days); `app.py:42` (the as-of date text is typed in, not read from `config.AS_OF`).
- Finding: none fails on today's data (starter and full both build and pass); each would fail or go stale on an unusual dataset or after a config change.
- Suggestion: raise the same error type everywhere in intake_examples; guard empty lists in metrics; build the sidebar text from `config.AS_OF`.
- Why it matters: cheap hardening; shows attention to edge cases.
- Priority: low
- Resolution: done in commit 7399082 (fix(view)). intake_examples raises LookupError everywhere, metrics day statistics guard empty lists, sidebar as-of text is built from config.AS_OF; tests added.

## Rejected

### IMP-009 (seed input only)
- Reason: the brief fixes the seed at 20261022 and `generate.build` accepts only that seed, so a seed control would contradict the brief. The view shows the seed read-only; scale, checksum and rebuild-and-compare were built.
