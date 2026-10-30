# Data dictionary

Generated from `src/claimsgen/schema.py`; do not edit by hand.
Dates are ISO `YYYY-MM-DD`; money is USD with 2 decimals.

## customer
A person who holds policies. PK `customer_id` pattern `CUS-\d{6}`.

| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |
|---|---|---|---|---|---|---|---|
| customer_id | id | Y | ^CUS-\d{6}$ |  | Y |  | primary key, immutable, zero-padded |
| full_name | text | Y |  |  | N |  | non-empty |
| dob | date | Y | YYYY-MM-DD |  | N |  | age 18-85 at AS_OF |
| region | text | Y |  |  | N |  | non-empty |
| created_date | date | Y | YYYY-MM-DD |  | N |  | <= AS_OF |

## coverage
Catalogue of protections. PK `coverage_id` pattern `COV-(AUTO|HOME|HLTH|TRVL|LIAB)-\d{3}`.

| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |
|---|---|---|---|---|---|---|---|
| coverage_id | id | Y | ^COV-(AUTO\|HOME\|HLTH\|TRVL\|LIAB)-\d{3}$ |  | Y |  | primary key, immutable, zero-padded |
| product | enum | Y | AUTO\|HOME\|HLTH\|TRVL\|LIAB |  | N |  |  |
| name | text | Y |  |  | N |  | non-empty |
| default_limit | money | Y | >= 0 | USD | N |  | > 0 |
| default_deductible | money | Y | >= 0 | USD | N |  | < default_limit |
| exclusion_codes | text | N |  |  | N |  | pipe-separated ITEM_TYPES, may be empty |

## adjuster
Claims handler. PK `adjuster_id` pattern `ADJ-\d{3}`.

| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |
|---|---|---|---|---|---|---|---|
| adjuster_id | id | Y | ^ADJ-\d{3}$ |  | Y |  | primary key, immutable, zero-padded |
| full_name | text | Y |  |  | N |  | non-empty |
| region | text | Y |  |  | N |  | non-empty |
| specialty | enum | Y | AUTO\|HOME\|HLTH\|TRVL\|LIAB |  | N |  |  |
| max_open_claims | int | Y | >= 0 | claims | N |  | >= 1 |

## document_requirement
Document types each claim type must have. PK `requirement_id` pattern `DRQ-(AUTO|HOME|HLTH|TRVL|LIAB)-[A-Z_]+`.

| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |
|---|---|---|---|---|---|---|---|
| requirement_id | id | Y | ^DRQ-(AUTO\|HOME\|HLTH\|TRVL\|LIAB)-[A-Z_]+$ |  | Y |  | primary key, immutable, zero-padded |
| claim_type | enum | Y | AUTO\|HOME\|HLTH\|TRVL\|LIAB |  | N |  |  |
| doc_type | enum | Y | photo\|police_report\|repair_estimate\|medical_report\|invoice\|proof_of_ownership\|itinerary\|incident_statement |  | N |  |  |
| mandatory | enum | Y | Y\|N |  | N |  |  |

## policy
Contract for one product. PK `policy_id` pattern `POL-(AUTO|HOME|HLTH|TRVL|LIAB)-2026-\d{6}`.

| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |
|---|---|---|---|---|---|---|---|
| policy_id | id | Y | ^POL-(AUTO\|HOME\|HLTH\|TRVL\|LIAB)-2026-\d{6}$ |  | Y |  | primary key, immutable, zero-padded |
| customer_id | id | Y |  |  | N | customer | must exist in customer |
| product | enum | Y | AUTO\|HOME\|HLTH\|TRVL\|LIAB |  | N |  | must equal the product segment of policy_id |
| start_date | date | Y | YYYY-MM-DD |  | N |  | start_date < end_date |
| end_date | date | Y | YYYY-MM-DD |  | N |  | > start_date |
| premium | money | Y | >= 0 | USD | N |  | > 0 |

## policy_event
Append-only policy lifecycle events. PK `event_id` pattern `PEV-POL-(AUTO|HOME|HLTH|TRVL|LIAB)-2026-\d{6}-\d{3}`.

| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |
|---|---|---|---|---|---|---|---|
| event_id | id | Y | ^PEV-POL-(AUTO\|HOME\|HLTH\|TRVL\|LIAB)-2026-\d{6}-\d{3}$ |  | Y |  | primary key, immutable, zero-padded |
| policy_id | id | Y |  |  | N | policy | must exist in policy |
| event_type | enum | Y | issued\|lapsed\|cancelled\|expired |  | N |  | first event is issued |
| event_date | date | Y | YYYY-MM-DD |  | N |  | within policy start..end window, <= AS_OF |

## policy_coverage
Bridge: coverage terms that apply to a policy. PK `policy_coverage_id` pattern `PCV-POL-(AUTO|HOME|HLTH|TRVL|LIAB)-2026-\d{6}-\d{3}`.

| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |
|---|---|---|---|---|---|---|---|
| policy_coverage_id | id | Y | ^PCV-POL-(AUTO\|HOME\|HLTH\|TRVL\|LIAB)-2026-\d{6}-\d{3}$ |  | Y |  | primary key, immutable, zero-padded |
| policy_id | id | Y |  |  | N | policy | must exist in policy |
| coverage_id | id | Y |  |  | N | coverage | must exist in coverage |
| limit_amount | money | Y | >= 0 | USD | N |  | > 0 |
| deductible | money | Y | >= 0 | USD | N |  | < limit_amount |
| effective_start | date | Y | YYYY-MM-DD |  | N |  | <= effective_end |
| effective_end | date | Y | YYYY-MM-DD |  | N |  | >= effective_start |

## incident
The event that triggers a claim. PK `incident_id` pattern `INC-2026-\d{6}`.

| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |
|---|---|---|---|---|---|---|---|
| incident_id | id | Y | ^INC-2026-\d{6}$ |  | Y |  | primary key, immutable, zero-padded |
| policy_id | id | Y |  |  | N | policy | must exist in policy |
| incident_date | date | Y | YYYY-MM-DD |  | N |  | <= claim submission_date except claim_before_policy_start path |
| incident_type | enum | Y | collision\|theft\|fire\|water_damage\|burglary\|illness\|injury\|trip_cancellation\|baggage_loss\|third_party_injury\|third_party_property |  | N |  | valid for the policy product |

## claim
Request for payment. PK `claim_id` pattern `CLM-2026-\d{6}`.

| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |
|---|---|---|---|---|---|---|---|
| claim_id | id | Y | ^CLM-2026-\d{6}$ |  | Y |  | primary key, immutable, zero-padded |
| policy_id | id | Y |  |  | N | policy | must exist in policy |
| incident_id | id | Y |  |  | N | incident | must exist in incident |
| claim_type | enum | Y | AUTO\|HOME\|HLTH\|TRVL\|LIAB |  | N |  | must equal policy product |
| submission_date | date | Y | YYYY-MM-DD |  | N |  | claim date; incident_date is separate |
| claimed_amount | money | Y | >= 0 | USD | N |  | equals sum of claim_item.claimed_amount |

## claim_item
One line of a claim. PK `item_id` pattern `ITM-CLM-2026-\d{6}-\d{3}`.

| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |
|---|---|---|---|---|---|---|---|
| item_id | id | Y | ^ITM-CLM-2026-\d{6}-\d{3}$ |  | Y |  | primary key, immutable, zero-padded |
| claim_id | id | Y |  |  | N | claim | must exist in claim |
| coverage_id | id | Y |  |  | N | coverage | must exist in coverage |
| item_type | enum | Y | repair\|replacement\|towing\|rental_car\|medical_treatment\|hospital_stay\|cancellation_fee\|baggage\|liability_payment\|cosmetic |  | N |  |  |
| claimed_amount | money | Y | >= 0 | USD | N |  | > 0 |

## document
Document metadata only. PK `document_id` pattern `DOC-CLM-2026-\d{6}-\d{3}`.

| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |
|---|---|---|---|---|---|---|---|
| document_id | id | Y | ^DOC-CLM-2026-\d{6}-\d{3}$ |  | Y |  | primary key, immutable, zero-padded |
| claim_id | id | Y |  |  | N | claim | must exist in claim |
| doc_type | enum | Y | photo\|police_report\|repair_estimate\|medical_report\|invoice\|proof_of_ownership\|itinerary\|incident_statement |  | N |  |  |
| received_date | date | Y | YYYY-MM-DD |  | N |  | >= claim submission_date |
| status | enum | Y | received\|rejected |  | N |  |  |

## claim_adjuster_assignment
Adjuster assignment record; reassignment is a new row. PK `assignment_id` pattern `ASN-CLM-2026-\d{6}-\d{3}`.

| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |
|---|---|---|---|---|---|---|---|
| assignment_id | id | Y | ^ASN-CLM-2026-\d{6}-\d{3}$ |  | Y |  | primary key, immutable, zero-padded |
| claim_id | id | Y |  |  | N | claim | must exist in claim |
| adjuster_id | id | Y |  |  | N | adjuster | must exist in adjuster |
| assigned_date | date | Y | YYYY-MM-DD |  | N |  | >= claim submission_date |
| reason | enum | Y | initial\|reassigned\|workload |  | N |  |  |

## assessment
Decision with reason; new row when re-run. PK `assessment_id` pattern `ASM-CLM-2026-\d{6}-\d{3}`.

| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |
|---|---|---|---|---|---|---|---|
| assessment_id | id | Y | ^ASM-CLM-2026-\d{6}-\d{3}$ |  | Y |  | primary key, immutable, zero-padded |
| claim_id | id | Y |  |  | N | claim | must exist in claim |
| adjuster_id | id | Y |  |  | N | adjuster | must exist in adjuster |
| assessment_date | date | Y | YYYY-MM-DD |  | N |  | >= assignment date |
| decision | enum | Y | approve\|deny\|pend_docs\|refer_review |  | N |  |  |
| rule_id | text | Y | R-[A-Z]{3}-\d{2} |  | N |  | rule catalogue id |
| reason_code | enum | Y | submitted\|before_policy_start\|policy_not_in_force\|outside_coverage_period\|duplicate_claim\|missing_document\|suspected_fraud\|item_not_covered\|item_excluded\|eligible\|within_deductible\|limit_reached\|docs_received\|approved_by_authority\|payment_recorded\|reassigned |  | N |  |  |
| eligible_amount | money | Y | >= 0 | USD | N |  | <= claimed_amount |
| deductible_applied | money | Y | >= 0 | USD | N |  | per R-PAY-01 |
| payable_amount | money | Y | >= 0 | USD | N |  | per R-PAY-01 |
| fraud_score | ratio | Y | 0..1 |  | N |  | flags / 4 |

## reserve
Append-only reserve history. PK `reserve_id` pattern `RSV-CLM-2026-\d{6}-\d{3}`.

| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |
|---|---|---|---|---|---|---|---|
| reserve_id | id | Y | ^RSV-CLM-2026-\d{6}-\d{3}$ |  | Y |  | primary key, immutable, zero-padded |
| claim_id | id | Y |  |  | N | claim | must exist in claim |
| reserve_date | date | Y | YYYY-MM-DD |  | N |  | >= assessment_date |
| amount | money | Y | >= 0 | USD | N |  | latest = final payable |
| basis | enum | Y | preliminary\|revised |  | N |  |  |
| rule_id | text | Y | R-[A-Z]{3}-\d{2} |  | N |  | R-RSV-01 |

## settlement
Write-once; stage = which dates are filled. PK `settlement_id` pattern `SET-CLM-2026-\d{6}-\d{3}`.

| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |
|---|---|---|---|---|---|---|---|
| settlement_id | id | Y | ^SET-CLM-2026-\d{6}-\d{3}$ |  | Y |  | primary key, immutable, zero-padded |
| claim_id | id | Y |  |  | N | claim | must exist in claim |
| recommended_amount | money | Y | >= 0 | USD | N |  | <= remaining policy_coverage limit |
| recommended_date | date | Y | YYYY-MM-DD |  | N |  | <= AS_OF |
| approved_amount | money | N | >= 0 | USD | N |  | = recommended_amount |
| approved_date | date | N | YYYY-MM-DD |  | N |  | >= recommended_date |
| approver_role | enum | N | process_owner\|approver |  | N |  | approver if amount > threshold |
| paid_amount | money | N | >= 0 | USD | N |  | <= approved_amount |
| paid_date | date | N | YYYY-MM-DD |  | N |  | >= approved_date |

## claim_status_history
Append-only claim event log; claim status = last event. PK `event_id` pattern `EVT-CLM-2026-\d{6}-\d{3}`.

| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |
|---|---|---|---|---|---|---|---|
| event_id | id | Y | ^EVT-CLM-2026-\d{6}-\d{3}$ |  | Y |  | primary key, immutable, zero-padded |
| claim_id | id | Y |  |  | N | claim | must exist in claim |
| from_status | enum | N | submitted\|denied\|docs_pending\|under_review\|assessed\|approved\|paid |  | N |  | empty only for the first event |
| to_status | enum | Y | submitted\|denied\|docs_pending\|under_review\|assessed\|approved\|paid |  | N |  | legal transition from from_status |
| event_date | date | Y | YYYY-MM-DD |  | N |  | non-decreasing per claim |
| actor_role | enum | Y | requester\|process_owner\|approver\|operations_analyst\|administrator |  | N |  |  |
| rule_id | text | N | R-[A-Z]{3}-\d{2} |  | N |  | rule catalogue id |
| reason_code | enum | Y | submitted\|before_policy_start\|policy_not_in_force\|outside_coverage_period\|duplicate_claim\|missing_document\|suspected_fraud\|item_not_covered\|item_excluded\|eligible\|within_deductible\|limit_reached\|docs_received\|approved_by_authority\|payment_recorded\|reassigned |  | N |  |  |

## ground_truth
Separate answer key; never joined into inputs. PK `entity_id` pattern `any entity id`.

| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |
|---|---|---|---|---|---|---|---|
| entity_id | id | Y |  |  | N |  | id of the labelled row (unique with label) |
| entity_type | text | Y |  |  | N |  | table name |
| label | enum | Y | claim_before_policy_start\|cancelled_before_incident\|duplicate_incident\|settlement_exceeds_limit\|missing_mandatory_doc\|paid_twice\|lapsed_policy\|outside_coverage_period\|incomplete_evidence\|claim_over_limit\|suspected_fraud\|boundary_incident_on_start\|boundary_incident_on_end\|boundary_amount_at_limit\|boundary_amount_at_deductible |  | N |  |  |
| origin | enum | Y | baseline\|injected |  | N |  |  |
| kind | enum | Y | business_outcome\|integrity_defect\|boundary |  | N |  |  |
| expected_decision | text | Y |  |  | N |  | non-empty |
| rule_id | text | N | R-[A-Z]{3}-\d{2} |  | N |  | rule that applies |
