# metrics (`src/claimsgen/metrics.py`)

**Purpose:** operational metrics computed from the tables (no ground_truth) and the `metrics.md` report that adds the precision/recall scoring.
**Brief items:** "produce measurable outputs", "meaningful evaluation metrics"; feeds the minimal view's metrics panel.

| Metric | How it is computed |
|---|---|
| outcome rates | share of claims by final status: approved (assessed/approved/paid), denied, docs_pending, under_review, not_yet_assessed |
| days submission to approval / settlement | per claim, from the first settlement row: approved/paid date minus submission date (mean, median, p90) |
| amount blocked | denied claims' claimed total; reduced = claimed minus payable on approved claims; held = docs_pending + under_review claimed total |
| reserve vs final | FNOL reserve total vs the revised (latest) total over all claims, how many claims were revised (denials to 0), and per settled claim the latest reserve vs the first settlement's recommended amount; mismatches are the planted limit defects |
| by claim type | claims, approval rate, denial rate |
| money effect by rule | `by_rule`: from each claim's FINAL assessment, key `RULE/effect`: denied = blocked (claimed amount), approved = reduced (claimed minus payable), pend/refer = held (claimed amount); values `{effect, claims, amount_cents}` |
| straight-through | `straight_through`: `assessed`, `straight_through` (no pend_docs/refer_review assessment ever and final status assessed/approved/paid), `reviewed` (= assessed minus straight_through), `human_step` (claims with a pend or refer assessment), `straight_through_rate` (0..1); defined as "no exception", every decision being automated; also `approver_share` (share of approved settlements routed to the approver) |
| approver workload | `approver_workload`: `{role: {settlements, amount_cents}}`, first settlement per claim, only approved ones |
| docs pending aging | `docs_pending_aging`: `count, mean_days, median_days, p90_days, max_days, older_than_14_days, older_than_30_days, older_than_90_days`; age = AS_OF minus the date the claim entered its final status |
| cycle by claim type | `cycle_by_claim_type`: `{type: {paid_claims, median_days, p90_days}}`, submission to paid |

`flagmix.flag_counts` feeds one line above the precision/recall table ("Fraud flag counts ..."). These keys are added next to the existing ones; all are plain dicts of ints, floats and strings. `to_markdown` also renders them and the "Threshold sensitivity" section from `sensitivity.sweep` (see sensitivity.md).

`operational(tables)` returns a plain dict (cents as integers); `to_markdown(tables, ground_truth, checks)` renders the report written to `metrics.md` in every dataset package.

## Tests
`tests/test_metrics.py`: counts and rates add up, cycle times ordered, amounts consistent, reserve mismatches equal the planted defects, every claim type present.
`tests/test_metrics_business.py`: straight_through + reviewed = assessed, by_rule sums equal the matching totals, approver workload, aging and cycle times, new report sections.
