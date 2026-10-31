# Metrics

Operational numbers come from the dataset; the scoring table compares engine and validator output with ground_truth.

## Outcomes

| Outcome | Claims | Share |
|---|---|---|
| approved | 29 | 58.0% |
| denied | 12 | 24.0% |
| docs_pending | 4 | 8.0% |
| under_review | 4 | 8.0% |
| not_yet_assessed | 1 | 2.0% |

Days from submission to approval: mean 6.83, median 6, p90 8.0
Days from submission to settlement (paid): mean 10.14, median 9, p90 12.0

## Amounts (USD)

- Claimed total: 716,232.95
- Blocked by denial: 115,227.81
- Reduced by deductible, exclusions and limits on approved claims: 50,383.58
- Held for documents or review: 227,968.45
- Recommended settlements: 451,480.43 | paid: 451,480.43

## Reserve vs final settlement

- Settled claims: 29 | reserve total 302,653.11 | recommended total 451,480.43
- Claims where the settlement differs from the reserve: 2 (compare with the integrity defects in the validation summary)

## By claim type

| Type | Claims | Approval rate | Denial rate |
|---|---|---|---|
| AUTO | 17 | 70.6% | 17.6% |
| HLTH | 8 | 50.0% | 37.5% |
| HOME | 16 | 50.0% | 12.5% |
| LIAB | 7 | 57.1% | 42.9% |
| TRVL | 2 | 50.0% | 50.0% |

## Money effect by rule (final assessment, USD)

| Rule / effect | Claims | Amount |
|---|---|---|
| R-COV-01/blocked | 2 | 30,776.32 |
| R-COV-02/blocked | 4 | 67,091.14 |
| R-COV-03/blocked | 1 | 779.64 |
| R-DOC-01/held | 4 | 99,128.13 |
| R-ELG-03/held | 3 | 71,461.36 |
| R-FRD-05/held | 1 | 57,378.96 |
| R-PAY-01/blocked | 5 | 16,580.71 |
| R-PAY-01/reduced | 29 | 50,383.58 |

## Straight-through (no exception) rate

Straight-through means the claim never pended for documents or went to review and ended assessed, approved or paid. Every decision in this dataset is automated; the actor roles show who would own each step in a real operation. It is not comparable with an industry touchless rate.

- Assessed claims: 49 | straight-through: 28 (57.1%) | other: 21 (of which pended or referred: 9)

## Approver workload

| Role | Settlements | Amount |
|---|---|---|
| approver | 3 | 129,450.36 |
| process_owner | 26 | 322,030.07 |

- Share of approved settlements that needed the approver: 10.3%

## Documents pending: aging at the as-of date

- Claims: 4 | mean 111 days, median 112.0, p90 202.0, max 216 | older than 14 days: 3, 30 days: 2, 90 days: 2
- There is no document-chase SLA or closure: a claim stays in `docs_pending` unless the documents arrive.

## Cycle time by claim type (submission to paid, days)

| Type | Paid claims | Median | p90 |
|---|---|---|---|
| AUTO | 12 | 8.5 | 11.0 |
| HLTH | 4 | 10.0 | 11.0 |
| HOME | 8 | 9.5 | 12.0 |
| LIAB | 4 | 11.0 | 13.0 |
| TRVL | 1 | 12.0 | 12.0 |

## Threshold sensitivity

The engine is re-run with one threshold changed at a time; the current setting is marked. Current: approver threshold 30,000.00 USD, fraud cutoff 0.5.

### Approver threshold (settlements above it need the approver role)

Counts every recommended settlement above the threshold on a clean re-run, including recent ones not yet approved and without the planted amount defects, so the current row can differ slightly from the approver workload table.

| Threshold (USD) | Recommended settlements above it | Amount (USD) |
|---|---|---|
| 15,000.00 | 7 | 231,391.18 |
| 30,000.00 (current) | 3 | 129,450.36 |
| 50,000.00 | 1 | 61,709.94 |
| 100,000.00 | 0 | 0.00 |

### Fraud-score cutoff (score = flags / 4; at or above it the claim goes to review)

| Cutoff | Fraud-referred claims | Claimed amount flagged (USD) | Precision | Recall |
|---|---|---|---|---|
| 0.25 | 8 | 175,868.94 | 0.12 | 1.00 |
| 0.5 (current) | 1 | 57,378.96 | 1.00 | 1.00 |
| 0.75 | 0 | 0.00 | n/a | 0.00 |
| 1.0 | 0 | 0.00 | n/a | 0.00 |

## Precision and recall vs ground_truth

Predicted labels come from engine output, input data and validator failures only. Unassessed (very recent) claims count as misses.

Fraud flag counts over 50 claims: F1 11 (22.0%), F2 0 (0.0%), F3 3 (6.0%), F4 2 (4.0%). Flag combinations: F1 10, F1+F3 1, F3 2, F4 2, none 35.

Fraud caveat: the fraud labels are the planted indicator pattern (an early claim near the limit), so the suspected_fraud row checks rule consistency; it is not a fraud-detection accuracy.

| Class | Truth | Predicted | True positives | Precision | Recall |
|---|---|---|---|---|---|
| claim_before_policy_start | 2 | 2 | 2 | 1.00 | 1.00 |
| cancelled_before_incident | 2 | 2 | 2 | 1.00 | 1.00 |
| lapsed_policy | 2 | 2 | 2 | 1.00 | 1.00 |
| outside_coverage_period | 1 | 1 | 1 | 1.00 | 1.00 |
| duplicate_incident | 3 | 3 | 3 | 1.00 | 1.00 |
| suspected_fraud | 1 | 1 | 1 | 1.00 | 1.00 |
| claim_over_limit | 1 | 3 | 1 | 0.33 | 1.00 |
| settlement_exceeds_limit | 2 | 2 | 2 | 1.00 | 1.00 |
| paid_twice | 2 | 2 | 2 | 1.00 | 1.00 |
| documents (shared class) | 5 | 5 | 5 | 1.00 | 1.00 |
| incomplete_evidence (recall only) | 3 |  | 3 | n/a | 1.00 |
| missing_mandatory_doc (recall only) | 2 |  | 2 | n/a | 1.00 |
| boundary_incident_on_start (decided as expected) | 1 |  | 1 | n/a | 1.00 |
| boundary_incident_on_end (decided as expected) | 1 |  | 1 | n/a | 1.00 |
| boundary_amount_at_limit (decided as expected) | 1 |  | 0 | n/a | 0.00 |
| boundary_amount_at_deductible (decided as expected) | 1 |  | 1 | n/a | 1.00 |
