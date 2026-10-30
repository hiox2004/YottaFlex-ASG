# metrics (`src/claimsgen/metrics.py`)

**Purpose:** operational metrics computed from the tables (no ground_truth) and the `metrics.md` report that adds the precision/recall scoring.
**Brief items:** "produce measurable outputs", "meaningful evaluation metrics"; feeds the minimal view's metrics panel.

| Metric | How it is computed |
|---|---|
| outcome rates | share of claims by final status: approved (assessed/approved/paid), denied, docs_pending, under_review, not_yet_assessed |
| days submission to approval / settlement | per claim, from the first settlement row: approved/paid date minus submission date (mean, median, p90) |
| amount blocked | denied claims' claimed total; reduced = claimed minus payable on approved claims; held = docs_pending + under_review claimed total |
| reserve vs final | per settled claim, latest reserve vs first settlement's recommended amount; mismatches are listed (the planted limit defects) |
| by claim type | claims, approval rate, denial rate |

`operational(tables)` returns a plain dict (cents as integers); `to_markdown(tables, ground_truth, checks)` renders the report written to `metrics.md` in every dataset package.

## Tests
`tests/test_metrics.py`: counts and rates add up, cycle times ordered, amounts consistent, reserve mismatches equal the planted defects, every claim type present.
