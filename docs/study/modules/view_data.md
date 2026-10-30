# view_data (`src/claimsgen/view_data.py`)

**Purpose:** all the data the minimal view shows, as pure tested functions (no Streamlit): decisions table, exceptions list, per-claim detail and timeline, metrics panel.
**Brief items:** "expose key decisions and exceptions, preserve traceability, produce measurable outputs" (SPEC deliverable 11).

| Function | What it returns | Source |
|---|---|---|
| `load(scale)` | `(tables, ground_truth, checks)` | `generate.build_dataset` + `validate.run_all` |
| `decisions_table(tables)` | one row per claim: status, decision, rule_id, reason_code, actor role of the latest event, payable | last assessment + last history event |
| `exceptions(tables, checks)` | exception title -> rows (docs pending, duplicate, over limit, fraud, cancelled before incident, lapsed, claim before start, outside coverage, paid twice, settlement above limit) | `scoring.predictions`: engine output, policy events and validator failures |
| `claim_detail(tables, claim_id)` | claim, policy, incident, items, documents, assignments, assessments, reserves, settlements and the status timeline (date, from, to, actor role, rule, reason) | the append-only tables |
| `display(table, rows)` | rows as display text (money dollars.cents, ISO dates, empty for None) | `export.text` |
| `metrics_panel(tables, ground_truth, checks)` | operational metrics and precision/recall rows | `metrics`, `scoring` |

Rule: `decisions_table`, `exceptions` and `claim_detail` never receive ground_truth (a test checks their signatures). Only `metrics_panel` reads it, for scoring.

## Tests
`tests/test_view_data.py`: one decision row per claim, required exception categories with the planted counts, timelines equal history, display formatting, and a headless Streamlit `AppTest` run of `app.py` that exercises every panel and selector.
