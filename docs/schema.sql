-- Generated from src/claimsgen/schema.py; do not edit by hand.
CREATE TABLE customer (
  customer_id TEXT NOT NULL,
  full_name TEXT NOT NULL,
  dob TEXT NOT NULL,
  region TEXT NOT NULL,
  created_date TEXT NOT NULL,
  PRIMARY KEY (customer_id)
);
CREATE TABLE coverage (
  coverage_id TEXT NOT NULL,
  product TEXT NOT NULL,
  name TEXT NOT NULL,
  default_limit NUMERIC NOT NULL,
  default_deductible NUMERIC NOT NULL,
  exclusion_codes TEXT,
  PRIMARY KEY (coverage_id)
);
CREATE TABLE adjuster (
  adjuster_id TEXT NOT NULL,
  full_name TEXT NOT NULL,
  region TEXT NOT NULL,
  specialty TEXT NOT NULL,
  max_open_claims INTEGER NOT NULL,
  PRIMARY KEY (adjuster_id)
);
CREATE TABLE document_requirement (
  requirement_id TEXT NOT NULL,
  claim_type TEXT NOT NULL,
  doc_type TEXT NOT NULL,
  mandatory TEXT NOT NULL,
  PRIMARY KEY (requirement_id)
);
CREATE TABLE policy (
  policy_id TEXT NOT NULL,
  customer_id TEXT NOT NULL,
  product TEXT NOT NULL,
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  premium NUMERIC NOT NULL,
  PRIMARY KEY (policy_id),
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);
CREATE TABLE policy_event (
  event_id TEXT NOT NULL,
  policy_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  event_date TEXT NOT NULL,
  PRIMARY KEY (event_id),
  FOREIGN KEY (policy_id) REFERENCES policy(policy_id)
);
CREATE TABLE policy_coverage (
  policy_coverage_id TEXT NOT NULL,
  policy_id TEXT NOT NULL,
  coverage_id TEXT NOT NULL,
  limit_amount NUMERIC NOT NULL,
  deductible NUMERIC NOT NULL,
  effective_start TEXT NOT NULL,
  effective_end TEXT NOT NULL,
  PRIMARY KEY (policy_coverage_id),
  FOREIGN KEY (policy_id) REFERENCES policy(policy_id),
  FOREIGN KEY (coverage_id) REFERENCES coverage(coverage_id)
);
CREATE TABLE incident (
  incident_id TEXT NOT NULL,
  policy_id TEXT NOT NULL,
  incident_date TEXT NOT NULL,
  incident_type TEXT NOT NULL,
  PRIMARY KEY (incident_id),
  FOREIGN KEY (policy_id) REFERENCES policy(policy_id)
);
CREATE TABLE claim (
  claim_id TEXT NOT NULL,
  policy_id TEXT NOT NULL,
  incident_id TEXT NOT NULL,
  claim_type TEXT NOT NULL,
  submission_date TEXT NOT NULL,
  claimed_amount NUMERIC NOT NULL,
  PRIMARY KEY (claim_id),
  FOREIGN KEY (policy_id) REFERENCES policy(policy_id),
  FOREIGN KEY (incident_id) REFERENCES incident(incident_id)
);
CREATE TABLE claim_item (
  item_id TEXT NOT NULL,
  claim_id TEXT NOT NULL,
  coverage_id TEXT NOT NULL,
  item_type TEXT NOT NULL,
  claimed_amount NUMERIC NOT NULL,
  PRIMARY KEY (item_id),
  FOREIGN KEY (claim_id) REFERENCES claim(claim_id),
  FOREIGN KEY (coverage_id) REFERENCES coverage(coverage_id)
);
CREATE TABLE document (
  document_id TEXT NOT NULL,
  claim_id TEXT NOT NULL,
  doc_type TEXT NOT NULL,
  received_date TEXT NOT NULL,
  status TEXT NOT NULL,
  PRIMARY KEY (document_id),
  FOREIGN KEY (claim_id) REFERENCES claim(claim_id)
);
CREATE TABLE claim_adjuster_assignment (
  assignment_id TEXT NOT NULL,
  claim_id TEXT NOT NULL,
  adjuster_id TEXT NOT NULL,
  assigned_date TEXT NOT NULL,
  reason TEXT NOT NULL,
  PRIMARY KEY (assignment_id),
  FOREIGN KEY (claim_id) REFERENCES claim(claim_id),
  FOREIGN KEY (adjuster_id) REFERENCES adjuster(adjuster_id)
);
CREATE TABLE assessment (
  assessment_id TEXT NOT NULL,
  claim_id TEXT NOT NULL,
  adjuster_id TEXT NOT NULL,
  assessment_date TEXT NOT NULL,
  decision TEXT NOT NULL,
  rule_id TEXT NOT NULL,
  reason_code TEXT NOT NULL,
  eligible_amount NUMERIC NOT NULL,
  deductible_applied NUMERIC NOT NULL,
  payable_amount NUMERIC NOT NULL,
  fraud_score REAL NOT NULL,
  PRIMARY KEY (assessment_id),
  FOREIGN KEY (claim_id) REFERENCES claim(claim_id),
  FOREIGN KEY (adjuster_id) REFERENCES adjuster(adjuster_id)
);
CREATE TABLE reserve (
  reserve_id TEXT NOT NULL,
  claim_id TEXT NOT NULL,
  reserve_date TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  basis TEXT NOT NULL,
  rule_id TEXT NOT NULL,
  PRIMARY KEY (reserve_id),
  FOREIGN KEY (claim_id) REFERENCES claim(claim_id)
);
CREATE TABLE settlement (
  settlement_id TEXT NOT NULL,
  claim_id TEXT NOT NULL,
  recommended_amount NUMERIC NOT NULL,
  recommended_date TEXT NOT NULL,
  approved_amount NUMERIC,
  approved_date TEXT,
  approver_role TEXT,
  paid_amount NUMERIC,
  paid_date TEXT,
  PRIMARY KEY (settlement_id),
  FOREIGN KEY (claim_id) REFERENCES claim(claim_id)
);
CREATE TABLE claim_status_history (
  event_id TEXT NOT NULL,
  claim_id TEXT NOT NULL,
  from_status TEXT,
  to_status TEXT NOT NULL,
  event_date TEXT NOT NULL,
  actor_role TEXT NOT NULL,
  rule_id TEXT,
  reason_code TEXT NOT NULL,
  PRIMARY KEY (event_id),
  FOREIGN KEY (claim_id) REFERENCES claim(claim_id)
);
CREATE TABLE ground_truth (
  entity_id TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  label TEXT NOT NULL,
  origin TEXT NOT NULL,
  kind TEXT NOT NULL,
  expected_decision TEXT NOT NULL,
  rule_id TEXT
);
