# view_data (`src/claimsgen/view_data.py`)

**Purpose:** all the data the minimal view shows, as pure tested functions (no Streamlit): decisions table, exceptions list, per-claim detail and timeline, metrics panel.
**Brief items:** "expose key decisions and exceptions, preserve traceability, produce measurable outputs" (SPEC deliverable 11).

| Function | What it returns | Source |
|---|---|---|
| `load(scale)` | `(tables, ground_truth, checks)` | `generate.build_dataset` + `validate.run_all` |
| `decisions_table(tables)` | one row per claim: status, decision, rule_id, reason_code, actor role of the latest event, payable | last assessment + last history event |
| `exceptions(tables, checks)` | exception title -> rows (docs pending, duplicate, over limit, fraud, cancelled before incident, lapsed, claim before start, outside coverage, paid twice, settlement above limit) | `scoring.predictions`: engine output, policy events and validator failures |
| `claim_detail(tables, claim_id)` (timeline rows carry a `detail` text, "Requested: <doc types>" on a docs_pending step, from `assessment.missing_doc_types`) | claim, policy, incident, items, documents, assignments, assessments, reserves, settlements and the status timeline (date, from, to, actor role, rule, reason) | the append-only tables |
| `display(table, rows)` | rows as display text (money dollars.cents, ISO dates, empty for None) | `export.text` |
| `metrics_panel(tables, ground_truth, checks, sweep_result=None)` | operational metrics (incl. by_rule, straight_through, approver workload, docs-pending aging, cycle by type), precision/recall rows and the threshold `sensitivity` sweep (8 engine re-runs; pass a cached `sweep_result` to skip) | `metrics`, `scoring`, `sensitivity` |
| `rule_trace(tables, claim_id)`, `counterfactual(tables, claim_id)` | decision path per claim and what would make it payable (re-exported from `view_trace`, see its note) | assessments, history, input rows |
| `dataset_checksum(tables)` | SHA-256 over the canonical CSV text of the input tables in schema order (nothing written) | `export._csv` |
| `rebuild_and_compare(scale)` | `(identical, checksum_1, checksum_2)` from two fresh builds with the fixed seed | `generate.build_dataset` |
| `realism(tables)` | claimed-amount histogram + median/mean/p90, claim-type mix, policy status at AS_OF, incident-to-submission lag bins (0, 1, 2, 3, 4-7, 8-14, 15-30, 31-60, 61+) | dataset tables |

Rule: `decisions_table`, `exceptions` and `claim_detail` never receive ground_truth (a test checks their signatures). Only `metrics_panel` reads it, for scoring and the sweep's precision/recall.

## Tests
`tests/test_view_data.py`: one decision row per claim, required exception categories with the planted counts, timelines equal history, display formatting, and a headless Streamlit `AppTest` run of `app.py` that exercises every panel and selector.

`tests/test_view_trace.py`: trace stop points per stop type, resumed docs re-run, counterfactual numbers. `test_view_data.py` also covers checksum stability, rebuild at scale 0.05, realism sums and the AppTest run of all six tabs, scale selector and the `rebuild` button.
