# Metrics

Operational numbers come from the dataset; the scoring table compares engine and validator output with ground_truth.

## Outcomes

| Outcome | Claims | Share |
|---|---|---|
| approved | 27 | 54.0% |
| denied | 14 | 28.0% |
| docs_pending | 3 | 6.0% |
| under_review | 4 | 8.0% |
| not_yet_assessed | 2 | 4.0% |

Days from submission to approval: mean 6.41, median 5, p90 7.0
Days from submission to settlement (paid): mean 9.04, median 8.0, p90 11.0

## Amounts (USD)

- Claimed total: 397,573.75
- Blocked by denial: 32,285.21
- Reduced by deductible, exclusions and limits on approved claims: 58,082.89
- Held for documents or review: 127,104.48
- Recommended settlements: 286,053.53 | paid: 284,020.84

## Reserve vs final settlement

- Settled claims: 27 | reserve total 174,022.44 | recommended total 286,053.53
- Claims where the settlement differs from the reserve: 2 (compare with the integrity defects in the validation summary)

## By claim type

| Type | Claims | Approval rate | Denial rate |
|---|---|---|---|
| AUTO | 15 | 53.3% | 33.3% |
| HLTH | 6 | 83.3% | 16.7% |
| HOME | 15 | 40.0% | 33.3% |
| LIAB | 7 | 57.1% | 28.6% |
| TRVL | 7 | 57.1% | 14.3% |

## Money effect by rule (final assessment, USD)

| Rule / effect | Claims | Amount |
|---|---|---|
| R-COV-01/blocked | 2 | 3,438.74 |
| R-COV-02/blocked | 4 | 23,376.28 |
| R-COV-03/blocked | 1 | 421.90 |
| R-DOC-01/held | 3 | 24,834.98 |
| R-ELG-02/blocked | 1 | 2,192.54 |
| R-ELG-03/held | 3 | 6,373.13 |
| R-FRD-05/held | 1 | 95,896.37 |
| R-PAY-01/blocked | 6 | 2,855.75 |
| R-PAY-01/reduced | 27 | 58,082.89 |

## Touchless processing

- Assessed claims: 48 | touchless (no pend or review step, ended assessed/approved/paid): 25 (52.1%) | other: 23 (of which with a human step: 9)

## Approver workload

| Role | Settlements | Amount |
|---|---|---|
| approver | 2 | 99,632.04 |
| process_owner | 25 | 186,421.49 |

## Documents pending: aging at the as-of date

- Claims: 3 | mean 243.33 days, median 313.0, p90 313.0, max 317 | older than 14 days: 3

## Cycle time by claim type (submission to paid, days)

| Type | Paid claims | Median | p90 |
|---|---|---|---|
| AUTO | 7 | 7.0 | 8.0 |
| HLTH | 5 | 7.0 | 8.0 |
| HOME | 6 | 8.0 | 10.0 |
| LIAB | 4 | 10.0 | 10.0 |
| TRVL | 4 | 6.5 | 7.0 |

## Threshold sensitivity

The engine is re-run with one threshold changed at a time; the current setting is marked. Current: approver threshold 10,000.00 USD, fraud cutoff 0.5.

### Approver threshold (settlements above it need the approver role)

Counts every recommended settlement above the threshold on a clean re-run, including recent ones not yet approved and without the planted amount defects, so the current row can differ slightly from the approver workload table.

| Threshold (USD) | Recommended settlements above it | Amount (USD) |
|---|---|---|
| 5,000.00 | 7 | 134,027.14 |
| 10,000.00 (current) | 2 | 99,632.04 |
| 20,000.00 | 2 | 99,632.04 |
| 50,000.00 | 1 | 75,000.00 |

### Fraud-score cutoff (score = flags / 4; at or above it the claim goes to review)

| Cutoff | Fraud-referred claims | Claimed amount flagged (USD) | Precision | Recall |
|---|---|---|---|---|
| 0.25 | 15 | 239,808.81 | 0.07 | 1.00 |
| 0.5 (current) | 1 | 95,896.37 | 1.00 | 1.00 |
| 0.75 | 0 | 0.00 | n/a | 0.00 |
| 1.0 | 0 | 0.00 | n/a | 0.00 |

## Precision and recall vs ground_truth

Predicted labels come from engine output, input data and validator failures only. Unassessed (very recent) claims count as misses.

| Class | Truth | Predicted | True positives | Precision | Recall |
|---|---|---|---|---|---|
| claim_before_policy_start | 2 | 2 | 2 | 1.00 | 1.00 |
| cancelled_before_incident | 2 | 2 | 2 | 1.00 | 1.00 |
| lapsed_policy | 2 | 2 | 2 | 1.00 | 1.00 |
| outside_coverage_period | 1 | 1 | 1 | 1.00 | 1.00 |
| duplicate_incident | 3 | 3 | 3 | 1.00 | 1.00 |
| suspected_fraud | 1 | 1 | 1 | 1.00 | 1.00 |
| claim_over_limit | 1 | 1 | 1 | 1.00 | 1.00 |
| settlement_exceeds_limit | 2 | 2 | 2 | 1.00 | 1.00 |
| paid_twice | 2 | 2 | 2 | 1.00 | 1.00 |
| documents (shared class) | 5 | 5 | 5 | 1.00 | 1.00 |
| incomplete_evidence (recall only) | 3 |  | 3 | n/a | 1.00 |
| missing_mandatory_doc (recall only) | 2 |  | 2 | n/a | 1.00 |
| boundary_incident_on_start (decided as expected) | 1 |  | 1 | n/a | 1.00 |
| boundary_incident_on_end (decided as expected) | 1 |  | 1 | n/a | 1.00 |
| boundary_amount_at_limit (decided as expected) | 1 |  | 1 | n/a | 1.00 |
| boundary_amount_at_deductible (decided as expected) | 1 |  | 1 | n/a | 1.00 |
