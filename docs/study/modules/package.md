# package (`src/claimsgen/__init__.py`)

**Purpose:** marks `claimsgen` as an importable package and exposes the project-wide constant `SEED = 20261022`.
**Pipeline stage:** none (shared constant); later modules and `scripts/verify.py` use the same seed.
**Brief items served:** step 4 fixed seed, step 10 reproducibility.

## Key items
| Item | What it does | Gotcha |
|---|---|---|
| `SEED` | The fixed seed from the brief | Per-module RNGs derive from it as `random.Random(f"{SEED}:{module}")`; never use the global `random` |

## How to test
`tests/test_smoke.py` checks the seed value and greps `src/` for clock or unseeded-random use.
