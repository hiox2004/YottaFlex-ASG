# Validation summary

Seed 20261022 | scale 0.05 | AS_OF 2026-10-22 | currency USD

## Validation checks

Checks: 12 | passed: 10 | failed: 2 | failing ids: 4

| Category | Check | Rows checked | Failures | Result |
|---|---|---|---|---|
| keys | primary key uniqueness | 1223 | 0 | PASS |
| keys | ID format | 1223 | 0 | PASS |
| joins | foreign key integrity | 1588 | 0 | PASS |
| domain | enum values | 1529 | 0 | PASS |
| domain | required fields present | 7091 | 0 | PASS |
| domain | money is a non-negative integer (cents) | 1055 | 0 | PASS |
| dates | event dates not after AS_OF | 992 | 0 | PASS |
| leakage | no label or unexpected columns in input tables | 16 | 0 | PASS |
| dates | date order across the claim lifecycle | 180 | 0 | PASS |
| arithmetic | totals, payable, reserve and settlement reconcile | 158 | 2 | FAIL |
| lifecycle | legal transitions, approval before payment, roles | 80 | 4 | FAIL |
| duplicates | duplicate claims are referred; no duplicate documents | 165 | 0 | PASS |

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
| claim_item | 77 |
| document | 115 |
| claim_adjuster_assignment | 53 |
| assessment | 49 |
| reserve | 85 |
| settlement | 30 |
| claim_status_history | 155 |
| ground_truth | 25 |

### Failures: totals, payable, reserve and settlement reconcile

- `SET-CLM-2026-000041-001` recommended 5350823 != replayed 1216510
- `SET-CLM-2026-000045-001` recommended 5244345 != replayed 740086

### Failures: legal transitions, approval before payment, roles

- `SET-CLM-2026-000020-002` more than one settlement for a claim
- `SET-CLM-2026-000035-002` more than one settlement for a claim
- `SET-CLM-2026-000041-001` approver role does not match R-APR-01
- `SET-CLM-2026-000045-001` approver role does not match R-APR-01

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

- Claimed amount (USD): median 5,204.79, mean 13,103.26, p90 38,739.80, max 77,481.15 (right-skewed: mean > median)
- Claim types: AUTO: 17 | HLTH: 9 | HOME: 15 | LIAB: 7 | TRVL: 2
- Policy status at AS_OF: cancelled: 2 | expired: 11 | in force: 79 | lapsed: 8
- Final claim status: denied: 12 | docs_pending: 4 | paid: 28 | submitted: 2 | under_review: 4

## Reproducibility (same seed, two runs)

Two independent builds with seed 20261022 produced identical row counts and SHA-256 checksums: **True**

| File | Rows | SHA-256 (run 1) | Same in run 2 |
|---|---|---|---|
| csv/adjuster.csv | 10 | 195496bea0d1a0d2... | True |
| csv/assessment.csv | 49 | 7be934491ed03e57... | True |
| csv/claim.csv | 50 | f32fcd2b0c08b7ab... | True |
| csv/claim_adjuster_assignment.csv | 53 | 8bf02a10699ae180... | True |
| csv/claim_item.csv | 77 | 434810f5ea12bff0... | True |
| csv/claim_status_history.csv | 155 | ed2553d9a1df688a... | True |
| csv/coverage.csv | 16 | bf0f56c31d0c488b... | True |
| csv/customer.csv | 62 | af82ccfa70eb2dfb... | True |
| csv/document.csv | 115 | 24ffb296c625c490... | True |
| csv/document_requirement.csv | 13 | 5c414630c1339248... | True |
| csv/incident.csv | 50 | fbefc66fac0ba8aa... | True |
| csv/policy.csv | 100 | d7c158c0434dbd41... | True |
| csv/policy_coverage.csv | 237 | b28cc2529a201c1a... | True |
| csv/policy_event.csv | 121 | ec8d8e3f1dddc1ec... | True |
| csv/reserve.csv | 85 | 5eacb32a90333b23... | True |
| csv/settlement.csv | 30 | 49154fc1ea10872c... | True |
| ground_truth.csv | 25 | 79e2bf31317d7582... | True |
| ground_truth.json | 25 | dc0834775a1fb645... | True |
| ground_truth.sql | 25 | 1bb3687a4302e1d9... | True |
| json/adjuster.json | 10 | 6b5be53a0e76275b... | True |
| json/assessment.json | 49 | 1f99d471e54e4ab4... | True |
| json/claim.json | 50 | e438be94a06c9bdb... | True |
| json/claim_adjuster_assignment.json | 53 | 88724cb168dbb577... | True |
| json/claim_item.json | 77 | f9e3efdce3f7a60e... | True |
| json/claim_status_history.json | 155 | cc8cf50a2a09a4c7... | True |
| json/coverage.json | 16 | c43d1af030655dc5... | True |
| json/customer.json | 62 | d4c867510719e676... | True |
| json/document.json | 115 | c1bba511c2bf3485... | True |
| json/document_requirement.json | 13 | bc2937023ade2830... | True |
| json/incident.json | 50 | 763e8472d80478f7... | True |
| json/policy.json | 100 | 3670c49467250e14... | True |
| json/policy_coverage.json | 237 | ccb75369c29fe3a5... | True |
| json/policy_event.json | 121 | 68b2f45cbd0d97fa... | True |
| json/reserve.json | 85 | 78bf51c911f27a32... | True |
| json/settlement.json | 30 | 7426758405e987e8... | True |
| seed.sql | 1223 | 1fe3ccfe83a931b1... | True |
