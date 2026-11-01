# view_stages

Source: `src/claimsgen/view_stages.py`. Tests: `tests/test_view_stages.py`, `tests/test_app_intake.py`.

## Purpose
Two pure functions for the first screen of the view, no Streamlit import.
- `stages(result)` turns a what-if result into the five brief stages (Intake, Coverage, Documents, Eligibility, Routing), each
  `passed`, `stopped` or `not reached`, with the rule id and reason code of the step that stopped it.
- `headline(tables, checks, checksum)` returns the four numbers shown above the tabs: claims, straight-through rate, open exceptions,
  seed and checksum.

## Notes
- Stages come only from `rule_trace` and the decision. R-COV-* is Coverage, R-DOC-01 Documents, R-ELG-* and R-FRD-* Eligibility,
  R-PAY-01, R-RSV-* and R-APR-01 Routing. A duplicate claim stops at R-ELG-03, which runs before documents, so Documents reads
  `not reached`.
- The headline reuses `metrics.operational` and `view_data.exceptions`; nothing is recomputed. "checksum computed" means the
  checksum exists; the rebuild-and-compare proof is on the Reproducibility tab.
- `app_intake.render` evaluates the default example once per session and scale (flag `intake_autorun`, cleared with the scale keys;
  Clear does not re-run it). It is the same what-if on a copy of the tables, so the dataset and its checksum do not change.
- On the Submit a claim tab the result now comes first (stage strip, decision, trace), above a open
  'Edit the claim' expander that holds the form, JSON box and Submit button, so the stages are on the first screen.
