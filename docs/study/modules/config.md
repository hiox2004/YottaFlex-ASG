# config (`src/claimsgen/config.py`)

**Purpose:** run-wide constants (`AS_OF`, currency, approver threshold), row counts per scale, and the seeded RNG factory.
**Pipeline stage:** read by every module. Brief items: step 4 (seed, scale parameter), step 10 (reproducibility).

## Key items
| Item | What it does | Gotcha |
|---|---|---|
| `AS_OF` | Fixed "today" (2026-10-22); replaces the system clock | never call `datetime.now`; a smoke test greps for it |
| `counts(scale)` | policies/claims/customers/adjusters for a scale | 1.0 = 2,000 / 1,000 / 1,250 / 30; starter 0.05 has small floors so tiny runs still work |
| `STARTER_SCALE`, `MIN_SCALE`, `MAX_SCALE`, `check_scale(scale)` | 0.05, 0.075, 5.0; valid scales are the starter or MIN..MAX | measured: below 0.05 and at 0.051, 0.055, 0.07 injection finds fewer than 2 eligible targets; every tested value from 0.071 to 3.0 builds with all scenarios present |
| `rng(stream)` | `Random(f"{SEED}:{stream}")` | one stream per table group so changing one table never shifts another |
| `APPROVER_THRESHOLD_CENTS` | 30,000 USD | R-APR-01; chosen so 8-15% of approved settlements need the approver (tests/test_realism.py) |

| `SCENARIO_RATES`, `scenario_counts(n)` | share of baseline claims planted per condition | min 1 each, so tiny starters still show every case |
| `inject_rows(scale)` | rows per injected edge case (15 at full scale) | injected duplicates are carved out of the 1,000 |

| `DOC_WINDOW_DAYS`, `FRAUD_*` | document cutoff and fraud-flag windows/threshold | defined once here; rules and tests read them |

## Worked example
`rng("customers")` always yields the same sequence for seed 20261022.
## Tests
`tests/test_generation.py` (counts, determinism).
