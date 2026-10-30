# whatif (`src/claimsgen/whatif.py`)

**Purpose:** run a claim submitted through intake (a `Draft`, see `draft.py`) through the real engine as a what-if, without changing the dataset.
**Brief items:** decisions derived from rules, per-claim timeline and rule trace, counterfactual.

## How it works
`evaluate` copies the input lists (the five engine output tables are dropped), appends one provisional incident, claim, items and documents, and calls `engine.run(inputs, as_of=horizon_for(draft))`. Only the provisional claim's rows are read back. The engine does not mutate input rows, so a shallow copy is enough. The engine order is (submission_date, incident_date, policy_id, claim_id); the provisional ids `CLM-2026-999999` / `INC-2026-999999` only break complete ties.

| Function | Role | Gotcha |
|---|---|---|
| `evaluate(tables, draft)` | dict: `claim, incident, decision, timeline, rule_trace, counterfactual, assessments, reserve, settlement, assignments, history, horizon, missing_documents, note` | `decision` has the shape of a `view_data.decisions_table` row |
| `missing_documents(tables, draft)` | mandatory types not received within `DOC_WINDOW_DAYS` of submission | uses `rules.missing_docs`, so a rejected or late document counts as missing |
| `horizon_for(draft)` | `max(config.intake_horizon(), submission_date + 21 days)` | 21 days covers assessment (5), approval (3), payment (5) and the documents path, so late drafts are never cut off |
| `request_docs(tables, draft, day=None)` | new draft with the missing documents received on `day` | stops adding at `intake.MAX_DOCS`; default is submission + window + 1 (capped at `horizon_for(draft)`): inside the window it would only delay the first assessment instead of producing `docs_pending` |

## Gotchas
- Existing claims submitted LATER than the draft ARE processed but their outcomes are not shown, so the draft's effect on them (shared limit, duplicate key) is invisible. `note` says so.
- The whole dataset advances to the horizon, so real claims still pending at `AS_OF` can consume limits before the draft does.
- The horizon is later than `AS_OF`, so a draft submitted on `AS_OF` still shows its whole workflow; the dataset itself still ends at `AS_OF`.
- Coverage checks are the engine's, not intake's: a draft submitted before policy start is denied by R-COV-01.
- ground_truth is never used.

## Tests
`tests/test_whatif.py`: dataset checksum unchanged, deterministic, base outputs reproduce, clean approval with approver role, docs_pending then resume (`ASM-...-002`), R-COV-01, R-ELG-03 duplicate, draft submitted on the horizon is paid, request_docs near the horizon, approver route on both sides of the threshold, lapsed policy R-COV-02.
