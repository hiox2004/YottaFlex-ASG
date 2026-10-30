# generate (`src/claimsgen/generate.py`)

**Purpose:** the single entry point that builds the whole dataset: master data -> policies -> claims -> baseline engine -> injection + engine re-run -> final ids -> ground truth.
**Brief items:** deliverable 2 (one generator, scale parameter), step 10 (reproducibility depends on it being deterministic).

`build_dataset(scale=1.0)` returns `(tables, ground_truth_rows)`. `tables` has the 16 input and event tables; ground truth is a separate list.
The export step will add `build(out_dir, seed, scale)` (CSV/JSON/SQL files) on top, which `scripts/verify.py` already expects.
Full scale builds in about a second; starter scale 0.05 builds 100 policies and 50 claims.
