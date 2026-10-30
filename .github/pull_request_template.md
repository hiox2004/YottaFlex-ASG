## What and why
<!-- One short paragraph: the problem and the change. -->

## Brief items touched
<!-- Deliverables 1-10 / review points a-g from docs/SPEC.md -->

## Checklist
- [ ] `pytest -q`, `ruff check .`, `ruff format --check .` pass
- [ ] Deterministic: no clock, no unseeded randomness; `scripts/verify.py` still matches
- [ ] No label/answer columns added to input tables; ground_truth stays separate
- [ ] Docs updated (SPEC/DESIGN/README) if behaviour or schema changed
- [ ] No secrets or large generated data committed

## Notes for reviewer
