# config (`src/claimsgen/config.py`)

**Purpose:** run-wide constants (`AS_OF`, currency, approver threshold), row counts per scale, and the seeded RNG factory.
**Pipeline stage:** read by every module. Brief items: step 4 (seed, scale parameter), step 10 (reproducibility).

## Key items
| Item | What it does | Gotcha |
|---|---|---|
| `AS_OF` | Fixed "today" (2026-10-22); replaces the system clock | never call `datetime.now`; a smoke test greps for it |
| `counts(scale)` | policies/claims/customers/adjusters for a scale | 1.0 = 2,000 / 1,000 / 1,250 / 30; starter 0.05 has small floors so tiny runs still work |
| `rng(stream)` | `Random(f"{SEED}:{stream}")` | one stream per table group so changing one table never shifts another |
| `APPROVER_THRESHOLD_CENTS` | 10,000 USD | used by R-APR-01 later |

| `SCENARIO_RATES`, `scenario_counts(n)` | share of baseline claims planted per condition | min 1 each, so tiny starters still show every case |
| `inject_rows(scale)` | rows per injected edge case (15 at full scale) | injected duplicates are carved out of the 1,000 |

## Worked example
`rng("customers")` always yields the same sequence for seed 20261022.
## Tests
`tests/test_generation.py` (counts, determinism).
