---
description: Generate twice with the fixed seed, compare checksums, run validation and tests (short output)
allowed-tools: Bash(python:*), Bash(pytest:*), Bash(ruff:*)
---

Run `python scripts/verify.py` and `pytest -q`. Report only the final summary lines and any failures.
Do not open generated data files.
