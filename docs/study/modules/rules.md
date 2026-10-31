# rules (`src/claimsgen/rules.py`)

**Purpose:** the rule catalogue (`RULES`, 14 IDs with text), the legal claim-status `TRANSITIONS`, and the pure functions the engine calls.
**Brief items:** "every decision has a reason and audit trail" (rule IDs), coverage checks follow policy rules, reserves and settlements obey limits and deductibles (review d).

| Function | Rule | Gotcha |
|---|---|---|
| `in_force(policy, ends, day)` | R-COV-02 | in force iff start <= day <= end and no lapse/cancel on or before day; the `expired` event is informational |
| `covered(coverages, day)` | R-COV-03 | inclusive dates; every claimed coverage must cover the incident |
| `missing_docs(required, docs, submission)` | R-DOC-01 | a doc counts only if received within `DOC_WINDOW_DAYS` of submission |
| `fraud_flags(...)` | R-FRD-01..04 | F2 counts only EARLIER claims by the customer, inclusive 90-day window |
| `covered_items(items, incident_type, terms)` | R-ELG-01 | an item is kept only if the claim's incident type and the item type are in the coverage's `covered_*` lists; the engine denies `not_covered` when none remain |
| `eligible_by_coverage(items, exclusions)` | R-ELG-02 | excluded item types contribute nothing |
| `fnol_reserve(items, pcv_by_cov)` | R-RSV-01 | claimed per coverage capped at the coverage limit (not the remaining limit), summed; the validator recomputes it with the same function |
| `payable(eligible, pcv_by_cov, committed)` | R-PAY-01 | per coverage `min(max(0, eligible - deductible), remaining)`; remaining = limit minus amounts already recommended on earlier claims |

`TRANSITIONS` is the single legal-transition table; the validator will reuse it.
Fraud score is `flags / 4`; `R-FRD-05` (score >= 0.5) is the decision rule.

## Tests
`tests/test_engine.py` (catalogue coverage, transitions, reconciliation). Boundary checks live in the planted-scenario test.
