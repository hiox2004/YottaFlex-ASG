# Learning / change log (newest first)

Add a line per step: date, commit scope, what it taught or changed, which notes were updated.

- 2026-10-30 `fix(inject)` Opus checkpoint 3 (DO NOW): duplicate filter with 15 days of room, policy_event re-sorted in finalize, orphan/row-count asserts, machine-readable expected_decision words, clearer settlement wording, tests parametrized over starter and full. DO LATER: non-target claims unchanged before/after injection; weaker-test cleanups; hand-computed payable fixtures (validator shares rules.payable with the engine); README note that 10-30 rows per case applies at full scale.
- 2026-10-30 `docs(scope)` scope correction: working workflow + minimal expose layer is core (SPEC deliverable 11, IMP-001); build order export -> metrics -> view; reviewer only for design review and final audit.
- 2026-10-30 `feat(inject)` six labelled cases on isolated targets, engine re-run for business cases and post-engine patches for the two defects, single-map ID finalize, ground_truth. Result: 1,000 claims, validator failing ids == the 30 integrity defects exactly. Notes: inject, finalize, ground_truth, generate.
- 2026-10-30 `feat(validate)` 12 checks on 290k rows, zero baseline failures; mutation tests prove each defect type is caught on the right id. Notes: checks_structure, checks_business, validate.
- 2026-10-30 `fix(rules)` Opus checkpoint 2 (DO NOW): date-ordered processing, per-claim RNG (decouples claims for injection), reassignment guard, assessment after in-window docs, fraud_score only at the fraud step, DESIGN corrections. DO LATER items in DESIGN 'Reviewer checkpoint 2'.
- 2026-10-30 `feat(rules)` rules catalogue + engine: decisions, history, assignments, reserves, settlements derived from rules. Learned: claimed == limit is paid below the limit (deductible); a capped over-limit claim can be denied when earlier claims used the limit. Notes: rules, engine.
- 2026-10-30 `fix(gen)` Opus checkpoint 1 (DO NOW): R-COV-02 semantics, DOC_WINDOW_DAYS, fraud constants, flag-isolated limit cases, unique (policy, incident_date). DO LATER items are in DESIGN 'Reviewer checkpoint 1'.
- 2026-10-30 `feat(gen)` claims: incidents, claims, items, documents + planted baseline scenarios (returned separately, never in input tables). Notes: claims, config, masterdata.
- 2026-10-30 `feat(gen)` config/ids/masterdata/policies: seeded master data + 2,000 policies with events and bridge rows. Notes: config, ids, masterdata, policies.
- 2026-10-30 `feat(schema)` 17-table spec in code; dictionary + SQL rendered from it (drift test). Split vocab/schema/schema_docs to stay near 300 lines. Notes: vocab, schema, schema_docs.
- 2026-10-30 `docs(study)` created this guide; notes for package and scripts.
- 2026-10-30 `docs` DESIGN v2 after Opus review: write-once settlement, IDs assigned after injection, per-coverage payable, disjoint injection targets.
- 2026-10-30 `chore(tooling)` scaffold, guardrails, commit conventions, CI.
