# Metrics

Operational numbers come from the dataset; the scoring table compares engine and validator output with ground_truth.

## Outcomes

| Outcome | Claims | Share |
|---|---|---|
| approved | 30 | 60.0% |
| denied | 11 | 22.0% |
| docs_pending | 4 | 8.0% |
| under_review | 4 | 8.0% |
| not_yet_assessed | 1 | 2.0% |

Days from submission to approval: mean 6.23, median 6.0, p90 8.0
Days from submission to settlement (paid): mean 9.47, median 9.0, p90 12.0

## Amounts (USD)

- Claimed total: 704,957.62
- Blocked by denial: 68,551.55
- Reduced by deductible, exclusions and limits on approved claims: 39,373.37
- Held for documents or review: 130,664.29
- Recommended settlements: 715,163.54 | paid: 715,163.54

## Reserve vs final settlement

- Settled claims: 30 | reserve total 428,204.28 | recommended total 715,163.54
- Claims where the settlement differs from the reserve: 2 (compare with the integrity defects in the validation summary)

## By claim type

| Type | Claims | Approval rate | Denial rate |
|---|---|---|---|
| AUTO | 20 | 65.0% | 10.0% |
| HLTH | 10 | 50.0% | 40.0% |
| HOME | 12 | 66.7% | 16.7% |
| LIAB | 5 | 60.0% | 40.0% |
| TRVL | 3 | 33.3% | 33.3% |

## Money effect by rule (final assessment, USD)

| Rule / effect | Claims | Amount |
|---|---|---|
| R-COV-01/blocked | 2 | 11,040.94 |
| R-COV-02/blocked | 4 | 55,041.38 |
| R-COV-03/blocked | 1 | 779.64 |
| R-DOC-01/held | 4 | 99,128.13 |
| R-ELG-03/held | 3 | 7,510.89 |
| R-FRD-05/held | 1 | 24,025.27 |
| R-PAY-01/blocked | 4 | 1,689.59 |
| R-PAY-01/reduced | 30 | 39,373.37 |

## Straight-through (no exception) rate

Straight-through means the claim never pended for documents or went to review and ended assessed, approved or paid. Every decision in this dataset is automated; the actor roles show who would own each step in a real operation. It is not comparable with an industry touchless rate.

- Assessed claims: 49 | straight-through: 29 (59.2%) | other: 20 (of which pended or referred: 9)

## Approver workload

| Role | Settlements | Amount |
|---|---|---|
| approver | 5 | 247,955.38 |
| process_owner | 25 | 467,208.16 |

- Share of approved settlements that needed the approver: 16.7%

## Documents pending: aging at the as-of date

- Claims: 4 | mean 111 days, median 112.0, p90 202.0, max 216 | older than 14 days: 3, 30 days: 2, 90 days: 2
- There is no document-chase SLA or closure: a claim stays in `docs_pending` unless the documents arrive.

## Cycle time by claim type (submission to paid, days)

| Type | Paid claims | Median | p90 |
|---|---|---|---|
| AUTO | 13 | 10.0 | 11.0 |
| HLTH | 5 | 9.0 | 11.0 |
| HOME | 8 | 10.0 | 12.0 |
| LIAB | 3 | 9.0 | 9.0 |
| TRVL | 1 | 12.0 | 12.0 |

## Threshold sensitivity

The engine is re-run with one threshold changed at a time; the current setting is marked. Current: approver threshold 30,000.00 USD, fraud cutoff 0.5.

### Approver threshold (settlements above it need the approver role)

Counts every recommended settlement above the threshold on a clean re-run, including recent ones not yet approved and without the planted amount defects, so the current row can differ slightly from the approver workload table.

| Threshold (USD) | Recommended settlements above it | Amount (USD) |
|---|---|---|
| 15,000.00 | 10 | 346,226.11 |
| 30,000.00 (current) | 5 | 247,955.38 |
| 50,000.00 | 2 | 144,258.52 |
| 100,000.00 | 0 | 0.00 |

### Fraud-score cutoff (score = flags / 4; at or above it the claim goes to review)

| Cutoff | Fraud-referred claims | Claimed amount flagged (USD) | Precision | Recall |
|---|---|---|---|---|
| 0.25 | 8 | 191,218.92 | 0.12 | 1.00 |
| 0.5 (current) | 1 | 24,025.27 | 1.00 | 1.00 |
| 0.75 | 0 | 0.00 | n/a | 0.00 |
| 1.0 | 0 | 0.00 | n/a | 0.00 |

## Precision and recall vs ground_truth

Predicted labels come from engine output, input data and validator failures only. Unassessed (very recent) claims count as misses.

Fraud flag counts over 50 claims: F1 13 (26.0%), F2 0 (0.0%), F3 3 (6.0%), F4 2 (4.0%). Flag combinations: F1 12, F1+F3 1, F3 2, F4 2, none 33.

Fraud caveat: the fraud labels are the planted indicator pattern (an early claim near the limit), so the suspected_fraud row checks rule consistency; it is not a fraud-detection accuracy.

| Class | Truth | Predicted | True positives | Precision | Recall |
|---|---|---|---|---|---|
| claim_before_policy_start | 2 | 2 | 2 | 1.00 | 1.00 |
| cancelled_before_incident | 2 | 2 | 2 | 1.00 | 1.00 |
| lapsed_policy | 2 | 2 | 2 | 1.00 | 1.00 |
| outside_coverage_period | 1 | 1 | 1 | 1.00 | 1.00 |
| duplicate_incident | 3 | 3 | 3 | 1.00 | 1.00 |
| suspected_fraud | 1 | 1 | 1 | 1.00 | 1.00 |
| claim_over_limit | 1 | 1 | 0 | 0.00 | 0.00 |
| settlement_exceeds_limit | 2 | 2 | 2 | 1.00 | 1.00 |
| paid_twice | 2 | 2 | 2 | 1.00 | 1.00 |
| documents (shared class) | 5 | 5 | 5 | 1.00 | 1.00 |
| incomplete_evidence (recall only) | 3 |  | 3 | n/a | 1.00 |
| missing_mandatory_doc (recall only) | 2 |  | 2 | n/a | 1.00 |
| boundary_incident_on_start (decided as expected) | 1 |  | 1 | n/a | 1.00 |
| boundary_incident_on_end (decided as expected) | 1 |  | 1 | n/a | 1.00 |
| boundary_amount_at_limit (decided as expected) | 1 |  | 1 | n/a | 1.00 |
| boundary_amount_at_deductible (decided as expected) | 1 |  | 1 | n/a | 1.00 |
