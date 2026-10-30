# scoring (`src/claimsgen/scoring.py`)

**Purpose:** precision and recall of the engine and validator against ground_truth.
**Brief items:** "meaningful evaluation metrics" (medium complexity), stand-out item 2, review e (case coverage), review f (ground truth used only for scoring).

## The one rule that matters
`predictions(tables, checks)` takes NO ground_truth. Predicted labels come from engine output, input data and validator failures:

| Label | Predicted when |
|---|---|
| claim_before_policy_start | last assessment denies with R-COV-01 |
| cancelled_before_incident | denied R-COV-02 and the policy has a `cancelled` event on/before the incident |
| lapsed_policy | denied R-COV-02 and a `lapsed` event on/before the incident |
| outside_coverage_period | denied R-COV-03 |
| duplicate_incident | any assessment cites R-ELG-03 (baseline and injected share the label) |
| suspected_fraud | any assessment cites R-FRD-05 |
| claim_over_limit | final reason is `limit_reached` |
| incomplete_evidence + missing_mandatory_doc | any assessment cites R-DOC-01 (one shared class) |
| settlement_exceeds_limit | validator failure "recommended ... != replayed" (settlement id) |
| paid_twice | validator failure "more than one settlement for a claim" (second settlement id) |
| boundary_* | recall only: decided as expected (not denied by a coverage rule; approved at limit; denied within deductible) |

`score(tables, ground_truth, checks)` builds truth sets from ground_truth and returns rows with truth, predicted, true positives, precision, recall.
The shared document class is scored as one class and also per label for recall, because the two labels produce the same decision.

## Honest limits
Claims not assessed by AS_OF count as misses (recall below 1). `claim_over_limit` precision is below 1 because other claims also hit an exhausted limit.

## Tests
`tests/test_metrics.py`: planted defects and injected cases score exactly 1.0, every label is scored, no row below 0.8, `predictions` takes no ground truth.
