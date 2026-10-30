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

Suggested order: IMP-002..005 (credibility of the numbers) -> IMP-006..007 (expose layer) -> run the Opus final audit -> IMP-008..012.

### IMP-002 Break validator/engine circularity
- Area: validation
- Source: docs/DESIGN.md "Reviewer checkpoint 2" DO LATER (validator shares rules.payable with the engine); src/claimsgen validator
- Finding: the validator replays `rules.payable`, the same function the engine uses. A wrong formula passes both, so "failing ids == integrity-defect ids" proves less than it appears.
- Suggestion: add hand-computed payable fixtures (deductible, cap, remaining limit, zero floor) and a small independent re-implementation in tests that is compared against `rules.payable` on the generated data.
- Why it matters: "isn't your validator just your engine?" is a likely reviewer/interview question.
- Priority: high

### IMP-003 Prove the evaluation can fail (mutation test)
- Area: tests
- Source: docs/DESIGN.md Validation/Metrics; ground_truth expected decisions are derived from the same rules as the engine
- Finding: precision/recall vs ground_truth can be perfect by construction; nothing shows the metrics would detect a bad engine.
- Suggestion: test that deliberately breaks one rule (e.g. R-COV-02 semantics or the deductible) and asserts precision/recall or validator failures change; report the result in the validation summary.
- Why it matters: shows the evaluation is meaningful, not tautological.
- Priority: high

### IMP-004 Non-target claims unchanged by injection
- Area: tests
- Source: docs/study/LOG.md fix(inject) DO LATER; CLAUDE.md ("without touching unrelated rows")
- Finding: the rule is stated but not tested as a before/after comparison.
- Suggestion: build baseline, snapshot rows for non-target claims and their children, inject, assert those rows are byte-identical.
- Why it matters: directly tests a stated hard rule; an unrelated-row change would fail a criterion.
- Priority: high

### IMP-006 Per-claim "why" drill-down in the view
- Area: design
- Source: SPEC deliverable 11; docs/DESIGN.md rule catalogue
- Finding: the view shows decisions but not the path of rules a claim went through.
- Suggestion: for a selected claim show the rule trace (each R-xxx passed/failed in order, stop point, reason code, actor) from claim_status_history, plus the counterfactual (what would make it payable).
- Why it matters: makes traceability readable to a claims manager; strongest demo of "expose key decisions and exceptions".
- Priority: high

### IMP-007 Business-outcome metrics, not only accuracy
- Area: design
- Source: docs/DESIGN.md Metrics
- Finding: planned metrics lean on precision/recall; clients judge on money and time.
- Suggestion: add amount blocked/saved by rule, touchless rate (no human review), approver workload, docs_pending aging, cycle time by claim type.
- Why it matters: connects the technical output to the client's leakage and cycle-time pain.
- Priority: high

### IMP-008 Threshold sensitivity table
- Area: design
- Source: config APPROVER_THRESHOLD, fraud cutoff 0.5
- Finding: thresholds are fixed with no trade-off shown.
- Suggestion: sweep approver threshold and fraud-score cutoff; show review workload vs flagged/blocked amount (and precision/recall where labels exist).
- Why it matters: shows judgement about trade-offs.
- Priority: med

### IMP-009 Seed/scale controls and live checksum in the view
- Area: design
- Source: SPEC deliverable 10
- Finding: determinism is claimed in a script, not visible in the product.
- Suggestion: seed and scale inputs in the view, with the dataset checksum displayed and a "rebuild and compare" action.
- Why it matters: makes reproducibility demonstrable live.
- Priority: med

### IMP-011 Realism panel
- Area: validation
- Source: review point (a)
- Finding: distributions are asserted in the summary but not shown.
- Suggestion: view panel with claimed-amount distribution, claim-type mix, policy status split, lag between incident and submission.
- Why it matters: makes review point (a) visible.
- Priority: low

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
- Resolution: README 'Known limits' section extended with hand-chosen thresholds, no reopen/appeal flow and heuristic fraud flags (commit: to be filled by the orchestrator).

### IMP-012 CI runs the proof
- Area: tests
- Source: .github, scripts/verify.py
- Finding: reproducibility is proven locally only.
- Suggestion: CI job runs `pytest -q`, ruff, and `scripts/verify.py`.
- Why it matters: reproducibility shown on every push.
- Priority: low
- Resolution: CI runs ruff, pytest and scripts/verify.py 0.05 on every push (commits 1cbb481 and 6241e72).

## Rejected

_(none yet)_
