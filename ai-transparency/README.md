# AI use and prompt history

This directory is the transparency record required by the submission guidelines: which AI tools were used, where they helped,
what the candidate reviewed, and the prompts submitted. Facts below come from the project history; items marked **TO COMPLETE**
can only be written by the candidate and are left open on purpose.

**Status of the prompt history: EXPORTED.** `prompt-history/` holds all three Claude Code sessions of this project (66 user prompts,
32 subagent prompts and 2 helper-model prompts at export time). Re-run `python scripts/export_prompts.py` before the final push so it is current.

## Timeline
The 72-hour window ran from Fri 30 Oct 2026 01:13:12 IST to Mon 2 Nov 2026 01:13:12 IST (as given by the organisation). The first prompt in the history is
30 Oct 12:16 IST and the first commit is 30 Oct 12:29 IST; every commit in this repository is inside the window (`git log --format=%cI`).

## Tools and models used
| Tool | Model(s) | Used for |
|---|---|---|
| Claude Code (VS Code extension), build session | Claude Sonnet 5.5 | Planning, design, and essentially all code, tests and docs in this repo |
| Subagents inside the build session | Claude Opus (six read-only reviews: the design review, checkpoints on generation, rules engine and injection, the final audit, and the claim-intake design) | Finding defects and ranking fixes by return on effort |
| Claude Code workers (subagents) for the improvements backlog | Claude Sonnet 5.5 (six workers) and Haiku (three workers) | Independent tests, business metrics and the sensitivity sweep, the view panels, README limits, and the claim-intake feature (what-if evaluation, example claims and the Submit a claim tab by Sonnet; intake validation, the Quality tab and the input documentation by Haiku). Each worker edited separate files and did not commit; the orchestrating session ran ruff and the tests, spot-checked outputs and committed |
| Claude Code, teaching session | Sonnet (briefly switched to Haiku, then back) | Explaining the code and the insurance domain; logging ideas in `docs/study/IMPROVEMENTS.md` |
| Claude Code, GitHub research session | Sonnet orchestrator with Haiku `Explore` workers | Searching public GitHub for related generators and claims engines and for other people's entries for this task (see "The research session" below) |
| Claude chat on claude.ai | Claude | Produced the "Understanding Brief" PDF and the initial setup pitch that this repo's setup followed. **Its prompts are not in this repo** (see limits) |
| GitHub CLI | none | Creating the repository and pushing; not an AI tool |

## Where AI accelerated, and where it was relied on heavily
- **Relied on heavily (written by the AI, directed by prompts):** the generator, rules engine, validation suite, injection and ground
  truth, export, metrics, the Streamlit view, the tests, the study guide and the design/spec documents.
- **Where review changed the result:** Opus reviews found real defects that were then fixed, for example claim ordering by a
  provisional ID, a shared random stream that would have changed untouched claims on re-run, injected rows identifiable by table
  position, and an unassessed injected duplicate. Each fix is recorded in `docs/study/LOG.md` and `docs/DESIGN.md`.
- **Human direction visible in the history:** the objective and the briefs came from the candidate; the candidate caught that the plan
  treated the working workflow as optional and corrected the scope (IMP-001, SPEC deliverable 11); the candidate set the
  subagent/model policy, delegated several design decisions, and authenticated `gh` and approved installs and edits through permission prompts.

## How the solution was verified
`pip install -e ".[dev,ui]"` then `pytest -q` (229 tests, including headless runs of the Streamlit app), `python scripts/verify.py`
(builds the dataset twice and compares every file by SHA-256), and CI on every push. The validator is checked against the planted
defects, and precision/recall against the answer key is reported in each package's `metrics.md`. Known limits are in the main README.

## Limits of this record (disclosed)
- Only Claude Code transcripts are exportable here. Prompts typed into claude.ai are not included unless the candidate adds them.
- AI responses are not exported (optional per the FAQ); the decisions and reasoning are in `docs/DESIGN.md`, `docs/study/LOG.md` and the commit history.
- The export keeps user text verbatim except: local OS username in paths, e-mail addresses and token-like strings are redacted;
  harness-injected blocks (system reminders, IDE notices) and tool outputs are omitted; attached PDFs appear as `[attached document: name]`.
- Repeated `/loop` entries are scheduled re-runs of the same prompt. Prompts that Claude wrote for subagents and helper models are in
  `prompt-history/subagent-and-helper-prompts.md`.
- The briefs and FAQ pasted into prompts are the organisation's material; they appear in the history because the history must be complete.

## Regenerating the prompt history
```
python scripts/export_prompts.py            # reads this project's Claude Code transcripts, writes ai-transparency/prompt-history/
```
Re-run it before the final push so the history is current. Each run rebuilds the files from the transcripts (fast and deterministic, so
there are no duplicated or reordered entries), but it refuses to overwrite the existing history with fewer prompts (for example if the local
transcripts were trimmed) unless `--force` is passed. The script exits non-zero if a secret-like pattern remains. Always read
the output before committing: it is a public repository.

## The research session (disclosure)
Facts from the prompt history (`prompt-history/session-3.md` and the Session 3 entries of `prompt-history/subagent-and-helper-prompts.md`):
- The session was asked to find relevant GitHub repositories, and later to "search for the task as it must have multiple people's entries
  ... so we can try to improve using those". Twelve Haiku workers looked into named public repositories (they are listed in the subagent
  prompts), searched for newer claims-engine and synthetic-claims repositories, and searched for entries to this task by distinctive IDs,
  workflow wording and on other platforms. The same session then discussed whether the product should use an LLM.
- Use in this project: no prompt in the build session (session 1) or the teaching session (session 2) mentions those repositories or
  their content, and this repository's code, tests and documents were written in the build session. According to the prompt history,
  nothing from the research session's reports was passed into the build, and no code from those repositories was imported or copied into this repository.
- What the history cannot show is anything done outside Claude Code (for example reading those repositories yourself). That is for the candidate to state below.

## Decisions the candidate owns
The design choices a reviewer is likely to ask about, each documented in `docs/DESIGN.md`: the rule order and why the first failing rule ends a claim;
per-claim random streams so a re-run cannot change untouched claims; injecting business cases before the engine re-run but integrity defects after it;
single-map ID renumbering after injection; the replay validator and its shared-formula limit (and the independent reference in tests);
predicted labels never reading ground truth; byte-stable export.

## Candidate statement (to be written by the candidate before submitting)
The sections above are facts from the project history. The following can only be stated by the candidate and are intentionally not
filled in by an AI:
1. **What I personally reviewed, changed and validated:** _[to be written by the candidate]_
2. **claude.ai prompts:** the chat that produced the Understanding Brief and the setup pitch cannot be exported from the coding sessions
   (only its share link appears, session 1 prompt 1). _[paste its prompts, or state that they could not be exported]_
3. **Research session:** _[confirm the section "The research session" is complete, whether any idea from those repositories or entries
   influenced a decision, whether you read them yourself, and that no third-party solution or core code was imported or copied (FAQ 7 and 10)]_
