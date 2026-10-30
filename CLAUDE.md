# YottaFlex-ASG: Claims Synthetic Data Challenge

Goal: a working claims workflow solution plus its test bed. (1) A deterministic Python generator -> clean, joinable
11-entity insurance claims dataset (2,000 policies, 1,000 claims, 5 claim types) + separate ground_truth + validation +
reproducibility proof. (2) The workflow engine (intake -> coverage -> documents -> eligibility -> settlement routing) with a
minimal view exposing decisions, exceptions, per-claim timeline and metrics (core scope, see docs/SPEC.md deliverable 11).
Full spec: `docs/SPEC.md` (source of truth, incl. data dictionary).

## Stack and commands
Plain Python 3.11+, stdlib (`csv`, `json`, `sqlite3`, `hashlib`), pytest, ruff. View = single-file Streamlit `app.py` (rendering only; logic lives in tested modules), built after export and metrics. No Faker.
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
- Subagents: never use `general-purpose`. Use `reviewer` (Opus, read-only) only for the design review and the final audit; use `mechanical` (Haiku)
  for boilerplate; any other subagent call sets `model` explicitly. Reviewer findings are ranked by ROI (quality gain vs token/time cost):
  apply DO NOW, log DO LATER in docs/study/LOG.md, skip the rest. Agent files load at session start, so run the final audit in a fresh session.
- ground_truth is for scoring only: the exceptions list and decisions come from engine output, never from labels.
  Mechanical jobs go to `mechanical` (Haiku). Any other subagent call sets `model: sonnet` or `haiku` explicitly.
- Never read raw `output/` CSV/DB files; use `scripts/summarize_data.py`.
- One git commit per step. Keep diffs small. Public repo: no secrets, ever.
- Study guide: for every new/changed module, update `docs/study/modules/<name>.md`, the index in `docs/study/README.md`, and `docs/study/LOG.md` in the same commit (a test enforces the note exists).
- Commit format `<type>(<scope>): <summary>` per CONTRIBUTING.md (enforced by .githooks/commit-msg); design lives in docs/DESIGN.md.
