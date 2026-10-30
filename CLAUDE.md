# YottaFlex-ASG: Claims Synthetic Data Challenge

Goal: one deterministic Python generator -> clean, joinable 11-entity insurance claims dataset
(2,000 policies, 1,000 claims, 5 claim types) + separate ground_truth + validation + reproducibility proof.
Full spec: `docs/SPEC.md` (source of truth, incl. data dictionary).

## Stack and commands
Plain Python 3.11+, stdlib (`csv`, `json`, `sqlite3`, `hashlib`), pytest, ruff. UI = single-file Streamlit, built last. No Faker.
- Install: `pip install -e ".[dev]"`
- Test: `pytest -q` · Lint: `ruff check . && ruff format --check .`
- Proof: `python scripts/verify.py` (or `/verify`) · Inspect data: `python scripts/summarize_data.py`

## Key decisions
- Seed 20261022, `scale` parameter. Fixed as-of date lives in config. Currency USD.
- IDs: zero-padded, deterministic. POL-<PRODUCT>-2026-000001, CLM-2026-000001, DOC-CLM-2026-000001-001,
  SET-<claimid>-001, ASN-<claimid>-001 (ASN = adjuster assignment; Assessment = ASM-). Products: AUTO HOME HLTH TRVL LIAB.
- 1,000 claims include duplicates and anomalies. 10-30 rows per mandatory edge case.

## Code rules
- Simple. No abstractions beyond need. Files under ~300 lines. One module per concern.
- Only `random.Random(seed)` instances. Never `datetime.now()`, `time`, or the global `random`/unseeded sources.
- Outcomes (status, decision, reserve, settlement) are derived from rule IDs (R-xxx), never assigned randomly.
- State changes append to claim_status_history; never overwrite.
- No label/answer columns (is_fraud, anomaly_type...) in input tables. Labels live only in ground_truth.
- Inject anomalies AFTER the clean baseline, without orphan FKs or touching unrelated rows.
- Never read raw `output/` CSV/DB files; use `scripts/summarize_data.py`.
- One git commit per step. Keep diffs small. Public repo: no secrets, ever.
