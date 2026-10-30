# claims (`src/claimsgen/claims.py`)

**Purpose:** pipeline step 3: incident, claim, claim_item, document, plus the planted baseline scenarios.
**Brief items:** step 4 baseline conditions (lapsed, outside coverage, incomplete evidence, over limit, fraud indicators, duplicates), boundary cases (review e), right-skewed amounts (review a).

## Idea
A claim is first a `Spec` (policy, incident date/type, submission date, items, docs). Normal specs are drawn inside the policy and coverage windows. Special scenarios are built with deliberate *inputs*; the outcome (deny, pend, review) comes from the rules engine later, never from here.

| Scenario | How it is planted |
|---|---|
| lapsed_policy | incident after the policy's lapse date |
| outside_coverage_period | incident before a late-starting policy_coverage |
| incomplete_evidence | one mandatory doc absent, or present but received 10-30 days late |
| claim_over_limit | single item at 1.1-1.6x the coverage limit |
| suspected_fraud | incident within 20 days of start, amount 95-100% of limit |
| duplicate_incident | clone of a normal claim (same policy/date/type), submitted 1-20 days later |
| boundary_* | incident on start/end date; amount exactly at limit or at deductible |

Shared helpers (`Spec`, `Ctx`, windows, items, docs) live in `claim_build.py`; this module has the scenario builders, duplicates and assembly.

## Key functions
| Function | Role | Gotcha |
|---|---|---|
| `BUILDERS` | one builder per scenario name | each returns `None` when the drawn policy cannot support it; `_draw` retries |
| `_duplicate` | clones a normal claim, submitted 1-20 days later | the clone's `detail` is the source claim ID |
| `_assemble` | sorts by (submission, incident, policy) then assigns IDs | injection step must renumber after adding claims |
| `generate` | returns `(tables, planted)` | `planted` is never joined into input tables; later feeds ground_truth |

Counts come from `config.scenario_counts`; baseline claims = claims - `inject_rows(scale)` so injected duplicates keep the total at 1,000.

## Tests
`tests/test_claims.py`: each scenario property, normal-claim cleanliness, ID order, skew, determinism.
