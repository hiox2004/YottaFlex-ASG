# whatif (`src/claimsgen/whatif.py`)

**Purpose:** run a claim submitted through intake (a `Draft`, see `draft.py`) through the real engine as a what-if, without changing the dataset.
**Brief items:** decisions derived from rules, per-claim timeline and rule trace, counterfactual.

## How it works
`evaluate` copies the input lists (the five engine output tables are dropped), appends one provisional incident, claim, items and documents, and calls `engine.run(inputs, as_of=config.intake_horizon())`. Only the provisional claim's rows are read back. The engine does not mutate input rows, so a shallow copy is enough. Ids `CLM-2026-999999` / `INC-2026-999999` sort after every real id, so same-day ties go to real claims.

| Function | Role | Gotcha |
|---|---|---|
| `evaluate(tables, draft)` | dict: `claim, incident, decision, timeline, rule_trace, counterfactual, assessments, reserve, settlement, assignments, history, horizon, missing_documents, note` | `decision` has the shape of a `view_data.decisions_table` row |
| `missing_documents(tables, draft)` | mandatory types not received within `DOC_WINDOW_DAYS` of submission | uses `rules.missing_docs`, so a rejected or late document counts as missing |
| `request_docs(tables, draft, day=None)` | new draft with the missing documents received on `day` | default is submission + window + 1 (capped at the horizon): inside the window it would only delay the first assessment instead of producing `docs_pending` |

## Gotchas
- Existing claims submitted LATER than the draft are not shown even if the draft would change their outcome (shared limit, duplicate key): the engine processes in date order. `note` says so.
- The horizon is later than `AS_OF`, so a draft submitted on `AS_OF` still shows its whole workflow; the dataset itself still ends at `AS_OF`.
- Coverage checks are the engine's, not intake's: a draft submitted before policy start is denied by R-COV-01.
- ground_truth is never used.

## Tests
`tests/test_whatif.py`: dataset checksum unchanged, deterministic, base outputs reproduce, clean approval with approver role, docs_pending then resume (`ASM-...-002`), R-COV-01, R-ELG-03 duplicate, horizon.
