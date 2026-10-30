# Study guide

A living guide to understand every file, function and decision in this repo. Updated in the same commit as the code it describes
(enforced for `src/claimsgen/*.py` by `tests/test_study_notes.py`).

## Reading order
1. [FLOW.md](FLOW.md) the big picture: one claim traced end to end
2. [GLOSSARY.md](GLOSSARY.md) insurance and project terms
3. `../SPEC.md` then `../DESIGN.md` what we build and why
4. Module notes below, in pipeline order
5. [LOG.md](LOG.md) what was learned or changed at each step

## Index
| Area | File | Note | Status |
|---|---|---|---|
| package | `src/claimsgen/__init__.py` | [modules/package.md](modules/package.md) | done |
| vocabulary | `src/claimsgen/vocab.py` | [modules/vocab.md](modules/vocab.md) | done |
| schema | `src/claimsgen/schema.py` | [modules/schema.md](modules/schema.md) | done |
| schema docs | `src/claimsgen/schema_docs.py` | [modules/schema_docs.md](modules/schema_docs.md) | done |
| tooling | `scripts/*.py` | [scripts.md](scripts.md) | done |

Add one row per new file as it is created. Status: `todo` / `draft` / `done`.

## Rules
- New module `src/claimsgen/<name>.py` needs `docs/study/modules/<name>.md` (copy [TEMPLATE.md](TEMPLATE.md)); the test fails otherwise.
- Change a function's behaviour, then update its note and add a line to LOG.md in the same commit.
- Notes explain *why* and *how to read it*, not a line-by-line repeat of the code.
