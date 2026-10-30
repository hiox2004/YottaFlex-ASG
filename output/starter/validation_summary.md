# Validation summary

Seed 20261022 | scale 0.05 | AS_OF 2026-10-22 | currency USD

## Validation checks

Checks: 12 | passed: 10 | failed: 2 | failing ids: 4

| Category | Check | Rows checked | Failures | Result |
|---|---|---|---|---|
| keys | primary key uniqueness | 1175 | 0 | PASS |
| keys | ID format | 1175 | 0 | PASS |
| joins | foreign key integrity | 1543 | 0 | PASS |
| domain | enum values | 1494 | 0 | PASS |
| domain | required fields present | 6805 | 0 | PASS |
| domain | money is a non-negative integer (cents) | 1008 | 0 | PASS |
| dates | event dates not after AS_OF | 949 | 0 | PASS |
| leakage | no label or unexpected columns in input tables | 16 | 0 | PASS |
| dates | date order across the claim lifecycle | 182 | 0 | PASS |
| arithmetic | totals, payable, reserve and settlement reconcile | 112 | 2 | FAIL |
| lifecycle | legal transitions, approval before payment, roles | 82 | 4 | FAIL |
| duplicates | duplicate claims are referred; no duplicate documents | 162 | 0 | PASS |

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
| claim_item | 76 |
| document | 112 |
| claim_adjuster_assignment | 56 |
| assessment | 50 |
| reserve | 30 |
| settlement | 32 |
| claim_status_history | 160 |
| ground_truth | 25 |

### Failures: totals, payable, reserve and settlement reconcile

- `SET-CLM-2026-000038-001` recommended 21937661 != replayed 170422
- `SET-CLM-2026-000047-001` recommended 8349050 != replayed 1420363

### Failures: legal transitions, approval before payment, roles

- `SET-CLM-2026-000026-002` more than one settlement for a claim
- `SET-CLM-2026-000038-001` approver role does not match R-APR-01
- `SET-CLM-2026-000039-002` more than one settlement for a claim
- `SET-CLM-2026-000047-001` approver role does not match R-APR-01

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

- Claimed amount (USD): median 5,204.79, mean 14,099.15, p90 38,164.13, max 83,548.58 (right-skewed: mean > median)
- Claim types: AUTO: 20 | HLTH: 10 | HOME: 12 | LIAB: 5 | TRVL: 3
- Policy status at AS_OF: cancelled: 2 | expired: 11 | in force: 79 | lapsed: 8
- Final claim status: denied: 11 | docs_pending: 4 | paid: 30 | submitted: 1 | under_review: 4

## Reproducibility (same seed, two runs)

Two independent builds with seed 20261022 produced identical row counts and SHA-256 checksums: **True**

| File | Rows | SHA-256 (run 1) | Same in run 2 |
|---|---|---|---|
| csv/adjuster.csv | 10 | 195496bea0d1a0d2... | True |
| csv/assessment.csv | 50 | b93bd598e044ac17... | True |
| csv/claim.csv | 50 | c3a54a275292c985... | True |
| csv/claim_adjuster_assignment.csv | 56 | f80c5dc6637523ac... | True |
| csv/claim_item.csv | 76 | 5802ad2bff9619a4... | True |
| csv/claim_status_history.csv | 160 | 23e4b253d2adf651... | True |
| csv/coverage.csv | 16 | bf0f56c31d0c488b... | True |
| csv/customer.csv | 62 | af82ccfa70eb2dfb... | True |
| csv/document.csv | 112 | ea0cd9f41993cee4... | True |
| csv/document_requirement.csv | 13 | 5c414630c1339248... | True |
| csv/incident.csv | 50 | d3bc851008cf4add... | True |
| csv/policy.csv | 100 | d7c158c0434dbd41... | True |
| csv/policy_coverage.csv | 237 | b28cc2529a201c1a... | True |
| csv/policy_event.csv | 121 | 231a2c654088e1be... | True |
| csv/reserve.csv | 30 | 4d0ba55a56477315... | True |
| csv/settlement.csv | 32 | eaa34b457c7cd912... | True |
| ground_truth.csv | 25 | d2a1a4ec4029fb97... | True |
| ground_truth.json | 25 | e40ba9bd69d7fcbe... | True |
| ground_truth.sql | 25 | 4ac19a3e56b17792... | True |
| json/adjuster.json | 10 | 6b5be53a0e76275b... | True |
| json/assessment.json | 50 | 6b5f81495f942348... | True |
| json/claim.json | 50 | 8de80842395b5f2f... | True |
| json/claim_adjuster_assignment.json | 56 | c99e85ac9367bc8f... | True |
| json/claim_item.json | 76 | 72747a69816e3ff2... | True |
| json/claim_status_history.json | 160 | be6ecef30fdb74f7... | True |
| json/coverage.json | 16 | c43d1af030655dc5... | True |
| json/customer.json | 62 | d4c867510719e676... | True |
| json/document.json | 112 | 3b502222ca6b29f3... | True |
| json/document_requirement.json | 13 | bc2937023ade2830... | True |
| json/incident.json | 50 | f02304ebef2d7815... | True |
| json/policy.json | 100 | 3670c49467250e14... | True |
| json/policy_coverage.json | 237 | ccb75369c29fe3a5... | True |
| json/policy_event.json | 121 | d19ad11955f50a95... | True |
| json/reserve.json | 30 | 15f7d363562dd34d... | True |
| json/settlement.json | 32 | c4f59ce4977d9931... | True |
| seed.sql | 1175 | 5382e6fa8c4f342e... | True |
