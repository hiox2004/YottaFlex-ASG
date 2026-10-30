# YottaFlex-ASG

Deterministic synthetic insurance-claims dataset generator (11 entities, labelled anomalies, separate answer key).
All data is fully synthetic; see [SOURCE_MANIFEST.md](SOURCE_MANIFEST.md). Spec: [docs/SPEC.md](docs/SPEC.md).

## Quick start
```
pip install -e ".[dev]"
pytest -q
python scripts/verify.py
```
Generator command (seed fixed at 20261022):
```
python -m claimsgen build --scale 1.0 --out output/full      # 2,000 policies / 1,000 claims
python -m claimsgen build --scale 0.05 --out output/starter  # small starter (committed)
python -m claimsgen all --out output                          # both
```
The starter dataset is in `output/starter/` (see its README.md and validation_summary.md).

## Where to verify the review points
| Point | Evidence |
|---|---|
| a. Distributions | `validation_summary.md` distributions section; `tests/test_claims.py` |
| b. IDs and joins | `tests/test_ids.py`; validation checks (ID format, foreign keys) |
| c. Lifecycle | validation date-order and lifecycle checks; `rules.TRANSITIONS` |
| d. Derived values | validation arithmetic replay (`checks_business.py`) |
| e. Case coverage | six injected cases + boundary cases; `tests/test_inject.py` |
| f. Ground truth separate | `tests/test_inject.py` (inputs carry schema columns only); leakage check |
| g. Reproducibility and provenance | `python scripts/verify.py`; `validation_summary.md` reproducibility table; `checksums.sha256`; SOURCE_MANIFEST.md |

## Status
Built and tested: generator, rules engine (workflow), validation, injection and ground truth (60 tests).
Also built: export (CSV/JSON/SQL + docs), CLI and the same-seed reproducibility proof.
Next: metrics (operational + precision/recall), then the minimal view (decisions, exceptions, timeline, metrics).
See `docs/SPEC.md` for scope and `docs/study/LOG.md` for progress.
