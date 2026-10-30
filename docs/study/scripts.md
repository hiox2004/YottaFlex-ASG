# scripts/

| Script | Purpose | How it works / gotcha |
|---|---|---|
| `verify.py` | Reproducibility proof (brief step 10) | `python scripts/verify.py [scale]` builds the whole package twice into temp dirs with the fixed seed and compares every file (lines + SHA-256); exit 1 on any difference or if validation does not flag exactly the planted defects |
| `summarize_data.py` | Compact look at generated CSVs | Prints row count, columns and 3 sample rows per file, so raw data never needs reading (also saves tokens) |
| `post_edit.py` | Claude Code PostToolUse hook | Reads the hook JSON from stdin; for edited `.py` files runs ruff format, ruff check --fix, pytest -x; exit 2 (blocking feedback) only on real failures; exit 5 (no tests collected) is tolerated |

| `app.py` (repo root) | The minimal view (SPEC deliverable 11) | `streamlit run app.py` (needs `pip install -e ".[ui]"`). Rendering only: tabs for Decisions (filters), Exceptions (counts + rows), Claim timeline (history and details), Metrics (rates, cycle times, amounts, reserve vs final, precision/recall). All data from `claimsgen.view_data`; dataset choice: starter or full, built in memory and cached |

Wired in `.claude/settings.json` (hook) and `.claude/commands/verify.md` (`/verify`).
