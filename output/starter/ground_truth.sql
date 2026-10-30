-- Answer key. Separate from the input tables; never join it into model or rule inputs.
-- Generated from src/claimsgen/schema.py; do not edit by hand.
CREATE TABLE ground_truth (
  entity_id TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  label TEXT NOT NULL,
  origin TEXT NOT NULL,
  kind TEXT NOT NULL,
  expected_decision TEXT NOT NULL,
  rule_id TEXT
);
BEGIN;
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000004', 'claim', 'lapsed_policy', 'baseline', 'business_outcome', 'deny: policy lapsed before the incident', 'R-COV-02');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000006', 'claim', 'boundary_incident_on_end', 'baseline', 'boundary', 'covered: an incident on the end date is in force', 'R-COV-02');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000009', 'claim', 'duplicate_incident', 'injected', 'business_outcome', 'refer_review: flag the later claim as a duplicate', 'R-ELG-03');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000011', 'claim', 'duplicate_incident', 'injected', 'business_outcome', 'refer_review: flag the later claim as a duplicate', 'R-ELG-03');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000016', 'claim', 'outside_coverage_period', 'baseline', 'business_outcome', 'deny: incident outside the coverage effective dates', 'R-COV-03');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000018', 'claim', 'suspected_fraud', 'baseline', 'business_outcome', 'refer_review: fraud score at or above the threshold', 'R-FRD-05');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000020', 'claim', 'incomplete_evidence', 'baseline', 'business_outcome', 'pend_docs: request the missing mandatory document; no payout until it arrives', 'R-DOC-01');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000021', 'claim', 'boundary_amount_at_limit', 'baseline', 'boundary', 'approve: claimed amount at the limit is paid minus the deductible', 'R-PAY-01');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000022', 'claim', 'boundary_amount_at_deductible', 'baseline', 'boundary', 'deny: amount equal to the deductible leaves a payable of zero', 'R-PAY-01');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000023', 'claim', 'boundary_incident_on_start', 'baseline', 'boundary', 'covered: an incident on the start date is in force', 'R-COV-02');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000026', 'claim', 'missing_mandatory_doc', 'injected', 'business_outcome', 'pend_docs: request the document, hold in docs_pending, no settlement', 'R-DOC-01');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000027', 'claim', 'missing_mandatory_doc', 'injected', 'business_outcome', 'pend_docs: request the document, hold in docs_pending, no settlement', 'R-DOC-01');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000028', 'claim', 'cancelled_before_incident', 'injected', 'business_outcome', 'deny: policy was cancelled before the incident', 'R-COV-02');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000029', 'claim', 'incomplete_evidence', 'baseline', 'business_outcome', 'pend_docs: request the missing mandatory document; no payout until it arrives', 'R-DOC-01');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000030', 'claim', 'claim_before_policy_start', 'injected', 'business_outcome', 'deny: at intake, coverage not yet effective', 'R-COV-01');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000037', 'claim', 'lapsed_policy', 'baseline', 'business_outcome', 'deny: policy lapsed before the incident', 'R-COV-02');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000038', 'claim', 'claim_over_limit', 'baseline', 'business_outcome', 'approve: pay no more than the remaining coverage limit (reason limit_reached)', 'R-PAY-01');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000042', 'claim', 'claim_before_policy_start', 'injected', 'business_outcome', 'deny: at intake, coverage not yet effective', 'R-COV-01');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000043', 'claim', 'cancelled_before_incident', 'injected', 'business_outcome', 'deny: policy was cancelled before the incident', 'R-COV-02');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000045', 'claim', 'incomplete_evidence', 'baseline', 'business_outcome', 'pend_docs: request the missing mandatory document; no payout until it arrives', 'R-DOC-01');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('CLM-2026-000047', 'claim', 'duplicate_incident', 'baseline', 'business_outcome', 'refer_review: flag the later claim as a duplicate', 'R-ELG-03');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('SET-CLM-2026-000024-002', 'settlement', 'paid_twice', 'injected', 'integrity_defect', 'flag: a claim is paid once; the second payment must be flagged', 'R-PAY-01');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('SET-CLM-2026-000031-002', 'settlement', 'paid_twice', 'injected', 'integrity_defect', 'flag: a claim is paid once; the second payment must be flagged', 'R-PAY-01');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('SET-CLM-2026-000033-001', 'settlement', 'settlement_exceeds_limit', 'injected', 'integrity_defect', 'flag: settlement should be 2404449 cents (R-PAY-01 payable, at most the limit 15000000)', 'R-PAY-01');
INSERT INTO ground_truth (entity_id, entity_type, label, origin, kind, expected_decision, rule_id) VALUES ('SET-CLM-2026-000046-001', 'settlement', 'settlement_exceeds_limit', 'injected', 'integrity_defect', 'flag: settlement should be 706922 cents (R-PAY-01 payable, at most the limit 10000000)', 'R-PAY-01');
COMMIT;
