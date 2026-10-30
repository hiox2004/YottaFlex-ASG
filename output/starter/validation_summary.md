# Validation summary

Seed 20261022 | scale 0.05 | AS_OF 2026-10-22 | currency USD

## Validation checks

Checks: 12 | passed: 10 | failed: 2 | failing ids: 4

| Category | Check | Rows checked | Failures | Result |
|---|---|---|---|---|
| keys | primary key uniqueness | 1177 | 0 | PASS |
| keys | ID format | 1177 | 0 | PASS |
| joins | foreign key integrity | 1539 | 0 | PASS |
| domain | enum values | 1502 | 0 | PASS |
| domain | required fields present | 6773 | 0 | PASS |
| domain | money is a non-negative integer (cents) | 1012 | 0 | PASS |
| dates | event dates not after AS_OF | 953 | 0 | PASS |
| leakage | no label or unexpected columns in input tables | 16 | 0 | PASS |
| dates | date order across the claim lifecycle | 184 | 0 | PASS |
| arithmetic | totals, payable, reserve and settlement reconcile | 116 | 2 | FAIL |
| lifecycle | legal transitions, approval before payment, roles | 84 | 3 | FAIL |
| duplicates | duplicate claims are referred; no duplicate documents | 164 | 0 | PASS |

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
| claim_item | 78 |
| document | 114 |
| claim_adjuster_assignment | 50 |
| assessment | 48 |
| reserve | 32 |
| settlement | 34 |
| claim_status_history | 162 |
| ground_truth | 25 |

### Failures: totals, payable, reserve and settlement reconcile

- `SET-CLM-2026-000033-001` recommended 16453246 != replayed 2404449
- `SET-CLM-2026-000046-001` recommended 13915084 != replayed 706922

### Failures: legal transitions, approval before payment, roles

- `SET-CLM-2026-000024-002` more than one settlement for a claim
- `SET-CLM-2026-000031-002` more than one settlement for a claim
- `SET-CLM-2026-000046-001` approver role does not match R-APR-01

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

- Claimed amount (USD): median 4,980.30, mean 11,008.20, p90 21,745.62, max 124,790.38 (right-skewed: mean > median)
- Claim types: AUTO: 19 | HLTH: 3 | HOME: 19 | LIAB: 6 | TRVL: 3
- Policy status at AS_OF: cancelled: 2 | expired: 11 | in force: 79 | lapsed: 8
- Final claim status: denied: 8 | docs_pending: 3 | paid: 32 | submitted: 4 | under_review: 3

## Reproducibility (same seed, two runs)

Two independent builds with seed 20261022 produced identical row counts and SHA-256 checksums: **True**

| File | Rows | SHA-256 (run 1) | Same in run 2 |
|---|---|---|---|
| csv/adjuster.csv | 10 | 195496bea0d1a0d2... | True |
| csv/assessment.csv | 48 | c9f9601a86245494... | True |
| csv/claim.csv | 50 | 3111f8fbddb6fb0c... | True |
| csv/claim_adjuster_assignment.csv | 50 | b43dc57fb9739a35... | True |
| csv/claim_item.csv | 78 | fea3e3abc5567ce5... | True |
| csv/claim_status_history.csv | 162 | 990fd0da83af1be3... | True |
| csv/coverage.csv | 16 | 36a63e9f28d6b855... | True |
| csv/customer.csv | 62 | af82ccfa70eb2dfb... | True |
| csv/document.csv | 114 | cd01fc947cf9ae42... | True |
| csv/document_requirement.csv | 13 | 5c414630c1339248... | True |
| csv/incident.csv | 50 | ff10c184a3a344f6... | True |
| csv/policy.csv | 100 | d7c158c0434dbd41... | True |
| csv/policy_coverage.csv | 237 | b28cc2529a201c1a... | True |
| csv/policy_event.csv | 121 | 83afba635fa61642... | True |
| csv/reserve.csv | 32 | 347e8449d3a9fcae... | True |
| csv/settlement.csv | 34 | eda364bc4404bc93... | True |
| ground_truth.csv | 25 | f37728aa91b50067... | True |
| ground_truth.json | 25 | f2f11e854d0c3cf2... | True |
| ground_truth.sql | 25 | 5de48e81ad5c469a... | True |
| json/adjuster.json | 10 | 6b5be53a0e76275b... | True |
| json/assessment.json | 48 | 2f6554182137e80f... | True |
| json/claim.json | 50 | 59d827bcdca767ca... | True |
| json/claim_adjuster_assignment.json | 50 | f6d3584450b3ed31... | True |
| json/claim_item.json | 78 | 2bee1885306e123c... | True |
| json/claim_status_history.json | 162 | b9abf545b9b2a0c0... | True |
| json/coverage.json | 16 | 0975df2afd9cf6ae... | True |
| json/customer.json | 62 | d4c867510719e676... | True |
| json/document.json | 114 | 39990eac20b8106d... | True |
| json/document_requirement.json | 13 | bc2937023ade2830... | True |
| json/incident.json | 50 | 719c28ed0729e03e... | True |
| json/policy.json | 100 | 3670c49467250e14... | True |
| json/policy_coverage.json | 237 | ccb75369c29fe3a5... | True |
| json/policy_event.json | 121 | 6f852b5381eef238... | True |
| json/reserve.json | 32 | 247c747802441ee8... | True |
| json/settlement.json | 34 | 571793c15e4c1f41... | True |
| seed.sql | 1177 | 1cfe8cc5be185b88... | True |
