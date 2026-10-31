# Submission checklist

Deadline: Mon 2 Nov 2026 01:13:12 IST (72 hours from Fri 30 Oct 2026 01:13:12 IST). Freeze code Sun 1 Nov 20:00 IST.
Update the status column as items close. Owner column: **Claude** = engineer work, **You** = only the candidate can do it.

## Code and repo (Claude)

| # | Item | Status |
|---|---|---|
| C1 | Workflow engine, generator, validation, metrics, view, container, CI | Done (HEAD green) |
| C2 | Reviewer backlog T1-T12 (honesty, coverage terms, realism, scale limits, cycle times, FNOL reserve) | Done |
| C3 | MIT LICENSE | Done |
| C4 | Fresh-clone check: clone the public repo, install, `pytest -q`, `verify.py 0.05` | Done: the fresh clone passed 319 tests and `verify.py` |
| C5 | Brief-vs-project audit by an independent Opus (`docs/review/BRIEF_AUDIT.md`, local) | Done; its engineer fix list is applied (data dictionary relationships, full-volume proof in CI, doc drift, R-ELG-01 on the data) |
| C6 | T13 freeze: refresh counts, final checklist, tag `v1.0.0` | After You H1-H4 |
| C7 | Local Docker re-test | Done 2026-11-01: image built, `verify.py 0.05` passed inside it, app healthy on :8501, browser run with Playwright (all 8 tabs, 7 example claims, 3 hostile inputs, no exceptions) |

## Only you (before sending)

| # | Item | Where |
|---|---|---|
| H1 | Candidate statement (three parts) | `ai-transparency/README.md` |
| H2 | claude.ai chat prompts used before this repo | `ai-transparency/` |
| H3 | Research-session statement | `ai-transparency/README.md` |
| H4 | Final `python scripts/export_prompts.py`, read the output, commit | `ai-transparency/prompt-history/` |
| H5 | Decide on commit email: switch to the GitHub no-reply address for later commits (`git config user.email ID+hiox2004@users.noreply.github.com`); the 70 existing commits keep the current address (history is not rewritten) | git config |
| H6 | Rehearse the walkthrough (questions and answers in the reviewer report, section 5) | local |
| H7 | Confirm the repo is public and the README renders | github.com/hiox2004/YottaFlex-ASG |
| H8 | Email the repo link from the recruitment address before the deadline | email |
| H9 | Start Docker Desktop, run `docker build -t yottaflex-asg .` and `docker run --rm -p 8501:8501 yottaflex-asg`, open http://localhost:8501 | local |
| H10 | Decide the opening line of the email: where to start (README "Five-minute tour", the Streamlit tab) and the container command | email |

## Order of work

1. Claude: Opus brief audit finishes, an engineer applies its DO NOW fixes, tests and CI green.
2. You: H1-H4 (the export must come last, after the final commit of code, so it includes this session's history).
3. Claude: T13 freeze and tag.
4. You: H5-H10, send.
