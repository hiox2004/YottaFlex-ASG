# Metrics

Operational numbers come from the dataset; the scoring table compares engine and validator output with ground_truth.

## Outcomes

| Outcome | Claims | Share |
|---|---|---|
| approved | 32 | 64.0% |
| denied | 8 | 16.0% |
| docs_pending | 3 | 6.0% |
| under_review | 3 | 6.0% |
| not_yet_assessed | 4 | 8.0% |

Days from submission to approval: mean 6.19, median 6.0, p90 8.0
Days from submission to settlement (paid): mean 8.84, median 8.0, p90 12.0

## Amounts (USD)

- Claimed total: 550,410.20
- Blocked by denial: 19,067.90
- Reduced by deductible, exclusions and limits on approved claims: 54,532.76
- Held for documents or review: 89,565.33
- Recommended settlements: 624,072.62 | paid: 624,072.62

## Reserve vs final settlement

- Settled claims: 32 | reserve total 351,503.03 | recommended total 624,072.62
- Claims where the settlement differs from the reserve: 2 (compare with the integrity defects in the validation summary)

## By claim type

| Type | Claims | Approval rate | Denial rate |
|---|---|---|---|
| AUTO | 19 | 68.4% | 15.8% |
| HLTH | 3 | 33.3% | 0.0% |
| HOME | 19 | 68.4% | 15.8% |
| LIAB | 6 | 66.7% | 16.7% |
| TRVL | 3 | 33.3% | 33.3% |

## Money effect by rule (final assessment, USD)

| Rule / effect | Claims | Amount |
|---|---|---|
| R-COV-01/blocked | 2 | 4,636.48 |
| R-COV-02/blocked | 4 | 10,055.46 |
| R-COV-03/blocked | 1 | 2,375.96 |
| R-DOC-01/held | 3 | 8,522.37 |
| R-ELG-03/held | 2 | 8,396.80 |
| R-FRD-05/held | 1 | 72,646.16 |
| R-PAY-01/blocked | 1 | 2,000.00 |
| R-PAY-01/reduced | 32 | 54,532.76 |

## Touchless processing

- Assessed claims: 46 | touchless (no pend or review step, ended assessed/approved/paid): 30 (65.2%) | other: 16 (of which with a human step: 8)

## Approver workload

| Role | Settlements | Amount |
|---|---|---|
| approver | 8 | 394,412.70 |
| process_owner | 24 | 229,659.92 |

## Documents pending: aging at the as-of date

- Claims: 3 | mean 63.33 days, median 91.0, p90 91.0, max 91 | older than 14 days: 2

## Cycle time by claim type (submission to paid, days)

| Type | Paid claims | Median | p90 |
|---|---|---|---|
| AUTO | 13 | 9.0 | 12.0 |
| HLTH | 1 | 8.0 | 8.0 |
| HOME | 13 | 9.0 | 12.0 |
| LIAB | 4 | 7.0 | 7.0 |
| TRVL | 1 | 6.0 | 6.0 |

## Threshold sensitivity

The engine is re-run with one threshold changed at a time; the current setting is marked. Current: approver threshold 10,000.00 USD, fraud cutoff 0.5.

### Approver threshold (settlements above it need the approver role)

Counts every recommended settlement above the threshold on a clean re-run, including recent ones not yet approved and without the planted amount defects, so the current row can differ slightly from the approver workload table.

| Threshold (USD) | Recommended settlements above it | Amount (USD) |
|---|---|---|
| 5,000.00 | 19 | 324,334.55 |
| 10,000.00 (current) | 8 | 253,924.73 |
| 20,000.00 | 5 | 214,795.63 |
| 50,000.00 | 1 | 99,557.62 |

### Fraud-score cutoff (score = flags / 4; at or above it the claim goes to review)

| Cutoff | Fraud-referred claims | Claimed amount flagged (USD) | Precision | Recall |
|---|---|---|---|---|
| 0.25 | 5 | 254,644.13 | 0.20 | 1.00 |
| 0.5 (current) | 1 | 72,646.16 | 1.00 | 1.00 |
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
| duplicate_incident | 3 | 2 | 2 | 1.00 | 0.67 |
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
