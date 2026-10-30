# Validation summary

Seed 20261022 | scale 0.05 | AS_OF 2026-10-22 | currency USD

## Validation checks

Checks: 12 | passed: 10 | failed: 2 | failing ids: 4

| Category | Check | Rows checked | Failures | Result |
|---|---|---|---|---|
| keys | primary key uniqueness | 1190 | 0 | PASS |
| keys | ID format | 1190 | 0 | PASS |
| joins | foreign key integrity | 1553 | 0 | PASS |
| domain | enum values | 1538 | 0 | PASS |
| domain | required fields present | 6893 | 0 | PASS |
| domain | money is a non-negative integer (cents) | 1019 | 0 | PASS |
| dates | event dates not after AS_OF | 974 | 0 | PASS |
| leakage | no label or unexpected columns in input tables | 16 | 0 | PASS |
| dates | date order across the claim lifecycle | 185 | 0 | PASS |
| arithmetic | totals, payable, reserve and settlement reconcile | 118 | 2 | FAIL |
| lifecycle | legal transitions, approval before payment, roles | 85 | 4 | FAIL |
| duplicates | duplicate claims are referred; no duplicate documents | 169 | 0 | PASS |

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
| claim_item | 72 |
| document | 119 |
| claim_adjuster_assignment | 54 |
| assessment | 51 |
| reserve | 33 |
| settlement | 35 |
| claim_status_history | 167 |
| ground_truth | 25 |

### Failures: totals, payable, reserve and settlement reconcile

- `SET-CLM-2026-000025-001` recommended 8775064 != replayed 1062777
- `SET-CLM-2026-000049-001` recommended 10436313 != replayed 754207

### Failures: legal transitions, approval before payment, roles

- `SET-CLM-2026-000012-002` more than one settlement for a claim
- `SET-CLM-2026-000013-002` more than one settlement for a claim
- `SET-CLM-2026-000025-001` approver role does not match R-APR-01
- `SET-CLM-2026-000049-001` approver role does not match R-APR-01

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

- Claimed amount (USD): median 5,850.97, mean 13,763.93, p90 27,267.73, max 109,164.33 (right-skewed: mean > median)
- Claim types: AUTO: 14 | HLTH: 7 | HOME: 16 | LIAB: 7 | TRVL: 6
- Policy status at AS_OF: cancelled: 2 | expired: 11 | in force: 79 | lapsed: 8
- Final claim status: denied: 9 | docs_pending: 3 | paid: 33 | submitted: 1 | under_review: 4

## Reproducibility (same seed, two runs)

Two independent builds with seed 20261022 produced identical row counts and SHA-256 checksums: **True**

| File | Rows | SHA-256 (run 1) | Same in run 2 |
|---|---|---|---|
| csv/adjuster.csv | 10 | 195496bea0d1a0d2... | True |
| csv/assessment.csv | 51 | 68321237a978d6ac... | True |
| csv/claim.csv | 50 | 2a88300b01b0fd7e... | True |
| csv/claim_adjuster_assignment.csv | 54 | b8b00371b6770160... | True |
| csv/claim_item.csv | 72 | edddd661d833461c... | True |
| csv/claim_status_history.csv | 167 | e2e150ea93155131... | True |
| csv/coverage.csv | 16 | bf0f56c31d0c488b... | True |
| csv/customer.csv | 62 | af82ccfa70eb2dfb... | True |
| csv/document.csv | 119 | 7a38823eed017de3... | True |
| csv/document_requirement.csv | 13 | 5c414630c1339248... | True |
| csv/incident.csv | 50 | a7c9889bdb49405f... | True |
| csv/policy.csv | 100 | d7c158c0434dbd41... | True |
| csv/policy_coverage.csv | 237 | b28cc2529a201c1a... | True |
| csv/policy_event.csv | 121 | ed95da4b1125ff74... | True |
| csv/reserve.csv | 33 | 7f2226d5730a1eaf... | True |
| csv/settlement.csv | 35 | 08f36c22995c0850... | True |
| ground_truth.csv | 25 | e11b4e1cd10a1d70... | True |
| ground_truth.json | 25 | 90e47a95494be99c... | True |
| ground_truth.sql | 25 | 8b65793fbc1c6907... | True |
| json/adjuster.json | 10 | 6b5be53a0e76275b... | True |
| json/assessment.json | 51 | 5ba1de900b4651ae... | True |
| json/claim.json | 50 | 3a4d4ef91dc8c82d... | True |
| json/claim_adjuster_assignment.json | 54 | be9ec0696da02283... | True |
| json/claim_item.json | 72 | d182e18efa41d637... | True |
| json/claim_status_history.json | 167 | af795fb2ab247115... | True |
| json/coverage.json | 16 | c43d1af030655dc5... | True |
| json/customer.json | 62 | d4c867510719e676... | True |
| json/document.json | 119 | 2ff7a6086d8a3085... | True |
| json/document_requirement.json | 13 | bc2937023ade2830... | True |
| json/incident.json | 50 | f9631e91e2c138b6... | True |
| json/policy.json | 100 | 3670c49467250e14... | True |
| json/policy_coverage.json | 237 | ccb75369c29fe3a5... | True |
| json/policy_event.json | 121 | b4202bc372ef62f9... | True |
| json/reserve.json | 33 | fcbbffef63c50236... | True |
| json/settlement.json | 35 | a775e3f76904e669... | True |
| seed.sql | 1190 | c5b67a7b1269f775... | True |
