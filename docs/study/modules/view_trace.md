# view_trace (`src/claimsgen/view_trace.py`)

**Purpose:** per-claim rule trace and counterfactual for the view: which rules a claim passed, where it stopped, and what would make it payable.
**Pipeline stage:** after the engine; read-only over the dataset tables. Re-exported by `view_data`.
**Brief items served:** traceability and exceptions (SPEC deliverable 11, IMP-006).

## Inputs and outputs
- Takes: `tables` and a `claim_id` (never ground_truth).
- Produces: a list of trace rows (`rule_id`, `description`, `outcome`, `date`, `actor_role`, `reason_code`, `run`) and a list of plain-language strings.

## Key functions
| Function | What it does | Why it exists / gotcha |
|---|---|---|
| `rule_trace(tables, claim_id)` | Ordered path R-COV-01, 02, 03, R-ELG-03, R-DOC-01, R-FRD-05, R-ELG-02, R-PAY-01, R-RSV-01, R-APR-01 with passed / failed-and-stopped / not evaluated | Derived only from the claim's assessments and status history. A docs_pending claim that resumed shows R-DOC-01 and later steps with the re-run date |
| `counterfactual(tables, claim_id)` | What would unblock the claim, from input rows and `rules.*` functions | Approved claims say they are already payable; unassessed claims say the assessment is still due |

## Rules / invariants it must keep
- No ground_truth parameter (a test checks the signatures). No clock, no randomness.
- The stop step equals the rule of the claim's last assessment.

## Worked example
A claim denied by R-PAY-01 / within_deductible: COV, ELG-03 and DOC steps passed, FRD-05 and ELG-02 passed, PAY-01 failed-and-stopped, RSV and APR not evaluated; the counterfactual says the claimed amount must exceed the deductible.

## How to test / inspect
`tests/test_view_trace.py`; the Claim timeline tab of `app.py`.

## Open questions / next
Limit-reached text uses policy-level earlier settlements (settlements carry no coverage id).
