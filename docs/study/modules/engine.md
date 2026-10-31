# engine (`src/claimsgen/engine.py`)

**Purpose:** pipeline step 4: runs the rules over every claim and writes `claim_adjuster_assignment`, `assessment`, `reserve`, `settlement`, `claim_status_history`.
**Brief items:** decisions derived from rules (rule 5), append-only history, reserve and settlement recommendations, adjuster assignment.

## Decision order (first failing step ends the path)
R-COV-01 -> R-COV-02 -> R-COV-03 -> R-ELG-03 duplicate -> R-DOC-01 -> R-FRD-05 -> R-ELG-01 (coverage terms, `not_covered`) -> R-ELG-02 -> R-PAY-01.
Outcomes: `deny`, `refer_review` (terminal), `pend_docs`, `approve`. Approved claims get a reserve, a settlement and approval/payment events.

| Function | Role | Gotcha |
|---|---|---|
| `World` | indexes all inputs; holds running state (`committed` limits, customer submission dates, seen duplicate keys, event counters) | claims are processed in (submission, incident, policy) date order, so "earlier" is well defined |
| `evaluate(w, c, duplicate, resumed)` | returns a `Decision` | `resumed=True` skips coverage/duplicate/document checks after late documents arrive |
| `_assess` | writes an assessment and its history event together; on pend_docs it records the requested document types in `missing_doc_types` (pipe list, empty otherwise) | a re-run after late docs becomes `ASM-...-002` |
| `_settle` | reserve (preliminary) + write-once settlement | approval/payment only if their dates are <= AS_OF; approver role if payable > threshold |
| `_resume_date` | date the last missing mandatory doc arrived | `None` if a document never arrived: the claim stays `docs_pending` |
| `run(tables, as_of=None, *, fraud_threshold=None, approver_threshold_cents=None)` | processes all claims in date order (per-claim delays: `config.ASSESS_DAYS` by product, `APPROVAL_DAYS` by approver role; a resume after a pend is dated `max(late document arrival, pend date + 1 day)`); `as_of` (default `config.AS_OF`) and the two thresholds (defaults read from config when `World` is created) are stored on `World` and used for every cut-off, fraud referral and approver routing; `sensitivity.py` passes the thresholds as arguments | config is never mutated, so threads can use different dates; a resume after docs arrive also stops if its day is after `as_of`. Used by `whatif.py` with the intake horizon | each claim has its own RNG stream seeded from its stable fields (delays, 5% reassignment, adjuster picks), so adding a claim does not shift others |
| `_ready_date` | latest in-window document arrival | an assessment is never dated before these documents exist |

Recent claims honestly stay in an earlier status when the next step would be after AS_OF. `paid_twice` and `settlement_exceeds_limit` are not produced here; injection adds them.

## Tests
`tests/test_engine_asof.py`: default `as_of` is byte-identical (starter and full), a later one progresses claims, an earlier one stops them.
`tests/test_engine.py`: determinism, legal ordered history, catalogued rules, planted scenarios decided as intended, reconciliation of reserve/settlement, limits never exceeded, plausible outcome mix.
