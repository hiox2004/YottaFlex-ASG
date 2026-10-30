# policies (`src/claimsgen/policies.py`)

**Purpose:** pipeline step 2: policy, policy_event, policy_coverage. Status mix 75% in-force / 13% expired / 8% lapsed / 4% cancelled.
**Brief items:** in-force and lapsed policies (step 4), cancellation as an explicit event (step 4 of the rules), bridge table for N:M.

| Function | What it does | Gotcha |
|---|---|---|
| `_dates(rng, status, term)` | picks start (and lapse/cancel date) consistent with the chosen status | in-force policies always end on/after AS_OF; lapse/cancel dates are before end and <= AS_OF |
| `_specs(n, customer_ids)` | draws all policies, sorted by start date so older policies get lower IDs | first `len(customers)` policies give every customer one policy |
| `_coverages(...)` | 2-3 coverages per policy; ~10% start 7+ days after the policy | creates natural "outside coverage period" incidents later |
| `generate(master, scale)` | returns policy, policy_event, policy_coverage | events: `issued`, then `expired`/`lapsed`/`cancelled`; status is never stored |

Terms: 365 days (TRVL 30-90). Limits are catalogue defaults x {0.5, 1, 1.5, 2}; deductible stays below a quarter of the limit.
## Tests
`tests/test_generation.py`: status shares, event order, windows, deductible < limit, late-coverage share.
