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

## Done

_(none yet)_

## Rejected

_(none yet)_
