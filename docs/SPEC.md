# SPEC: Claims Synthetic Data Challenge (condensed from the Understanding Brief)

## Deliverables (each needs reviewer-checkable proof)
1. Data dictionary, all entities: type, required, allowed values, units, uniqueness, validation rule (one row per field)
2. Generator, parents first then children/events; one command builds starter + full; scale is a parameter
3. Deterministic zero-padded IDs in the five given formats, identical across files
4. Baseline 2,000 policies, 1,000 claims, 5 claim types; counts in validation summary
5. Six labelled edge cases injected after a clean baseline, each present and counted
6. Derived values computed from sources (totals, balances, reserves, statuses reconcile)
7. Separate ground_truth.csv/json, not joined into any input table
8. Validation report: PK uniqueness, FK integrity, enums, date order, arithmetic, lifecycle, duplicates
9. Export + docs: CSV, JSON, SQL seed, README, schema, generator command, seed, source manifest, validation summary
10. Reproducibility proof: two same-seed runs, matching row counts and SHA-256 checksums

## Entities (PK -> FK)
| Entity | PK | FK |
|---|---|---|
| Customer | CUS-000001 (proposed) | - |
| Policy | POL-<product>-2026-000001 | customer_id |
| Coverage | COV-<product>-001 (proposed) | - (N:M Policy via policy_coverage) |
| Incident | INC-2026-000001 (proposed) | policy_id |
| Claim | CLM-2026-000001 | policy_id, incident_id |
| ClaimItem | ITM-<claimid>-001 (proposed) | claim_id, coverage_id |
| Document | DOC-<claimid>-001 (e.g. DOC-CLM-2026-000001-001) | claim_id |
| Adjuster | ADJ-001 (proposed) | - (N:M Claim via assignments) |
| Assessment | ASM-<claimid>-001 (proposed) | claim_id, adjuster_id |
| Reserve | RSV-<claimid>-001 (proposed) | claim_id (change = new row) |
| Settlement | SET-<claimid>-001 | claim_id (0/1 per claim; 2 only paid_twice) |

Implied extra tables: policy_coverage, claim_adjuster_assignment (ASN-<claimid>-001), claim_status_history
(event log, actor role + reason), document_requirement, ground_truth.

## Workflow rules (each decision stores a rule ID, e.g. R-COV-02, and a reason)
- Coverage: submitted on/after policy start; policy active on incident date; incident within coverage effective dates.
- Documents: every type required for the claim type is present, else docs-pending, no payout.
- Eligibility: item covered, no exclusion, not a duplicate (duplicate/fraud -> review).
- Payable: eligible amount - deductible, floor 0, capped at remaining limit. Preliminary reserve uses same calc.
- Audit: every state change is a new event with actor role and reason.
- Actors: requester, process owner, approver, operations analyst, administrator. Settlements above a threshold need approver.

## Mandatory edge cases (labels only in ground_truth; mark kind = business outcome vs integrity defect + expected decision)
| Case | Inject | Expected | Label |
|---|---|---|---|
| Claim date before policy start | submission date < start | reject at intake | claim_before_policy_start |
| Policy cancelled before incident | cancellation event, incident after | deny, history shows cancel | cancelled_before_incident |
| Duplicate incident | clone policy/date/type into second claim | flag duplicate, review | duplicate_incident |
| Settlement exceeds limit | settlement > coverage limit | validator catches; correct = capped | settlement_exceeds_limit |
| Missing mandatory document | drop a required doc type | request doc, docs-pending, no settlement | missing_mandatory_doc |
| Claim paid twice | second paid settlement | validator flags second | paid_twice |

Also: lapsed policies, incidents outside coverage, incomplete evidence, amounts over limits, fraud indicators.
Boundary cases: incident on start/end date, amount exactly at limit, amount at deductible.

## Settled decisions (2026-10-30)
- Baseline conditions from brief step 4 (lapsed policies, duplicate claims, outside-coverage incidents, incomplete evidence,
  over-limit amounts, fraud indicators) are produced by the rules and recorded in ground_truth with
  `origin=baseline`, `kind=business_outcome`. The six step-5 cases use `origin=injected`.
- One label per concept: organic duplicate claims and the injected duplicate incident share `duplicate_incident`,
  told apart by `origin`. Injected cases get 10-30 rows each; baseline rows are counted separately.
- ground_truth columns: entity_id, entity_type, label, origin, kind (business_outcome | integrity_defect), expected_decision, rule_id.
- Starter = scale 0.05 (100 policies, 50 claims); full = scale 1.0 (2,000 policies, 1,000 claims). Same generator.

## Review points (a-g)
a. Realistic distributions (right-skewed amounts, uneven type mix) · b. ID regex + 100% FK match ·
c. Lifecycle order (policy start, incident, claim, assessment, settlement; no payment w/o approval) ·
d. Derived values recompute exactly · e. Normal/boundary/failure/exception cases ·
f. Ground truth separate, no leakage (test proves it) · g. Reproducibility + provenance (source manifest: fully synthetic)

## Assumptions (state in README)
Products AUTO/HOME/HLTH/TRVL/LIAB one per claim type · ASN = adjuster assignment, reassignment = -002 ·
claim date = submission date, incident date separate · 1,000 claims include duplicates/anomalies ·
USD · fixed as-of date in config · generator + rules engine + metrics report + small UI last.

## Stand-out items
Rule catalogue with reason codes · precision/recall of own engine vs ground truth + operational metrics ·
runnable validation suite (non-zero exit on failure) · one-command reproducibility proof · approval authority matrix ·
transparent fraud-indicator score · starter dataset + reviewer's guide.

## Data dictionary
TODO: filled in the first build step (one row per field per entity).
