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
| a. Distributions | TODO validation report |
| b. IDs and joins | TODO |
| c. Lifecycle | TODO |
| d. Derived values | TODO |
| e. Case coverage | TODO |
| f. Ground truth separate | TODO test |
| g. Reproducibility and provenance | `scripts/verify.py`, SOURCE_MANIFEST.md |

## Status
Scaffold only; generator not built yet.
