# Validation summary

Seed 20261022 | scale 0.05 | AS_OF 2026-10-22 | currency USD

## Validation checks

Checks: 12 | passed: 10 | failed: 2 | failing ids: 4

| Category | Check | Rows checked | Failures | Result |
|---|---|---|---|---|
| keys | primary key uniqueness | 1178 | 0 | PASS |
| keys | ID format | 1178 | 0 | PASS |
| joins | foreign key integrity | 1549 | 0 | PASS |
| domain | enum values | 1495 | 0 | PASS |
| domain | required fields present | 6818 | 0 | PASS |
| domain | money is a non-negative integer (cents) | 1007 | 0 | PASS |
| dates | event dates not after AS_OF | 947 | 0 | PASS |
| leakage | no label or unexpected columns in input tables | 16 | 0 | PASS |
| dates | date order across the claim lifecycle | 181 | 0 | PASS |
| arithmetic | totals, payable, reserve and settlement reconcile | 110 | 2 | FAIL |
| lifecycle | legal transitions, approval before payment, roles | 81 | 4 | FAIL |
| duplicates | duplicate claims are referred; no duplicate documents | 166 | 0 | PASS |

## Row counts

| Table | Rows |
|---|---|
| customer | 62 |
| coverage | 16 |
| adjuster | 10 |
| document_requirement | 13 |
| policy | 100 |
| policy_event | 121 |
| policy_coverage | 237 |
| incident | 50 |
| claim | 50 |
| claim_item | 79 |
| document | 116 |
| claim_adjuster_assignment | 56 |
| assessment | 50 |
| reserve | 29 |
| settlement | 31 |
| claim_status_history | 158 |
| ground_truth | 25 |

### Failures: totals, payable, reserve and settlement reconcile

- `SET-CLM-2026-000034-001` recommended 8775064 != replayed 821019
- `SET-CLM-2026-000048-001` recommended 8349050 != replayed 1420363

### Failures: legal transitions, approval before payment, roles

- `SET-CLM-2026-000023-002` more than one settlement for a claim
- `SET-CLM-2026-000034-001` approver role does not match R-APR-01
- `SET-CLM-2026-000037-002` more than one settlement for a claim
- `SET-CLM-2026-000048-001` approver role does not match R-APR-01

## Integrity defects

Defect rows in ground_truth: 4 | flagged by the validator: 4 | exact match: True
The failures above are the two planted integrity defects (settlement_exceeds_limit, paid_twice); the baseline has none.

## Edge cases present and counted

| Label | Origin | Kind | Rows |
|---|---|---|---|
| boundary_amount_at_deductible | baseline | boundary | 1 |
| boundary_amount_at_limit | baseline | boundary | 1 |
| boundary_incident_on_end | baseline | boundary | 1 |
| boundary_incident_on_start | baseline | boundary | 1 |
| cancelled_before_incident | injected | business_outcome | 2 |
| claim_before_policy_start | injected | business_outcome | 2 |
| claim_over_limit | baseline | business_outcome | 1 |
| duplicate_incident | baseline | business_outcome | 1 |
| duplicate_incident | injected | business_outcome | 2 |
| incomplete_evidence | baseline | business_outcome | 3 |
| lapsed_policy | baseline | business_outcome | 2 |
| missing_mandatory_doc | injected | business_outcome | 2 |
| outside_coverage_period | baseline | business_outcome | 1 |
| paid_twice | injected | integrity_defect | 2 |
| settlement_exceeds_limit | injected | integrity_defect | 2 |
| suspected_fraud | baseline | business_outcome | 1 |

## Distributions (review point a)

- Claimed amount (USD): median 5,733.98, mean 14,324.65, p90 39,251.71, max 77,481.15 (right-skewed: mean > median)
- Claim types: AUTO: 17 | HLTH: 8 | HOME: 16 | LIAB: 7 | TRVL: 2
- Policy status at AS_OF: cancelled: 2 | expired: 11 | in force: 79 | lapsed: 8
- Final claim status: denied: 12 | docs_pending: 4 | paid: 29 | submitted: 1 | under_review: 4

## Reproducibility (same seed, two runs)

Two independent builds with seed 20261022 produced identical row counts and SHA-256 checksums: **True**

| File | Rows | SHA-256 (run 1) | Same in run 2 |
|---|---|---|---|
| csv/adjuster.csv | 10 | 195496bea0d1a0d2... | True |
| csv/assessment.csv | 50 | 1e923c160d37f8f9... | True |
| csv/claim.csv | 50 | 92290678839a3e09... | True |
| csv/claim_adjuster_assignment.csv | 56 | a184e7f619e010a1... | True |
| csv/claim_item.csv | 79 | 6b18eb7992e44451... | True |
| csv/claim_status_history.csv | 158 | f3042f4b8aacb389... | True |
| csv/coverage.csv | 16 | bf0f56c31d0c488b... | True |
| csv/customer.csv | 62 | af82ccfa70eb2dfb... | True |
| csv/document.csv | 116 | 8933acb28f860cd5... | True |
| csv/document_requirement.csv | 13 | 5c414630c1339248... | True |
| csv/incident.csv | 50 | 08d7280a0cf1c6a7... | True |
| csv/policy.csv | 100 | d7c158c0434dbd41... | True |
| csv/policy_coverage.csv | 237 | b28cc2529a201c1a... | True |
| csv/policy_event.csv | 121 | 463e18ed75aee505... | True |
| csv/reserve.csv | 29 | e310c94483cae754... | True |
| csv/settlement.csv | 31 | b981ac4bb0dda09b... | True |
| ground_truth.csv | 25 | c84dbd86e6edc531... | True |
| ground_truth.json | 25 | 2961ecc3ee3edc17... | True |
| ground_truth.sql | 25 | fc8464a66b6bc920... | True |
| json/adjuster.json | 10 | 6b5be53a0e76275b... | True |
| json/assessment.json | 50 | 1e94abbec79d3bcf... | True |
| json/claim.json | 50 | 05728d9a402aa231... | True |
| json/claim_adjuster_assignment.json | 56 | 49ae2f43fab03e65... | True |
| json/claim_item.json | 79 | 0a47d345bbdf0c0a... | True |
| json/claim_status_history.json | 158 | 259b509b79e05929... | True |
| json/coverage.json | 16 | c43d1af030655dc5... | True |
| json/customer.json | 62 | d4c867510719e676... | True |
| json/document.json | 116 | 352fac5629115afd... | True |
| json/document_requirement.json | 13 | bc2937023ade2830... | True |
| json/incident.json | 50 | 5bd735e2252c3d20... | True |
| json/policy.json | 100 | 3670c49467250e14... | True |
| json/policy_coverage.json | 237 | ccb75369c29fe3a5... | True |
| json/policy_event.json | 121 | 1a1c35692d602ec8... | True |
| json/reserve.json | 29 | c1c020a1d1bc4cd0... | True |
| json/settlement.json | 31 | 782507199eb41464... | True |
| seed.sql | 1178 | 3d58b11f47425c1a... | True |
