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
