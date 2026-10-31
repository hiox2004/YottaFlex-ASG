# claims (`src/claimsgen/claims.py`)

**Purpose:** pipeline step 3: incident, claim, claim_item, document, plus the planted baseline scenarios.
**Brief items:** step 4 baseline conditions (lapsed, outside coverage, incomplete evidence, over limit, fraud indicators, duplicates), boundary cases (review e), right-skewed amounts (review a).

## Idea
A claim is first a `Spec` (policy, incident date/type, submission date, items, docs). Normal specs are drawn inside the policy and coverage windows. Special scenarios are built with deliberate *inputs*; the outcome (deny, pend, review) comes from the rules engine later, never from here.

| Scenario | How it is planted |
|---|---|
| lapsed_policy | incident after the policy's lapse date |
| outside_coverage_period | incident before a late-starting policy_coverage |
| incomplete_evidence | one mandatory doc absent (about a quarter of the omissions are instead present on time with status `rejected`, which does not count), or present but received 10-30 days late (detail: absent, rejected or late) |
| claim_over_limit | single item at 1.1-1.6x the coverage limit |
| suspected_fraud | incident within 20 days of start, amount 95-100% of limit |
| duplicate_incident | clone of a normal claim (same policy/date/type), submitted 1-20 days later |
| boundary_* | incident on start/end date; amount exactly at limit or at deductible |

Shared helpers (`Spec`, `Ctx`, windows, items, docs) live in `claim_build.py`; this module has the scenario builders, duplicates and assembly.

Uniqueness: `_draw` keeps a `seen` set of (policy, incident date) so only labelled duplicates ever share them. Over-limit and at-limit claims avoid F1 and cosmetic items so they test the limit rule alone.

## Key functions
| Function | Role | Gotcha |
|---|---|---|
| `BUILDERS` | one builder per scenario name | each returns `None` when the drawn policy cannot support it; `_draw` retries |
| `_duplicate` | clones a normal claim, submitted 1-20 days later; each source is cloned at most once (`copied` set) | the clone's `detail` is the source claim ID; before T6 two clones of one source could appear by chance and made a group of three |
| `_assemble` | sorts by (submission, incident, policy) then assigns IDs | injection step must renumber after adding claims |
| `generate` | returns `(tables, planted)` | `planted` is never joined into input tables; later feeds ground_truth |

`_make_not_covered` is not a builder: it converts k ordinary claims (one item of a type the coverage does not list, same amount) after all other draws, on its own random stream, so every other claim is untouched; it skips duplicate sources and claims whose dates could trip a fraud flag. Scenario `not_covered` (R-ELG-01) makes the rule fire on the data (10 claims at full scale).

Counts come from `config.scenario_counts`; baseline claims = claims - `inject_rows(scale)` so injected duplicates keep the total at 1,000.

## Tests
`tests/test_claims.py`: each scenario property, normal-claim cleanliness, ID order, skew, determinism.
