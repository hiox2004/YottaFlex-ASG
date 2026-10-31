# decide (`src/claimsgen/decide.py`)

**Purpose:** the decision step split out of `engine.py` (which had passed the 300-line rule): `Decision` and `evaluate(w, c, duplicate, resumed)`.
**Brief items:** coverage validation, document request, eligibility, settlement routing inputs; every outcome comes from a rule ID.

## Order (first failing step ends the path)
R-COV-01 -> R-COV-02 -> R-COV-03 -> R-ELG-03 -> R-DOC-01 (pend, records `missing`) -> R-FRD-05 -> R-ELG-01 -> R-ELG-02 -> R-PAY-01.
`resumed=True` skips everything before R-FRD-05 (late documents arrived).

| Name | Role | Gotcha |
|---|---|---|
| `Decision` | decision, rule, reason, eligible/deductible/payable cents, fraud score, payout detail, requested doc types | `score` is 0 on steps before the fraud step, by design |
| `evaluate` | reads the engine `World` (duck-typed, no import, so no cycle), never writes it | it must stay pure: `engine._process` owns all output rows and running state |

No behaviour change in the split: full and starter builds were byte-identical before and after.

## Tests
Covered through `tests/test_engine.py`, `tests/test_coverage_terms.py` and `tests/test_whatif.py` (they exercise `engine.run`).
