# __main__ (`src/claimsgen/__main__.py`)

**Purpose:** the command line: `python -m claimsgen build --scale 1.0 --out DIR` builds one dataset; `python -m claimsgen all --out output` builds starter (scale 0.05, `output/starter`) and full (scale 1.0, `output/full`).
`--scale` goes through `config.check_scale`: anything unsupported gives one argparse error line and exit code 2 (no traceback).
**Brief items:** deliverable 2 (one command builds starter and full; scale is a parameter), step 9 (generator command).

- Exit code is 1 if validation does not flag exactly the planted defects or the same-seed rerun differs.
- `--seed` exists but only the fixed seed 20261022 is accepted (`generate.build` raises `ValueError`), because the brief fixes it.
- Prints one summary line per dataset (files written, checks passed, rerun identical).
