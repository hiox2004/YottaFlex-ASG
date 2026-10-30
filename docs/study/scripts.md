# scripts/

| Script | Purpose | How it works / gotcha |
|---|---|---|
| `verify.py` | Reproducibility proof (brief step 10) | `python scripts/verify.py [scale]` builds the whole package twice into temp dirs with the fixed seed and compares every file (lines + SHA-256); exit 1 on any difference or if validation does not flag exactly the planted defects |
| `summarize_data.py` | Compact look at generated CSVs | Prints row count, columns and 3 sample rows per file, so raw data never needs reading (also saves tokens) |
| `post_edit.py` | Claude Code PostToolUse hook | Reads the hook JSON from stdin; for edited `.py` files runs ruff format, ruff check --fix, pytest -x; exit 2 (blocking feedback) only on real failures; exit 5 (no tests collected) is tolerated |

| `export_prompts.py` | Prompt history for the submission (FAQ 6) | Reads this project's Claude Code transcripts and writes redacted markdown to `ai-transparency/prompt-history/`: user prompts per session, subagent prompts, WebFetch helper prompts. Keeps user text verbatim; strips system reminders, IDE notices and tool output; redacts OS username, e-mails and token patterns; exits 1 if a secret-like pattern remains. Rebuilds from the transcripts every run (deterministic) but refuses to shrink the committed history unless `--force` is passed. Re-run before the final push and read the output first |
| `app.py` (repo root) | The minimal view (SPEC deliverable 11) | `streamlit run app.py` (needs `pip install -e ".[ui]"`). Rendering only: tabs for Decisions (filters), Exceptions (counts + rows), Claim timeline (history, rule trace, what would make it payable, details), Metrics (rates, cycle times, amounts, rule impact, touchless, approver workload, docs-pending aging, threshold sensitivity, precision/recall), Realism (distributions) and Reproducibility (fixed seed, dataset checksum, rebuild button). All data from `claimsgen.view_data`; scale: starter 0.05, medium 0.25 or full 1.0, built in memory and cached |

Wired in `.claude/settings.json` (hook) and `.claude/commands/verify.md` (`/verify`).
