# YottaFlex-ASG

Deterministic synthetic insurance-claims dataset generator (11 entities, labelled anomalies, separate answer key).
All data is fully synthetic; see [SOURCE_MANIFEST.md](SOURCE_MANIFEST.md). Spec: [docs/SPEC.md](docs/SPEC.md).

## Quick start
```
pip install -e ".[dev]"
pytest -q
python scripts/verify.py
```
Generator command and seed (20261022): TODO once the generator exists.

## Where to verify the review points
| Point | Evidence |
|---|---|
| a. Distributions | `tests/test_claims.py` (right-skewed amounts, uneven type mix); metrics panel pending |
| b. IDs and joins | `tests/test_ids.py`; validation checks (ID format, foreign keys) |
| c. Lifecycle | validation date-order and lifecycle checks; `rules.TRANSITIONS` |
| d. Derived values | validation arithmetic replay (`checks_business.py`) |
| e. Case coverage | six injected cases + boundary cases; `tests/test_inject.py` |
| f. Ground truth separate | `tests/test_inject.py` (inputs carry schema columns only); leakage check |
| g. Reproducibility and provenance | `scripts/verify.py`, SOURCE_MANIFEST.md |

## Status
Built and tested: generator, rules engine (workflow), validation, injection and ground truth (60 tests).
Next: export + reproducibility proof, metrics, then the minimal view (decisions, exceptions, timeline, metrics).
See `docs/SPEC.md` for scope and `docs/study/LOG.md` for progress.
