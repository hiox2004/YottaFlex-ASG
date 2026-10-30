# Metrics

Operational numbers come from the dataset; the scoring table compares engine and validator output with ground_truth.

## Outcomes

| Outcome | Claims | Share |
|---|---|---|
| approved | 33 | 66.0% |
| denied | 9 | 18.0% |
| docs_pending | 3 | 6.0% |
| under_review | 4 | 8.0% |
| not_yet_assessed | 1 | 2.0% |

Days from submission to approval: mean 6.55, median 6, p90 8.0
Days from submission to settlement (paid): mean 9.18, median 8, p90 11.0

## Amounts (USD)

- Claimed total: 688,196.61
- Blocked by denial: 67,364.82
- Reduced by deductible, exclusions and limits on approved claims: 70,150.16
- Held for documents or review: 136,098.70
- Recommended settlements: 565,015.01 | paid: 565,015.01

## Reserve vs final settlement

- Settled claims: 33 | reserve total 391,071.08 | recommended total 565,015.01
- Claims where the settlement differs from the reserve: 2 (compare with the integrity defects in the validation summary)

## By claim type

| Type | Claims | Approval rate | Denial rate |
|---|---|---|---|
| AUTO | 14 | 35.7% | 35.7% |
| HLTH | 7 | 85.7% | 14.3% |
| HOME | 16 | 75.0% | 12.5% |
| LIAB | 7 | 85.7% | 0.0% |
| TRVL | 6 | 66.7% | 16.7% |

## Money effect by rule (final assessment, USD)

| Rule / effect | Claims | Amount |
|---|---|---|
| R-COV-01/blocked | 2 | 6,317.61 |
| R-COV-02/blocked | 4 | 53,352.16 |
| R-COV-03/blocked | 1 | 2,290.41 |
| R-DOC-01/held | 3 | 14,966.32 |
| R-ELG-02/blocked | 1 | 4,904.64 |
| R-ELG-03/held | 3 | 25,236.01 |
| R-FRD-05/held | 1 | 95,896.37 |
| R-PAY-01/blocked | 1 | 500.00 |
| R-PAY-01/reduced | 33 | 70,150.16 |

## Straight-through (no exception) rate

Straight-through means the claim never pended for documents or went to review and ended assessed, approved or paid. Every decision in this dataset is automated; the actor roles show who would own each step in a real operation. It is not comparable with an industry touchless rate.

- Assessed claims: 49 | straight-through: 31 (63.3%) | other: 18 (of which pended or referred: 9)

## Approver workload

| Role | Settlements | Amount |
|---|---|---|
| approver | 4 | 228,973.92 |
| process_owner | 29 | 336,041.09 |

- Share of approved settlements that needed the approver: 12.1%

## Documents pending: aging at the as-of date

- Claims: 3 | mean 151.33 days, median 100.0, p90 100.0, max 307 | older than 14 days: 3, 30 days: 3, 90 days: 2
- There is no document-chase SLA or closure: a claim stays in `docs_pending` unless the documents arrive.

## Cycle time by claim type (submission to paid, days)

| Type | Paid claims | Median | p90 |
|---|---|---|---|
| AUTO | 5 | 7.0 | 8.0 |
| HLTH | 6 | 7.5 | 10.0 |
| HOME | 12 | 9.0 | 11.0 |
| LIAB | 6 | 9.5 | 10.0 |
| TRVL | 4 | 6.0 | 6.0 |

## Threshold sensitivity

The engine is re-run with one threshold changed at a time; the current setting is marked. Current: approver threshold 25,000.00 USD, fraud cutoff 0.5.

### Approver threshold (settlements above it need the approver role)

Counts every recommended settlement above the threshold on a clean re-run, including recent ones not yet approved and without the planted amount defects, so the current row can differ slightly from the approver workload table.

| Threshold (USD) | Recommended settlements above it | Amount (USD) |
|---|---|---|
| 10,000.00 | 11 | 313,604.44 |
| 25,000.00 (current) | 4 | 228,973.92 |
| 50,000.00 | 2 | 173,000.00 |
| 100,000.00 | 0 | 0.00 |

### Fraud-score cutoff (score = flags / 4; at or above it the claim goes to review)

| Cutoff | Fraud-referred claims | Claimed amount flagged (USD) | Precision | Recall |
|---|---|---|---|---|
| 0.25 | 13 | 361,007.78 | 0.08 | 1.00 |
| 0.5 (current) | 1 | 95,896.37 | 1.00 | 1.00 |
| 0.75 | 0 | 0.00 | n/a | 0.00 |
| 1.0 | 0 | 0.00 | n/a | 0.00 |

## Precision and recall vs ground_truth

Predicted labels come from engine output, input data and validator failures only. Unassessed (very recent) claims count as misses.

Fraud caveat: the fraud labels are the planted indicator pattern (an early claim near the limit), so the suspected_fraud row checks rule consistency; it is not a fraud-detection accuracy.

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
