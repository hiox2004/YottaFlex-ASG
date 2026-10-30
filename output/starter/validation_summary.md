# Validation summary

Seed 20261022 | scale 0.05 | AS_OF 2026-10-22 | currency USD

## Validation checks

Checks: 12 | passed: 10 | failed: 2 | failing ids: 4

| Category | Check | Rows checked | Failures | Result |
|---|---|---|---|---|
| keys | primary key uniqueness | 1164 | 0 | PASS |
| keys | ID format | 1164 | 0 | PASS |
| joins | foreign key integrity | 1526 | 0 | PASS |
| domain | enum values | 1470 | 0 | PASS |
| domain | required fields present | 6743 | 0 | PASS |
| domain | money is a non-negative integer (cents) | 992 | 0 | PASS |
| dates | event dates not after AS_OF | 934 | 0 | PASS |
| leakage | no label or unexpected columns in input tables | 16 | 0 | PASS |
| dates | date order across the claim lifecycle | 179 | 0 | PASS |
| arithmetic | totals, payable, reserve and settlement reconcile | 106 | 2 | FAIL |
| lifecycle | legal transitions, approval before payment, roles | 79 | 4 | FAIL |
| duplicates | duplicate claims are referred; no duplicate documents | 170 | 0 | PASS |

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
| claim_item | 73 |
| document | 120 |
| claim_adjuster_assignment | 53 |
| assessment | 50 |
| reserve | 27 |
| settlement | 29 |
| claim_status_history | 153 |
| ground_truth | 25 |

### Failures: totals, payable, reserve and settlement reconcile

- `SET-CLM-2026-000024-001` recommended 8775064 != replayed 840221
- `SET-CLM-2026-000039-001` recommended 3478771 != replayed 210505

### Failures: legal transitions, approval before payment, roles

- `SET-CLM-2026-000008-002` more than one settlement for a claim
- `SET-CLM-2026-000023-002` more than one settlement for a claim
- `SET-CLM-2026-000024-001` approver role does not match R-APR-01
- `SET-CLM-2026-000039-001` approver role does not match R-APR-01

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

- Claimed amount (USD): median 2,398.79, mean 7,951.47, p90 13,620.77, max 109,164.33 (right-skewed: mean > median)
- Claim types: AUTO: 15 | HLTH: 6 | HOME: 15 | LIAB: 7 | TRVL: 7
- Policy status at AS_OF: cancelled: 2 | expired: 11 | in force: 79 | lapsed: 8
- Final claim status: approved: 1 | denied: 14 | docs_pending: 3 | paid: 26 | submitted: 2 | under_review: 4

## Reproducibility (same seed, two runs)

Two independent builds with seed 20261022 produced identical row counts and SHA-256 checksums: **True**

| File | Rows | SHA-256 (run 1) | Same in run 2 |
|---|---|---|---|
| csv/adjuster.csv | 10 | 195496bea0d1a0d2... | True |
| csv/assessment.csv | 50 | cbdcf5e8c21e04c8... | True |
| csv/claim.csv | 50 | f064d0b1202d74c3... | True |
| csv/claim_adjuster_assignment.csv | 53 | 9a59d7b61fd48068... | True |
| csv/claim_item.csv | 73 | 4091f794fb93a074... | True |
| csv/claim_status_history.csv | 153 | 6c631a262208953e... | True |
| csv/coverage.csv | 16 | bf0f56c31d0c488b... | True |
| csv/customer.csv | 62 | af82ccfa70eb2dfb... | True |
| csv/document.csv | 120 | 3a84c640774a99d9... | True |
| csv/document_requirement.csv | 13 | 5c414630c1339248... | True |
| csv/incident.csv | 50 | 6d7e35385d8bba0f... | True |
| csv/policy.csv | 100 | d7c158c0434dbd41... | True |
| csv/policy_coverage.csv | 237 | b28cc2529a201c1a... | True |
| csv/policy_event.csv | 121 | 2e8f9b6119985945... | True |
| csv/reserve.csv | 27 | 3f974e9d1ed0c489... | True |
| csv/settlement.csv | 29 | 2bf8ca7285fdf23f... | True |
| ground_truth.csv | 25 | d7e7629fce71cfcb... | True |
| ground_truth.json | 25 | 42c1b37ac65b6002... | True |
| ground_truth.sql | 25 | 7fd0f2cd54a2ee62... | True |
| json/adjuster.json | 10 | 6b5be53a0e76275b... | True |
| json/assessment.json | 50 | 26957ecdcc6ad5c2... | True |
| json/claim.json | 50 | d22f63e6b1f6be72... | True |
| json/claim_adjuster_assignment.json | 53 | cac7eb3f43de81c4... | True |
| json/claim_item.json | 73 | da95d401b66feb4c... | True |
| json/claim_status_history.json | 153 | 74c1069b90ae1789... | True |
| json/coverage.json | 16 | c43d1af030655dc5... | True |
| json/customer.json | 62 | d4c867510719e676... | True |
| json/document.json | 120 | a2a8745541e8b5a2... | True |
| json/document_requirement.json | 13 | bc2937023ade2830... | True |
| json/incident.json | 50 | 4d01388f5062ca13... | True |
| json/policy.json | 100 | 3670c49467250e14... | True |
| json/policy_coverage.json | 237 | ccb75369c29fe3a5... | True |
| json/policy_event.json | 121 | 362e3d49cacc0b83... | True |
| json/reserve.json | 27 | 2eb15813b8bfedc5... | True |
| json/settlement.json | 29 | d9ec2afb82fdcd0e... | True |
| seed.sql | 1164 | 189b05260d6d9c70... | True |
