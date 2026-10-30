# flagmix (`src/claimsgen/flagmix.py`)

**Purpose:** count how often each fraud indicator (F1-F4) and each combination fires on a dataset, so the report can show that the flags are not all planted.
**Pipeline stage:** reporting, after the engine; read by `metrics.to_markdown` (the "Fraud flag counts" line) and by `tests/test_realism.py`.
**Brief items served:** meaningful evaluation metrics; honesty about what the fraud row measures.

## Inputs and outputs
- Takes: the dataset tables (`claim`, `incident`, `policy`, `policy_coverage`, `claim_item`). No ground_truth.
- Produces: `{"claims": n, "flags": {"F1": k, "F2": k, "F3": k, "F4": k}, "combos": {"F1+F3": k, ..., "none": k}}`.

## Key functions
| Function | What it does | Why it exists / gotcha |
|---|---|---|
| `flag_counts(tables)` | calls `rules.fraud_flags` for every claim, in the engine's processing order (submission date, incident date, policy, claim id), with the customer's earlier submissions | uses the same function and order as the engine, so F2 matches what the engine saw; it does not read the assessment's fraud score |

## Rules / invariants it must keep
- No labels, no clock, no randomness; combos are sorted so the report text is stable.

## Worked example
At full scale: F1 163 (16.3%), F2 7, F3 70 (7.0%), F4 18 (1.8%); combinations F1 133, F1+F3 30 (the planted fraud), F2 7, F3 40, F4 18, none 772.

## How to test / inspect
`tests/test_realism.py` (F4 share, F1 share); the line is printed in `metrics.md`.

## Open questions / next
- F1 stays about 16% of all claims: 5.5% are early by construction (planted fraud, before-start and on-start claims) and about 11% is organic.
