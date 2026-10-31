# Metrics

Operational numbers come from the dataset; the scoring table compares engine and validator output with ground_truth.

## Outcomes

| Outcome | Claims | Share |
|---|---|---|
| approved | 28 | 56.0% |
| denied | 12 | 24.0% |
| docs_pending | 4 | 8.0% |
| under_review | 4 | 8.0% |
| not_yet_assessed | 2 | 4.0% |

Days from submission to approval: mean 11.11, median 8.5, p90 19.0
Days from submission to settlement (paid): mean 13.89, median 12.0, p90 22.0

## Amounts (USD)

- Claimed total: 655,163.09
- Blocked by denial: 95,942.64
- Reduced by deductible, exclusions and limits on approved claims: 49,283.58
- Held for documents or review: 172,107.77
- Recommended settlements: 391,223.89 | paid: 391,223.89

## Reserve vs final settlement

- Settled claims: 28 | reserve total 304,838.17 | recommended total 391,223.89
- Claims where the settlement differs from the reserve: 2 (compare with the integrity defects in the validation summary)

## By claim type

| Type | Claims | Approval rate | Denial rate |
|---|---|---|---|
| AUTO | 17 | 70.6% | 23.5% |
| HLTH | 9 | 55.6% | 33.3% |
| HOME | 15 | 53.3% | 0.0% |
| LIAB | 7 | 42.9% | 42.9% |
| TRVL | 2 | 0.0% | 100.0% |

## Money effect by rule (final assessment, USD)

| Rule / effect | Claims | Amount |
|---|---|---|
| R-COV-01/blocked | 2 | 15,521.47 |
| R-COV-02/blocked | 4 | 63,060.82 |
| R-COV-03/blocked | 1 | 779.64 |
| R-DOC-01/held | 4 | 104,337.31 |
| R-ELG-03/held | 3 | 10,391.50 |
| R-FRD-05/held | 1 | 57,378.96 |
| R-PAY-01/blocked | 5 | 16,580.71 |
| R-PAY-01/reduced | 28 | 49,283.58 |

## Straight-through (no exception) rate

Straight-through means the claim never pended for documents or went to review and ended assessed, approved or paid. Every decision in this dataset is automated; the actor roles show who would own each step in a real operation. It is not comparable with an industry touchless rate.

- Assessed claims: 48 | straight-through: 27 (56.2%) | other: 21 (of which pended or referred: 9)

## Approver workload

| Role | Settlements | Amount |
|---|---|---|
| approver | 3 | 129,450.36 |
| process_owner | 25 | 261,773.53 |

- Share of approved settlements that needed the approver: 10.7%

## Documents pending: aging at the as-of date

- Claims: 4 | mean 101.25 days, median 99.5, p90 173.0, max 206 | older than 14 days: 3, 30 days: 2, 90 days: 2
- There is no document-chase SLA or closure: a claim stays in `docs_pending` unless the documents arrive.

## Cycle time by claim type (submission to paid, days)

| Type | Paid claims | Median | p90 |
|---|---|---|---|
| AUTO | 12 | 10.5 | 13.0 |
| HLTH | 5 | 8.0 | 9.0 |
| HOME | 8 | 20.5 | 26.0 |
| LIAB | 3 | 21.0 | 21.0 |

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
| 0.25 | 8 | 184,713.55 | 0.12 | 1.00 |
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
