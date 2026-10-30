# engine (`src/claimsgen/engine.py`)

**Purpose:** pipeline step 4: runs the rules over every claim and writes `claim_adjuster_assignment`, `assessment`, `reserve`, `settlement`, `claim_status_history`.
**Brief items:** decisions derived from rules (rule 5), append-only history, reserve and settlement recommendations, adjuster assignment.

## Decision order (first failing step ends the path)
R-COV-01 -> R-COV-02 -> R-COV-03 -> R-ELG-03 duplicate -> R-DOC-01 -> R-FRD-05 -> R-ELG-02 -> R-PAY-01.
Outcomes: `deny`, `refer_review` (terminal), `pend_docs`, `approve`. Approved claims get a reserve, a settlement and approval/payment events.

| Function | Role | Gotcha |
|---|---|---|
| `World` | indexes all inputs; holds running state (`committed` limits, customer submission dates, seen duplicate keys, event counters) | claims are processed in `claim_id` order, so "earlier" is well defined |
| `evaluate(w, c, duplicate, resumed)` | returns a `Decision` | `resumed=True` skips coverage/duplicate/document checks after late documents arrive |
| `_assess` | writes an assessment and its history event together | a re-run after late docs becomes `ASM-...-002` |
| `_settle` | reserve (preliminary) + write-once settlement | approval/payment only if their dates are <= AS_OF; approver role if payable > threshold |
| `_resume_date` | date the last missing mandatory doc arrived | `None` if a document never arrived: the claim stays `docs_pending` |
| `run(tables)` | processes all claims | delays and a 5% reassignment come from the seeded `engine` stream, 4 draws per claim |

Recent claims honestly stay in an earlier status when the next step would be after AS_OF. `paid_twice` and `settlement_exceeds_limit` are not produced here; injection adds them.

## Tests
`tests/test_engine.py`: determinism, legal ordered history, catalogued rules, planted scenarios decided as intended, reconciliation of reserve/settlement, limits never exceeded, plausible outcome mix.
