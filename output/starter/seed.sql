-- Seed data (SQLite). Tables are in parent-first order; load with PRAGMA foreign_keys=ON.
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
BEGIN;
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000001', 'Elena Frank', '1947-03-23', 'North', '2020-10-18');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000002', 'Yara Frank', '1961-10-24', 'Central', '2021-12-19');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000003', 'Quinn Baker', '1982-03-23', 'Northwest', '2023-08-31');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000004', 'Xavier Patel', '1991-08-15', 'South', '2019-05-02');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000005', 'Rosa Ivanov', '1957-08-16', 'East', '2021-01-03');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000006', 'Elena Kim', '1943-02-24', 'Northeast', '2021-01-13');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000007', 'Zane Costa', '2007-02-03', 'North', '2023-09-15');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000008', 'Asha Reyes', '1956-05-25', 'Southeast', '2021-05-22');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000009', 'Wen Khan', '1959-08-14', 'North', '2021-07-30');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000010', 'Uma Baker', '1959-12-06', 'North', '2021-04-15');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000011', 'Dmitri Frank', '1956-12-19', 'East', '2021-08-03');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000012', 'Omar Larsen', '1990-05-12', 'Southeast', '2023-12-21');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000013', 'Omar Kim', '1949-09-02', 'Northwest', '2019-02-19');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000014', 'Mei Reyes', '1995-10-04', 'East', '2019-06-15');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000015', 'Mei Tanaka', '2002-12-30', 'East', '2022-03-19');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000016', 'Grace Ivanov', '1974-02-01', 'Northwest', '2021-06-03');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000017', 'Grace Patel', '1964-07-17', 'South', '2019-06-09');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000018', 'Sam Nguyen', '2004-03-17', 'North', '2021-08-28');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000019', 'Sam Kim', '1996-08-05', 'Northeast', '2019-03-13');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000020', 'Omar Evans', '1946-07-14', 'Northwest', '2022-11-28');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000021', 'Xavier Frank', '1975-07-19', 'Northeast', '2021-09-12');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000022', 'Noor Baker', '1946-08-12', 'East', '2020-12-07');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000023', 'Amara Costa', '1992-08-19', 'North', '2019-05-10');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000024', 'Xavier Haddad', '1980-10-08', 'East', '2020-01-02');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000025', 'Hiro Nguyen', '1994-12-25', 'West', '2021-04-27');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000026', 'Quinn Tanaka', '1991-03-27', 'West', '2019-07-08');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000027', 'Carla Kim', '1985-04-29', 'Southeast', '2019-12-19');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000028', 'Ben Kim', '1999-08-19', 'South', '2020-07-25');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000029', 'Kavya Haddad', '1958-04-06', 'Central', '2021-01-12');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000030', 'Asha Costa', '1952-02-27', 'Northeast', '2023-04-29');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000031', 'Ben Singh', '2001-01-15', 'Central', '2021-08-31');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000032', 'Omar Patel', '1979-03-22', 'Northeast', '2022-10-21');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000033', 'Bruno Rossi', '1955-09-05', 'North', '2023-10-09');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000034', 'Mei Evans', '1984-10-26', 'Southeast', '2020-06-15');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000035', 'Rosa Garcia', '1980-03-05', 'Southeast', '2020-07-23');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000036', 'Bruno Khan', '1975-07-12', 'Central', '2022-08-23');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000037', 'Wen Patel', '1983-05-29', 'Northwest', '2020-10-16');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000038', 'Farid Novak', '1944-07-06', 'East', '2019-07-12');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000039', 'Farid Kim', '1945-09-30', 'Northeast', '2019-11-27');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000040', 'Rosa Nguyen', '1978-06-05', 'South', '2021-06-11');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000041', 'Grace Reyes', '1964-01-06', 'Northeast', '2023-08-18');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000042', 'Asha Rossi', '1967-11-17', 'Northwest', '2023-07-05');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000043', 'Carla Ivanov', '1963-05-16', 'South', '2023-04-19');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000044', 'Priya Reyes', '1946-01-10', 'Northeast', '2022-01-15');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000045', 'Farid Patel', '1965-03-18', 'North', '2021-02-11');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000046', 'Grace Evans', '1996-04-11', 'East', '2021-09-15');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000047', 'Ines Novak', '2005-10-21', 'North', '2023-06-30');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000048', 'Mei Patel', '1944-05-14', 'South', '2023-09-10');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000049', 'Priya Evans', '2001-04-21', 'North', '2021-01-02');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000050', 'Asha Haddad', '1985-06-03', 'Northeast', '2021-10-25');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000051', 'Mei Ivanov', '1944-12-05', 'West', '2023-07-01');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000052', 'Uma Silva', '1956-12-17', 'Northeast', '2022-07-15');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000053', 'Grace Larsen', '1953-08-10', 'West', '2019-09-28');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000054', 'Rosa Garcia', '1944-06-20', 'South', '2019-04-15');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000055', 'Ines Nguyen', '1967-07-26', 'Northwest', '2019-05-10');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000056', 'Farid Haddad', '1976-02-28', 'West', '2023-02-20');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000057', 'Omar Larsen', '1969-09-20', 'Central', '2023-07-24');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000058', 'Yara Rossi', '1944-06-20', 'East', '2020-05-29');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000059', 'Dmitri Silva', '2006-04-13', 'Northwest', '2022-05-29');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000060', 'Dev Costa', '1994-04-04', 'South', '2021-11-02');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000061', 'Omar Silva', '1971-03-28', 'East', '2021-02-28');
INSERT INTO customer (customer_id, full_name, dob, region, created_date) VALUES ('CUS-000062', 'Uma Baker', '1971-07-01', 'North', '2021-08-24');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes) VALUES ('COV-AUTO-001', 'AUTO', 'Collision', 25000.00, 500.00, 'cosmetic');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes) VALUES ('COV-AUTO-002', 'AUTO', 'Theft', 30000.00, 500.00, '');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes) VALUES ('COV-AUTO-003', 'AUTO', 'Third-party liability', 50000.00, 0.00, '');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes) VALUES ('COV-AUTO-004', 'AUTO', 'Towing and rental', 3000.00, 100.00, '');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes) VALUES ('COV-HOME-001', 'HOME', 'Fire', 200000.00, 1000.00, 'cosmetic');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes) VALUES ('COV-HOME-002', 'HOME', 'Water damage', 50000.00, 1000.00, '');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes) VALUES ('COV-HOME-003', 'HOME', 'Burglary', 30000.00, 500.00, '');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes) VALUES ('COV-HOME-004', 'HOME', 'Contents', 40000.00, 500.00, 'cosmetic');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes) VALUES ('COV-HLTH-001', 'HLTH', 'Outpatient', 10000.00, 250.00, 'cosmetic');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes) VALUES ('COV-HLTH-002', 'HLTH', 'Hospital stay', 100000.00, 1000.00, 'cosmetic');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes) VALUES ('COV-HLTH-003', 'HLTH', 'Emergency care', 50000.00, 500.00, '');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes) VALUES ('COV-TRVL-001', 'TRVL', 'Trip cancellation', 8000.00, 100.00, '');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes) VALUES ('COV-TRVL-002', 'TRVL', 'Baggage loss', 3000.00, 50.00, '');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes) VALUES ('COV-TRVL-003', 'TRVL', 'Medical abroad', 50000.00, 250.00, '');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes) VALUES ('COV-LIAB-001', 'LIAB', 'Third-party injury', 100000.00, 1000.00, '');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes) VALUES ('COV-LIAB-002', 'LIAB', 'Third-party property', 75000.00, 1000.00, '');
INSERT INTO adjuster (adjuster_id, full_name, region, specialty, max_open_claims) VALUES ('ADJ-001', 'Carla Patel', 'Northwest', 'AUTO', 40);
INSERT INTO adjuster (adjuster_id, full_name, region, specialty, max_open_claims) VALUES ('ADJ-002', 'Jamal Okafor', 'Northeast', 'HOME', 23);
INSERT INTO adjuster (adjuster_id, full_name, region, specialty, max_open_claims) VALUES ('ADJ-003', 'Rosa Nguyen', 'Northwest', 'HLTH', 35);
INSERT INTO adjuster (adjuster_id, full_name, region, specialty, max_open_claims) VALUES ('ADJ-004', 'Zane Larsen', 'East', 'TRVL', 28);
INSERT INTO adjuster (adjuster_id, full_name, region, specialty, max_open_claims) VALUES ('ADJ-005', 'Quinn Okafor', 'South', 'LIAB', 39);
INSERT INTO adjuster (adjuster_id, full_name, region, specialty, max_open_claims) VALUES ('ADJ-006', 'Carla Haddad', 'Central', 'AUTO', 39);
INSERT INTO adjuster (adjuster_id, full_name, region, specialty, max_open_claims) VALUES ('ADJ-007', 'Dmitri Larsen', 'South', 'HOME', 34);
INSERT INTO adjuster (adjuster_id, full_name, region, specialty, max_open_claims) VALUES ('ADJ-008', 'Elena Ivanov', 'Northwest', 'HLTH', 27);
INSERT INTO adjuster (adjuster_id, full_name, region, specialty, max_open_claims) VALUES ('ADJ-009', 'Ines Tanaka', 'Southeast', 'TRVL', 21);
INSERT INTO adjuster (adjuster_id, full_name, region, specialty, max_open_claims) VALUES ('ADJ-010', 'Carla Kim', 'Central', 'LIAB', 20);
INSERT INTO document_requirement (requirement_id, claim_type, doc_type, mandatory) VALUES ('DRQ-AUTO-PHOTO', 'AUTO', 'photo', 'Y');
INSERT INTO document_requirement (requirement_id, claim_type, doc_type, mandatory) VALUES ('DRQ-AUTO-POLICE_REPORT', 'AUTO', 'police_report', 'Y');
INSERT INTO document_requirement (requirement_id, claim_type, doc_type, mandatory) VALUES ('DRQ-AUTO-REPAIR_ESTIMATE', 'AUTO', 'repair_estimate', 'N');
INSERT INTO document_requirement (requirement_id, claim_type, doc_type, mandatory) VALUES ('DRQ-HOME-PHOTO', 'HOME', 'photo', 'Y');
INSERT INTO document_requirement (requirement_id, claim_type, doc_type, mandatory) VALUES ('DRQ-HOME-REPAIR_ESTIMATE', 'HOME', 'repair_estimate', 'Y');
INSERT INTO document_requirement (requirement_id, claim_type, doc_type, mandatory) VALUES ('DRQ-HOME-PROOF_OF_OWNERSHIP', 'HOME', 'proof_of_ownership', 'N');
INSERT INTO document_requirement (requirement_id, claim_type, doc_type, mandatory) VALUES ('DRQ-HLTH-MEDICAL_REPORT', 'HLTH', 'medical_report', 'Y');
INSERT INTO document_requirement (requirement_id, claim_type, doc_type, mandatory) VALUES ('DRQ-HLTH-INVOICE', 'HLTH', 'invoice', 'Y');
INSERT INTO document_requirement (requirement_id, claim_type, doc_type, mandatory) VALUES ('DRQ-TRVL-ITINERARY', 'TRVL', 'itinerary', 'Y');
INSERT INTO document_requirement (requirement_id, claim_type, doc_type, mandatory) VALUES ('DRQ-TRVL-INVOICE', 'TRVL', 'invoice', 'Y');
INSERT INTO document_requirement (requirement_id, claim_type, doc_type, mandatory) VALUES ('DRQ-TRVL-INCIDENT_STATEMENT', 'TRVL', 'incident_statement', 'N');
INSERT INTO document_requirement (requirement_id, claim_type, doc_type, mandatory) VALUES ('DRQ-LIAB-INCIDENT_STATEMENT', 'LIAB', 'incident_statement', 'Y');
INSERT INTO document_requirement (requirement_id, claim_type, doc_type, mandatory) VALUES ('DRQ-LIAB-POLICE_REPORT', 'LIAB', 'police_report', 'Y');
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000001', 'CUS-000038', 'HLTH', '2024-01-15', '2025-01-13', 2281.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000002', 'CUS-000059', 'HOME', '2024-02-02', '2025-01-31', 792.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000003', 'CUS-000027', 'HOME', '2024-04-08', '2025-04-07', 1474.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-LIAB-2026-000004', 'CUS-000017', 'LIAB', '2024-05-23', '2025-05-22', 377.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000005', 'CUS-000043', 'AUTO', '2024-08-24', '2025-08-23', 2323.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-TRVL-2026-000006', 'CUS-000027', 'TRVL', '2024-09-22', '2024-11-13', 115.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000007', 'CUS-000016', 'AUTO', '2024-10-17', '2025-10-16', 1827.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000008', 'CUS-000061', 'AUTO', '2025-02-18', '2026-02-17', 2302.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000009', 'CUS-000021', 'AUTO', '2025-03-09', '2026-03-08', 916.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000010', 'CUS-000056', 'AUTO', '2025-04-01', '2026-03-31', 1830.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000011', 'CUS-000014', 'HOME', '2025-04-15', '2026-04-14', 1937.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-LIAB-2026-000012', 'CUS-000057', 'LIAB', '2025-04-21', '2026-04-20', 862.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000013', 'CUS-000015', 'AUTO', '2025-06-01', '2026-05-31', 1907.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-TRVL-2026-000014', 'CUS-000048', 'TRVL', '2025-07-02', '2025-08-02', 237.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-TRVL-2026-000015', 'CUS-000009', 'TRVL', '2025-07-21', '2025-10-16', 193.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000016', 'CUS-000007', 'HOME', '2025-08-21', '2026-08-20', 1768.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000017', 'CUS-000046', 'AUTO', '2025-10-29', '2026-10-28', 1938.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-LIAB-2026-000018', 'CUS-000058', 'LIAB', '2025-11-03', '2026-11-02', 610.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000019', 'CUS-000041', 'HOME', '2025-11-05', '2026-11-04', 1780.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000020', 'CUS-000011', 'AUTO', '2025-11-13', '2026-11-12', 1124.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000021', 'CUS-000018', 'HLTH', '2025-11-17', '2026-11-16', 2750.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-LIAB-2026-000022', 'CUS-000039', 'LIAB', '2025-11-17', '2026-11-16', 568.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-LIAB-2026-000023', 'CUS-000058', 'LIAB', '2025-11-17', '2026-11-16', 953.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000024', 'CUS-000042', 'HLTH', '2025-12-02', '2026-12-01', 3880.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000025', 'CUS-000007', 'HOME', '2025-12-03', '2026-12-02', 749.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000026', 'CUS-000036', 'HLTH', '2025-12-05', '2026-12-04', 4448.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000027', 'CUS-000045', 'AUTO', '2025-12-16', '2026-12-15', 1354.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000028', 'CUS-000032', 'HLTH', '2025-12-18', '2026-12-17', 4838.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000029', 'CUS-000003', 'HLTH', '2025-12-19', '2026-12-18', 4763.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000030', 'CUS-000055', 'HOME', '2025-12-21', '2026-12-20', 1069.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000031', 'CUS-000060', 'HOME', '2025-12-26', '2026-12-25', 1661.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000032', 'CUS-000016', 'HOME', '2026-01-03', '2027-01-02', 1113.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000033', 'CUS-000005', 'AUTO', '2026-01-10', '2027-01-09', 1551.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000034', 'CUS-000011', 'AUTO', '2026-01-24', '2027-01-23', 1796.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000035', 'CUS-000010', 'AUTO', '2026-02-01', '2027-01-31', 1056.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000036', 'CUS-000017', 'HOME', '2026-02-14', '2027-02-13', 1839.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000037', 'CUS-000010', 'HOME', '2026-02-27', '2027-02-26', 1163.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000038', 'CUS-000049', 'HOME', '2026-03-11', '2027-03-10', 988.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000039', 'CUS-000020', 'HLTH', '2026-03-18', '2027-03-17', 2307.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-LIAB-2026-000040', 'CUS-000040', 'LIAB', '2026-03-18', '2027-03-17', 857.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-LIAB-2026-000041', 'CUS-000033', 'LIAB', '2026-03-19', '2027-03-18', 813.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-TRVL-2026-000042', 'CUS-000025', 'TRVL', '2026-03-20', '2026-05-14', 93.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000043', 'CUS-000007', 'HLTH', '2026-03-27', '2027-03-26', 3458.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-LIAB-2026-000044', 'CUS-000037', 'LIAB', '2026-04-01', '2027-03-31', 1125.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000045', 'CUS-000039', 'HOME', '2026-04-06', '2027-04-05', 943.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000046', 'CUS-000012', 'AUTO', '2026-04-07', '2027-04-06', 1171.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000047', 'CUS-000030', 'HLTH', '2026-04-09', '2027-04-08', 1563.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000048', 'CUS-000031', 'HOME', '2026-04-14', '2027-04-13', 708.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-LIAB-2026-000049', 'CUS-000022', 'LIAB', '2026-04-27', '2027-04-26', 847.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-LIAB-2026-000050', 'CUS-000053', 'LIAB', '2026-05-10', '2027-05-09', 747.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000051', 'CUS-000022', 'AUTO', '2026-05-11', '2027-05-10', 1239.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000052', 'CUS-000047', 'HLTH', '2026-05-11', '2027-05-10', 2069.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000053', 'CUS-000042', 'HLTH', '2026-05-14', '2027-05-13', 4417.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000054', 'CUS-000044', 'HOME', '2026-05-21', '2027-05-20', 1330.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000055', 'CUS-000049', 'AUTO', '2026-05-30', '2027-05-29', 930.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000056', 'CUS-000050', 'AUTO', '2026-05-30', '2027-05-29', 929.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000057', 'CUS-000044', 'AUTO', '2026-05-31', '2027-05-30', 1344.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000058', 'CUS-000062', 'HOME', '2026-06-03', '2027-06-02', 1642.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000059', 'CUS-000041', 'AUTO', '2026-06-05', '2027-06-04', 1326.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000060', 'CUS-000050', 'AUTO', '2026-06-09', '2027-06-08', 1769.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000061', 'CUS-000034', 'HOME', '2026-06-09', '2027-06-08', 1392.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000062', 'CUS-000052', 'HOME', '2026-06-23', '2027-06-22', 1465.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000063', 'CUS-000054', 'HOME', '2026-06-23', '2027-06-22', 1165.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000064', 'CUS-000017', 'HOME', '2026-07-08', '2027-07-07', 1596.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000065', 'CUS-000021', 'AUTO', '2026-07-15', '2027-07-14', 2331.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000066', 'CUS-000035', 'AUTO', '2026-07-26', '2027-07-25', 1745.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000067', 'CUS-000025', 'AUTO', '2026-07-30', '2027-07-29', 1347.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-LIAB-2026-000068', 'CUS-000010', 'LIAB', '2026-07-30', '2027-07-29', 925.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000069', 'CUS-000008', 'AUTO', '2026-08-04', '2027-08-03', 1382.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000070', 'CUS-000055', 'HLTH', '2026-08-05', '2027-08-04', 4127.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-LIAB-2026-000071', 'CUS-000019', 'LIAB', '2026-08-11', '2027-08-10', 828.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000072', 'CUS-000037', 'HLTH', '2026-08-13', '2027-08-12', 3645.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000073', 'CUS-000024', 'AUTO', '2026-08-14', '2027-08-13', 1541.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-TRVL-2026-000074', 'CUS-000008', 'TRVL', '2026-08-14', '2026-09-16', 58.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000075', 'CUS-000046', 'HOME', '2026-08-19', '2027-08-18', 1634.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-TRVL-2026-000076', 'CUS-000051', 'TRVL', '2026-08-21', '2026-11-11', 234.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000077', 'CUS-000060', 'AUTO', '2026-08-22', '2027-08-21', 1698.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000078', 'CUS-000004', 'HOME', '2026-08-24', '2027-08-23', 1417.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000079', 'CUS-000032', 'AUTO', '2026-08-25', '2027-08-24', 1431.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000080', 'CUS-000059', 'AUTO', '2026-08-27', '2027-08-26', 2065.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000081', 'CUS-000058', 'HOME', '2026-08-29', '2027-08-28', 930.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000082', 'CUS-000029', 'AUTO', '2026-08-30', '2027-08-29', 1939.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000083', 'CUS-000001', 'HOME', '2026-08-31', '2027-08-30', 1173.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000084', 'CUS-000056', 'AUTO', '2026-09-05', '2027-09-04', 2300.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-LIAB-2026-000085', 'CUS-000015', 'LIAB', '2026-09-06', '2027-09-05', 458.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000086', 'CUS-000018', 'HLTH', '2026-09-12', '2027-09-11', 2975.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000087', 'CUS-000044', 'HLTH', '2026-09-12', '2027-09-11', 4791.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-LIAB-2026-000088', 'CUS-000002', 'LIAB', '2026-09-12', '2027-09-11', 356.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-LIAB-2026-000089', 'CUS-000034', 'LIAB', '2026-09-14', '2027-09-13', 697.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000090', 'CUS-000020', 'HOME', '2026-09-16', '2027-09-15', 1494.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000091', 'CUS-000014', 'AUTO', '2026-09-18', '2027-09-17', 2121.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-TRVL-2026-000092', 'CUS-000026', 'TRVL', '2026-09-21', '2026-10-22', 213.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000093', 'CUS-000042', 'HLTH', '2026-09-27', '2027-09-26', 1511.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000094', 'CUS-000006', 'HLTH', '2026-10-04', '2027-10-03', 4644.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000095', 'CUS-000040', 'AUTO', '2026-10-09', '2027-10-08', 1313.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HOME-2026-000096', 'CUS-000013', 'HOME', '2026-10-10', '2027-10-09', 1509.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-TRVL-2026-000097', 'CUS-000028', 'TRVL', '2026-10-10', '2026-12-27', 72.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-TRVL-2026-000098', 'CUS-000049', 'TRVL', '2026-10-14', '2026-12-21', 210.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-AUTO-2026-000099', 'CUS-000012', 'AUTO', '2026-10-18', '2027-10-17', 1184.00);
INSERT INTO policy (policy_id, customer_id, product, start_date, end_date, premium) VALUES ('POL-HLTH-2026-000100', 'CUS-000023', 'HLTH', '2026-10-19', '2027-10-18', 3126.00);
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000001-001', 'POL-HLTH-2026-000001', 'issued', '2024-01-15');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000001-002', 'POL-HLTH-2026-000001', 'expired', '2025-01-13');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000002-001', 'POL-HOME-2026-000002', 'issued', '2024-02-02');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000002-002', 'POL-HOME-2026-000002', 'expired', '2025-01-31');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000003-001', 'POL-HOME-2026-000003', 'issued', '2024-04-08');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000003-002', 'POL-HOME-2026-000003', 'lapsed', '2024-09-13');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-LIAB-2026-000004-001', 'POL-LIAB-2026-000004', 'issued', '2024-05-23');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-LIAB-2026-000004-002', 'POL-LIAB-2026-000004', 'expired', '2025-05-22');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000005-001', 'POL-AUTO-2026-000005', 'issued', '2024-08-24');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000005-002', 'POL-AUTO-2026-000005', 'lapsed', '2025-03-12');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-TRVL-2026-000006-001', 'POL-TRVL-2026-000006', 'issued', '2024-09-22');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-TRVL-2026-000006-002', 'POL-TRVL-2026-000006', 'expired', '2024-11-13');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000007-001', 'POL-AUTO-2026-000007', 'issued', '2024-10-17');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000007-002', 'POL-AUTO-2026-000007', 'lapsed', '2025-09-10');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000008-001', 'POL-AUTO-2026-000008', 'issued', '2025-02-18');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000008-002', 'POL-AUTO-2026-000008', 'lapsed', '2025-11-21');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000009-001', 'POL-AUTO-2026-000009', 'issued', '2025-03-09');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000009-002', 'POL-AUTO-2026-000009', 'expired', '2026-03-08');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000010-001', 'POL-AUTO-2026-000010', 'issued', '2025-04-01');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000010-002', 'POL-AUTO-2026-000010', 'lapsed', '2025-12-03');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000011-001', 'POL-HOME-2026-000011', 'issued', '2025-04-15');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000011-002', 'POL-HOME-2026-000011', 'expired', '2026-04-14');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-LIAB-2026-000012-001', 'POL-LIAB-2026-000012', 'issued', '2025-04-21');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-LIAB-2026-000012-002', 'POL-LIAB-2026-000012', 'lapsed', '2025-09-18');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000013-001', 'POL-AUTO-2026-000013', 'issued', '2025-06-01');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000013-002', 'POL-AUTO-2026-000013', 'expired', '2026-05-31');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-TRVL-2026-000014-001', 'POL-TRVL-2026-000014', 'issued', '2025-07-02');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-TRVL-2026-000014-002', 'POL-TRVL-2026-000014', 'expired', '2025-08-02');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-TRVL-2026-000015-001', 'POL-TRVL-2026-000015', 'issued', '2025-07-21');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-TRVL-2026-000015-002', 'POL-TRVL-2026-000015', 'expired', '2025-10-16');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000016-001', 'POL-HOME-2026-000016', 'issued', '2025-08-21');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000016-002', 'POL-HOME-2026-000016', 'expired', '2026-08-20');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000017-001', 'POL-AUTO-2026-000017', 'issued', '2025-10-29');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-LIAB-2026-000018-001', 'POL-LIAB-2026-000018', 'issued', '2025-11-03');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000019-001', 'POL-HOME-2026-000019', 'issued', '2025-11-05');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000020-001', 'POL-AUTO-2026-000020', 'issued', '2025-11-13');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000021-001', 'POL-HLTH-2026-000021', 'issued', '2025-11-17');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-LIAB-2026-000022-001', 'POL-LIAB-2026-000022', 'issued', '2025-11-17');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-LIAB-2026-000023-001', 'POL-LIAB-2026-000023', 'issued', '2025-11-17');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000024-001', 'POL-HLTH-2026-000024', 'issued', '2025-12-02');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000025-001', 'POL-HOME-2026-000025', 'issued', '2025-12-03');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000026-001', 'POL-HLTH-2026-000026', 'issued', '2025-12-05');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000027-001', 'POL-AUTO-2026-000027', 'issued', '2025-12-16');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000028-001', 'POL-HLTH-2026-000028', 'issued', '2025-12-18');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000029-001', 'POL-HLTH-2026-000029', 'issued', '2025-12-19');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000030-001', 'POL-HOME-2026-000030', 'issued', '2025-12-21');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000031-001', 'POL-HOME-2026-000031', 'issued', '2025-12-26');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000032-001', 'POL-HOME-2026-000032', 'issued', '2026-01-03');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000033-001', 'POL-AUTO-2026-000033', 'issued', '2026-01-10');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000034-001', 'POL-AUTO-2026-000034', 'issued', '2026-01-24');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000035-001', 'POL-AUTO-2026-000035', 'issued', '2026-02-01');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000036-001', 'POL-HOME-2026-000036', 'issued', '2026-02-14');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000037-001', 'POL-HOME-2026-000037', 'issued', '2026-02-27');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000038-001', 'POL-HOME-2026-000038', 'issued', '2026-03-11');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000039-001', 'POL-HLTH-2026-000039', 'issued', '2026-03-18');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-LIAB-2026-000040-001', 'POL-LIAB-2026-000040', 'issued', '2026-03-18');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-LIAB-2026-000041-001', 'POL-LIAB-2026-000041', 'issued', '2026-03-19');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-TRVL-2026-000042-001', 'POL-TRVL-2026-000042', 'issued', '2026-03-20');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-TRVL-2026-000042-002', 'POL-TRVL-2026-000042', 'expired', '2026-05-14');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000043-001', 'POL-HLTH-2026-000043', 'issued', '2026-03-27');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-LIAB-2026-000044-001', 'POL-LIAB-2026-000044', 'issued', '2026-04-01');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000045-001', 'POL-HOME-2026-000045', 'issued', '2026-04-06');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000046-001', 'POL-AUTO-2026-000046', 'issued', '2026-04-07');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000047-001', 'POL-HLTH-2026-000047', 'issued', '2026-04-09');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000048-001', 'POL-HOME-2026-000048', 'issued', '2026-04-14');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-LIAB-2026-000049-001', 'POL-LIAB-2026-000049', 'issued', '2026-04-27');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-LIAB-2026-000050-001', 'POL-LIAB-2026-000050', 'issued', '2026-05-10');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000051-001', 'POL-AUTO-2026-000051', 'issued', '2026-05-11');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000051-002', 'POL-AUTO-2026-000051', 'cancelled', '2026-09-18');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000052-001', 'POL-HLTH-2026-000052', 'issued', '2026-05-11');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000053-001', 'POL-HLTH-2026-000053', 'issued', '2026-05-14');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000054-001', 'POL-HOME-2026-000054', 'issued', '2026-05-21');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000055-001', 'POL-AUTO-2026-000055', 'issued', '2026-05-30');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000056-001', 'POL-AUTO-2026-000056', 'issued', '2026-05-30');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000057-001', 'POL-AUTO-2026-000057', 'issued', '2026-05-31');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000058-001', 'POL-HOME-2026-000058', 'issued', '2026-06-03');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000059-001', 'POL-AUTO-2026-000059', 'issued', '2026-06-05');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000060-001', 'POL-AUTO-2026-000060', 'issued', '2026-06-09');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000061-001', 'POL-HOME-2026-000061', 'issued', '2026-06-09');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000062-001', 'POL-HOME-2026-000062', 'issued', '2026-06-23');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000063-001', 'POL-HOME-2026-000063', 'issued', '2026-06-23');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000063-002', 'POL-HOME-2026-000063', 'cancelled', '2026-06-29');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000064-001', 'POL-HOME-2026-000064', 'issued', '2026-07-08');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000065-001', 'POL-AUTO-2026-000065', 'issued', '2026-07-15');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000066-001', 'POL-AUTO-2026-000066', 'issued', '2026-07-26');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000067-001', 'POL-AUTO-2026-000067', 'issued', '2026-07-30');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-LIAB-2026-000068-001', 'POL-LIAB-2026-000068', 'issued', '2026-07-30');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000069-001', 'POL-AUTO-2026-000069', 'issued', '2026-08-04');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000069-002', 'POL-AUTO-2026-000069', 'lapsed', '2026-10-17');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000070-001', 'POL-HLTH-2026-000070', 'issued', '2026-08-05');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-LIAB-2026-000071-001', 'POL-LIAB-2026-000071', 'issued', '2026-08-11');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000072-001', 'POL-HLTH-2026-000072', 'issued', '2026-08-13');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000073-001', 'POL-AUTO-2026-000073', 'issued', '2026-08-14');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-TRVL-2026-000074-001', 'POL-TRVL-2026-000074', 'issued', '2026-08-14');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-TRVL-2026-000074-002', 'POL-TRVL-2026-000074', 'lapsed', '2026-09-05');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000075-001', 'POL-HOME-2026-000075', 'issued', '2026-08-19');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-TRVL-2026-000076-001', 'POL-TRVL-2026-000076', 'issued', '2026-08-21');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000077-001', 'POL-AUTO-2026-000077', 'issued', '2026-08-22');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000078-001', 'POL-HOME-2026-000078', 'issued', '2026-08-24');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000079-001', 'POL-AUTO-2026-000079', 'issued', '2026-08-25');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000080-001', 'POL-AUTO-2026-000080', 'issued', '2026-08-27');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000081-001', 'POL-HOME-2026-000081', 'issued', '2026-08-29');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000082-001', 'POL-AUTO-2026-000082', 'issued', '2026-08-30');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000083-001', 'POL-HOME-2026-000083', 'issued', '2026-08-31');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000084-001', 'POL-AUTO-2026-000084', 'issued', '2026-09-05');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-LIAB-2026-000085-001', 'POL-LIAB-2026-000085', 'issued', '2026-09-06');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000086-001', 'POL-HLTH-2026-000086', 'issued', '2026-09-12');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000087-001', 'POL-HLTH-2026-000087', 'issued', '2026-09-12');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-LIAB-2026-000088-001', 'POL-LIAB-2026-000088', 'issued', '2026-09-12');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-LIAB-2026-000089-001', 'POL-LIAB-2026-000089', 'issued', '2026-09-14');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000090-001', 'POL-HOME-2026-000090', 'issued', '2026-09-16');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000091-001', 'POL-AUTO-2026-000091', 'issued', '2026-09-18');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-TRVL-2026-000092-001', 'POL-TRVL-2026-000092', 'issued', '2026-09-21');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000093-001', 'POL-HLTH-2026-000093', 'issued', '2026-09-27');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000094-001', 'POL-HLTH-2026-000094', 'issued', '2026-10-04');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000095-001', 'POL-AUTO-2026-000095', 'issued', '2026-10-09');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000096-001', 'POL-HOME-2026-000096', 'issued', '2026-10-10');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-TRVL-2026-000097-001', 'POL-TRVL-2026-000097', 'issued', '2026-10-10');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-TRVL-2026-000098-001', 'POL-TRVL-2026-000098', 'issued', '2026-10-14');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000099-001', 'POL-AUTO-2026-000099', 'issued', '2026-10-18');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HLTH-2026-000100-001', 'POL-HLTH-2026-000100', 'issued', '2026-10-19');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000001-001', 'POL-HLTH-2026-000001', 'COV-HLTH-001', 15000.00, 500.00, '2024-01-15', '2025-01-13');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000001-002', 'POL-HLTH-2026-000001', 'COV-HLTH-003', 100000.00, 1000.00, '2024-01-15', '2025-01-13');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000002-001', 'POL-HOME-2026-000002', 'COV-HOME-001', 400000.00, 2000.00, '2024-02-02', '2025-01-31');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000002-002', 'POL-HOME-2026-000002', 'COV-HOME-002', 100000.00, 2000.00, '2024-02-02', '2025-01-31');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000002-003', 'POL-HOME-2026-000002', 'COV-HOME-003', 60000.00, 1000.00, '2024-02-02', '2025-01-31');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000003-001', 'POL-HOME-2026-000003', 'COV-HOME-002', 50000.00, 2000.00, '2024-04-08', '2025-04-07');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000003-002', 'POL-HOME-2026-000003', 'COV-HOME-003', 45000.00, 500.00, '2024-04-08', '2025-04-07');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000003-003', 'POL-HOME-2026-000003', 'COV-HOME-004', 40000.00, 500.00, '2024-04-08', '2025-04-07');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000004-001', 'POL-LIAB-2026-000004', 'COV-LIAB-001', 100000.00, 2000.00, '2024-05-23', '2025-05-22');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000004-002', 'POL-LIAB-2026-000004', 'COV-LIAB-002', 37500.00, 1000.00, '2024-05-23', '2025-05-22');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000005-001', 'POL-AUTO-2026-000005', 'COV-AUTO-001', 12500.00, 1000.00, '2024-08-24', '2025-08-23');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000005-002', 'POL-AUTO-2026-000005', 'COV-AUTO-002', 30000.00, 1000.00, '2024-08-24', '2025-08-23');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000006-001', 'POL-TRVL-2026-000006', 'COV-TRVL-001', 16000.00, 100.00, '2024-09-22', '2024-11-13');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000006-002', 'POL-TRVL-2026-000006', 'COV-TRVL-003', 75000.00, 500.00, '2024-09-22', '2024-11-13');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000007-001', 'POL-AUTO-2026-000007', 'COV-AUTO-001', 50000.00, 500.00, '2024-10-17', '2025-10-16');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000007-002', 'POL-AUTO-2026-000007', 'COV-AUTO-003', 50000.00, 0.00, '2024-10-17', '2025-10-16');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000008-001', 'POL-AUTO-2026-000008', 'COV-AUTO-002', 30000.00, 500.00, '2025-02-18', '2026-02-17');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000008-002', 'POL-AUTO-2026-000008', 'COV-AUTO-003', 50000.00, 0.00, '2025-02-18', '2026-02-17');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000009-001', 'POL-AUTO-2026-000009', 'COV-AUTO-001', 37500.00, 1000.00, '2025-03-09', '2026-03-08');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000009-002', 'POL-AUTO-2026-000009', 'COV-AUTO-002', 15000.00, 1000.00, '2025-03-09', '2026-03-08');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000009-003', 'POL-AUTO-2026-000009', 'COV-AUTO-004', 4500.00, 100.00, '2025-03-09', '2026-03-08');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000010-001', 'POL-AUTO-2026-000010', 'COV-AUTO-001', 25000.00, 500.00, '2025-04-01', '2026-03-31');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000010-002', 'POL-AUTO-2026-000010', 'COV-AUTO-003', 75000.00, 0.00, '2025-04-01', '2026-03-31');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000010-003', 'POL-AUTO-2026-000010', 'COV-AUTO-004', 3000.00, 200.00, '2025-04-01', '2026-03-31');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000011-001', 'POL-HOME-2026-000011', 'COV-HOME-002', 100000.00, 2000.00, '2025-04-15', '2026-04-14');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000011-002', 'POL-HOME-2026-000011', 'COV-HOME-003', 45000.00, 1000.00, '2025-04-15', '2026-04-14');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000012-001', 'POL-LIAB-2026-000012', 'COV-LIAB-001', 150000.00, 1000.00, '2025-04-21', '2026-04-20');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000012-002', 'POL-LIAB-2026-000012', 'COV-LIAB-002', 112500.00, 2000.00, '2025-04-21', '2026-04-20');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000013-001', 'POL-AUTO-2026-000013', 'COV-AUTO-001', 37500.00, 500.00, '2025-08-25', '2026-05-31');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000013-002', 'POL-AUTO-2026-000013', 'COV-AUTO-003', 50000.00, 0.00, '2025-06-01', '2026-05-31');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000013-003', 'POL-AUTO-2026-000013', 'COV-AUTO-004', 4500.00, 100.00, '2025-06-01', '2026-05-31');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000014-001', 'POL-TRVL-2026-000014', 'COV-TRVL-001', 12000.00, 200.00, '2025-07-02', '2025-08-02');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000014-002', 'POL-TRVL-2026-000014', 'COV-TRVL-002', 4500.00, 100.00, '2025-07-02', '2025-08-02');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000015-001', 'POL-TRVL-2026-000015', 'COV-TRVL-002', 1500.00, 100.00, '2025-07-21', '2025-10-16');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000015-002', 'POL-TRVL-2026-000015', 'COV-TRVL-003', 25000.00, 500.00, '2025-07-21', '2025-10-16');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000016-001', 'POL-HOME-2026-000016', 'COV-HOME-003', 15000.00, 500.00, '2025-08-21', '2026-08-20');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000016-002', 'POL-HOME-2026-000016', 'COV-HOME-004', 60000.00, 500.00, '2025-08-21', '2026-08-20');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000017-001', 'POL-AUTO-2026-000017', 'COV-AUTO-002', 30000.00, 1000.00, '2025-10-29', '2026-10-28');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000017-002', 'POL-AUTO-2026-000017', 'COV-AUTO-003', 25000.00, 0.00, '2025-10-29', '2026-10-28');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000017-003', 'POL-AUTO-2026-000017', 'COV-AUTO-004', 4500.00, 200.00, '2025-10-29', '2026-10-28');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000018-001', 'POL-LIAB-2026-000018', 'COV-LIAB-001', 100000.00, 1000.00, '2025-11-03', '2026-11-02');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000018-002', 'POL-LIAB-2026-000018', 'COV-LIAB-002', 75000.00, 1000.00, '2025-11-03', '2026-11-02');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000019-001', 'POL-HOME-2026-000019', 'COV-HOME-002', 100000.00, 1000.00, '2025-11-05', '2026-11-04');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000019-002', 'POL-HOME-2026-000019', 'COV-HOME-004', 80000.00, 1000.00, '2025-11-05', '2026-11-04');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000020-001', 'POL-AUTO-2026-000020', 'COV-AUTO-002', 60000.00, 500.00, '2025-11-13', '2026-11-12');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000020-002', 'POL-AUTO-2026-000020', 'COV-AUTO-004', 6000.00, 200.00, '2026-01-26', '2026-11-12');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000021-001', 'POL-HLTH-2026-000021', 'COV-HLTH-001', 5000.00, 500.00, '2025-11-17', '2026-11-16');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000021-002', 'POL-HLTH-2026-000021', 'COV-HLTH-002', 200000.00, 1000.00, '2025-11-17', '2026-11-16');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000022-001', 'POL-LIAB-2026-000022', 'COV-LIAB-001', 200000.00, 2000.00, '2025-11-17', '2026-11-16');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000022-002', 'POL-LIAB-2026-000022', 'COV-LIAB-002', 75000.00, 2000.00, '2025-11-17', '2026-11-16');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000023-001', 'POL-LIAB-2026-000023', 'COV-LIAB-001', 50000.00, 2000.00, '2025-11-17', '2026-11-16');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000023-002', 'POL-LIAB-2026-000023', 'COV-LIAB-002', 112500.00, 1000.00, '2025-11-17', '2026-11-16');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000024-001', 'POL-HLTH-2026-000024', 'COV-HLTH-001', 10000.00, 500.00, '2025-12-02', '2026-12-01');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000024-002', 'POL-HLTH-2026-000024', 'COV-HLTH-002', 150000.00, 2000.00, '2025-12-02', '2026-12-01');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000024-003', 'POL-HLTH-2026-000024', 'COV-HLTH-003', 50000.00, 500.00, '2025-12-02', '2026-12-01');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000025-001', 'POL-HOME-2026-000025', 'COV-HOME-002', 100000.00, 2000.00, '2025-12-03', '2026-12-02');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000025-002', 'POL-HOME-2026-000025', 'COV-HOME-004', 40000.00, 1000.00, '2025-12-03', '2026-12-02');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000026-001', 'POL-HLTH-2026-000026', 'COV-HLTH-002', 100000.00, 1000.00, '2025-12-05', '2026-12-04');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000026-002', 'POL-HLTH-2026-000026', 'COV-HLTH-003', 100000.00, 1000.00, '2025-12-05', '2026-12-04');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000027-001', 'POL-AUTO-2026-000027', 'COV-AUTO-001', 12500.00, 1000.00, '2025-12-16', '2026-12-15');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000027-002', 'POL-AUTO-2026-000027', 'COV-AUTO-002', 30000.00, 1000.00, '2025-12-16', '2026-12-15');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000027-003', 'POL-AUTO-2026-000027', 'COV-AUTO-004', 3000.00, 100.00, '2025-12-16', '2026-12-15');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000028-001', 'POL-HLTH-2026-000028', 'COV-HLTH-001', 10000.00, 250.00, '2025-12-18', '2026-12-17');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000028-002', 'POL-HLTH-2026-000028', 'COV-HLTH-002', 150000.00, 1000.00, '2025-12-18', '2026-12-17');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000028-003', 'POL-HLTH-2026-000028', 'COV-HLTH-003', 100000.00, 500.00, '2026-01-03', '2026-12-17');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000029-001', 'POL-HLTH-2026-000029', 'COV-HLTH-001', 5000.00, 500.00, '2025-12-19', '2026-12-18');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000029-002', 'POL-HLTH-2026-000029', 'COV-HLTH-002', 100000.00, 2000.00, '2025-12-19', '2026-12-18');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000029-003', 'POL-HLTH-2026-000029', 'COV-HLTH-003', 25000.00, 500.00, '2025-12-19', '2026-12-18');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000030-001', 'POL-HOME-2026-000030', 'COV-HOME-002', 25000.00, 2000.00, '2025-12-21', '2026-12-20');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000030-002', 'POL-HOME-2026-000030', 'COV-HOME-003', 45000.00, 500.00, '2025-12-21', '2026-12-20');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000031-001', 'POL-HOME-2026-000031', 'COV-HOME-001', 200000.00, 1000.00, '2025-12-26', '2026-12-25');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000031-002', 'POL-HOME-2026-000031', 'COV-HOME-002', 75000.00, 1000.00, '2025-12-26', '2026-12-25');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000031-003', 'POL-HOME-2026-000031', 'COV-HOME-003', 30000.00, 1000.00, '2026-03-19', '2026-12-25');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000032-001', 'POL-HOME-2026-000032', 'COV-HOME-001', 200000.00, 2000.00, '2026-01-03', '2027-01-02');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000032-002', 'POL-HOME-2026-000032', 'COV-HOME-002', 50000.00, 2000.00, '2026-01-03', '2027-01-02');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000032-003', 'POL-HOME-2026-000032', 'COV-HOME-004', 80000.00, 500.00, '2026-03-12', '2027-01-02');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000033-001', 'POL-AUTO-2026-000033', 'COV-AUTO-001', 12500.00, 1000.00, '2026-01-10', '2027-01-09');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000033-002', 'POL-AUTO-2026-000033', 'COV-AUTO-004', 6000.00, 200.00, '2026-01-10', '2027-01-09');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000034-001', 'POL-AUTO-2026-000034', 'COV-AUTO-002', 30000.00, 500.00, '2026-01-24', '2027-01-23');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000034-002', 'POL-AUTO-2026-000034', 'COV-AUTO-003', 75000.00, 0.00, '2026-01-24', '2027-01-23');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000034-003', 'POL-AUTO-2026-000034', 'COV-AUTO-004', 1500.00, 100.00, '2026-01-24', '2027-01-23');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000035-001', 'POL-AUTO-2026-000035', 'COV-AUTO-002', 30000.00, 500.00, '2026-02-01', '2027-01-31');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000035-002', 'POL-AUTO-2026-000035', 'COV-AUTO-003', 100000.00, 0.00, '2026-02-01', '2027-01-31');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000035-003', 'POL-AUTO-2026-000035', 'COV-AUTO-004', 1500.00, 200.00, '2026-02-01', '2027-01-31');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000036-001', 'POL-HOME-2026-000036', 'COV-HOME-001', 300000.00, 2000.00, '2026-02-14', '2027-02-13');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000036-002', 'POL-HOME-2026-000036', 'COV-HOME-002', 75000.00, 2000.00, '2026-02-14', '2027-02-13');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000036-003', 'POL-HOME-2026-000036', 'COV-HOME-004', 20000.00, 1000.00, '2026-02-14', '2027-02-13');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000037-001', 'POL-HOME-2026-000037', 'COV-HOME-001', 200000.00, 1000.00, '2026-02-27', '2027-02-26');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000037-002', 'POL-HOME-2026-000037', 'COV-HOME-004', 80000.00, 500.00, '2026-02-27', '2027-02-26');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000038-001', 'POL-HOME-2026-000038', 'COV-HOME-001', 100000.00, 2000.00, '2026-03-26', '2027-03-10');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000038-002', 'POL-HOME-2026-000038', 'COV-HOME-002', 75000.00, 1000.00, '2026-03-11', '2027-03-10');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000038-003', 'POL-HOME-2026-000038', 'COV-HOME-004', 60000.00, 1000.00, '2026-03-11', '2027-03-10');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000039-001', 'POL-HLTH-2026-000039', 'COV-HLTH-002', 150000.00, 1000.00, '2026-03-18', '2027-03-17');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000039-002', 'POL-HLTH-2026-000039', 'COV-HLTH-003', 50000.00, 1000.00, '2026-03-18', '2027-03-17');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000040-001', 'POL-LIAB-2026-000040', 'COV-LIAB-001', 200000.00, 2000.00, '2026-03-18', '2027-03-17');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000040-002', 'POL-LIAB-2026-000040', 'COV-LIAB-002', 150000.00, 2000.00, '2026-03-18', '2027-03-17');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000041-001', 'POL-LIAB-2026-000041', 'COV-LIAB-001', 100000.00, 1000.00, '2026-03-19', '2027-03-18');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000041-002', 'POL-LIAB-2026-000041', 'COV-LIAB-002', 150000.00, 2000.00, '2026-03-19', '2027-03-18');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000042-001', 'POL-TRVL-2026-000042', 'COV-TRVL-001', 4000.00, 200.00, '2026-04-03', '2026-05-14');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000042-002', 'POL-TRVL-2026-000042', 'COV-TRVL-002', 6000.00, 50.00, '2026-03-20', '2026-05-14');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000043-001', 'POL-HLTH-2026-000043', 'COV-HLTH-002', 50000.00, 2000.00, '2026-03-27', '2027-03-26');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000043-002', 'POL-HLTH-2026-000043', 'COV-HLTH-003', 50000.00, 500.00, '2026-03-27', '2027-03-26');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000044-001', 'POL-LIAB-2026-000044', 'COV-LIAB-001', 200000.00, 2000.00, '2026-04-01', '2027-03-31');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000044-002', 'POL-LIAB-2026-000044', 'COV-LIAB-002', 75000.00, 1000.00, '2026-04-01', '2027-03-31');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000045-001', 'POL-HOME-2026-000045', 'COV-HOME-001', 300000.00, 1000.00, '2026-04-06', '2027-04-05');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000045-002', 'POL-HOME-2026-000045', 'COV-HOME-002', 50000.00, 2000.00, '2026-04-06', '2027-04-05');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000046-001', 'POL-AUTO-2026-000046', 'COV-AUTO-002', 45000.00, 1000.00, '2026-04-07', '2027-04-06');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000046-002', 'POL-AUTO-2026-000046', 'COV-AUTO-003', 100000.00, 0.00, '2026-04-07', '2027-04-06');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000046-003', 'POL-AUTO-2026-000046', 'COV-AUTO-004', 3000.00, 200.00, '2026-04-07', '2027-04-06');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000047-001', 'POL-HLTH-2026-000047', 'COV-HLTH-001', 5000.00, 500.00, '2026-04-09', '2027-04-08');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000047-002', 'POL-HLTH-2026-000047', 'COV-HLTH-002', 150000.00, 2000.00, '2026-04-09', '2027-04-08');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000047-003', 'POL-HLTH-2026-000047', 'COV-HLTH-003', 100000.00, 500.00, '2026-04-09', '2027-04-08');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000048-001', 'POL-HOME-2026-000048', 'COV-HOME-002', 50000.00, 2000.00, '2026-04-14', '2027-04-13');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000048-002', 'POL-HOME-2026-000048', 'COV-HOME-003', 30000.00, 500.00, '2026-04-14', '2027-04-13');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000048-003', 'POL-HOME-2026-000048', 'COV-HOME-004', 20000.00, 500.00, '2026-04-14', '2027-04-13');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000049-001', 'POL-LIAB-2026-000049', 'COV-LIAB-001', 100000.00, 1000.00, '2026-04-27', '2027-04-26');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000049-002', 'POL-LIAB-2026-000049', 'COV-LIAB-002', 37500.00, 2000.00, '2026-04-27', '2027-04-26');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000050-001', 'POL-LIAB-2026-000050', 'COV-LIAB-001', 200000.00, 2000.00, '2026-05-10', '2027-05-09');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000050-002', 'POL-LIAB-2026-000050', 'COV-LIAB-002', 75000.00, 2000.00, '2026-05-10', '2027-05-09');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000051-001', 'POL-AUTO-2026-000051', 'COV-AUTO-001', 37500.00, 500.00, '2026-05-11', '2027-05-10');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000051-002', 'POL-AUTO-2026-000051', 'COV-AUTO-002', 60000.00, 500.00, '2026-05-11', '2027-05-10');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000051-003', 'POL-AUTO-2026-000051', 'COV-AUTO-003', 75000.00, 0.00, '2026-05-11', '2027-05-10');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000052-001', 'POL-HLTH-2026-000052', 'COV-HLTH-002', 50000.00, 1000.00, '2026-05-11', '2027-05-10');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000052-002', 'POL-HLTH-2026-000052', 'COV-HLTH-003', 25000.00, 1000.00, '2026-05-11', '2027-05-10');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000053-001', 'POL-HLTH-2026-000053', 'COV-HLTH-001', 10000.00, 250.00, '2026-05-14', '2027-05-13');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000053-002', 'POL-HLTH-2026-000053', 'COV-HLTH-002', 200000.00, 1000.00, '2026-05-14', '2027-05-13');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000053-003', 'POL-HLTH-2026-000053', 'COV-HLTH-003', 50000.00, 1000.00, '2026-05-14', '2027-05-13');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000054-001', 'POL-HOME-2026-000054', 'COV-HOME-003', 30000.00, 1000.00, '2026-05-21', '2027-05-20');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000054-002', 'POL-HOME-2026-000054', 'COV-HOME-004', 20000.00, 1000.00, '2026-05-21', '2027-05-20');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000055-001', 'POL-AUTO-2026-000055', 'COV-AUTO-001', 37500.00, 500.00, '2026-05-30', '2027-05-29');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000055-002', 'POL-AUTO-2026-000055', 'COV-AUTO-002', 60000.00, 1000.00, '2026-05-30', '2027-05-29');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000055-003', 'POL-AUTO-2026-000055', 'COV-AUTO-004', 3000.00, 200.00, '2026-05-30', '2027-05-29');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000056-001', 'POL-AUTO-2026-000056', 'COV-AUTO-001', 12500.00, 1000.00, '2026-05-30', '2027-05-29');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000056-002', 'POL-AUTO-2026-000056', 'COV-AUTO-003', 25000.00, 0.00, '2026-05-30', '2027-05-29');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000057-001', 'POL-AUTO-2026-000057', 'COV-AUTO-001', 12500.00, 1000.00, '2026-06-27', '2027-05-30');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000057-002', 'POL-AUTO-2026-000057', 'COV-AUTO-002', 45000.00, 1000.00, '2026-05-31', '2027-05-30');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000057-003', 'POL-AUTO-2026-000057', 'COV-AUTO-004', 4500.00, 200.00, '2026-05-31', '2027-05-30');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000058-001', 'POL-HOME-2026-000058', 'COV-HOME-002', 50000.00, 2000.00, '2026-06-03', '2027-06-02');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000058-002', 'POL-HOME-2026-000058', 'COV-HOME-003', 30000.00, 1000.00, '2026-06-03', '2027-06-02');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000058-003', 'POL-HOME-2026-000058', 'COV-HOME-004', 20000.00, 500.00, '2026-06-03', '2027-06-02');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000059-001', 'POL-AUTO-2026-000059', 'COV-AUTO-001', 25000.00, 500.00, '2026-06-05', '2027-06-04');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000059-002', 'POL-AUTO-2026-000059', 'COV-AUTO-003', 100000.00, 0.00, '2026-07-06', '2027-06-04');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000060-001', 'POL-AUTO-2026-000060', 'COV-AUTO-002', 60000.00, 500.00, '2026-06-09', '2027-06-08');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000060-002', 'POL-AUTO-2026-000060', 'COV-AUTO-004', 1500.00, 100.00, '2026-06-09', '2027-06-08');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000061-001', 'POL-HOME-2026-000061', 'COV-HOME-002', 75000.00, 1000.00, '2026-06-09', '2027-06-08');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000061-002', 'POL-HOME-2026-000061', 'COV-HOME-004', 40000.00, 1000.00, '2026-06-09', '2027-06-08');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000062-001', 'POL-HOME-2026-000062', 'COV-HOME-002', 100000.00, 1000.00, '2026-06-23', '2027-06-22');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000062-002', 'POL-HOME-2026-000062', 'COV-HOME-004', 80000.00, 1000.00, '2026-06-23', '2027-06-22');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000063-001', 'POL-HOME-2026-000063', 'COV-HOME-001', 200000.00, 2000.00, '2026-06-23', '2027-06-22');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000063-002', 'POL-HOME-2026-000063', 'COV-HOME-003', 15000.00, 500.00, '2026-06-23', '2027-06-22');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000063-003', 'POL-HOME-2026-000063', 'COV-HOME-004', 80000.00, 1000.00, '2026-06-23', '2027-06-22');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000064-001', 'POL-HOME-2026-000064', 'COV-HOME-001', 200000.00, 2000.00, '2026-07-08', '2027-07-07');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000064-002', 'POL-HOME-2026-000064', 'COV-HOME-002', 100000.00, 1000.00, '2026-07-08', '2027-07-07');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000064-003', 'POL-HOME-2026-000064', 'COV-HOME-004', 40000.00, 1000.00, '2026-07-08', '2027-07-07');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000065-001', 'POL-AUTO-2026-000065', 'COV-AUTO-001', 25000.00, 500.00, '2026-07-15', '2027-07-14');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000065-002', 'POL-AUTO-2026-000065', 'COV-AUTO-002', 15000.00, 1000.00, '2026-07-15', '2027-07-14');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000065-003', 'POL-AUTO-2026-000065', 'COV-AUTO-004', 3000.00, 200.00, '2026-07-15', '2027-07-14');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000066-001', 'POL-AUTO-2026-000066', 'COV-AUTO-001', 12500.00, 500.00, '2026-07-26', '2027-07-25');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000066-002', 'POL-AUTO-2026-000066', 'COV-AUTO-004', 1500.00, 200.00, '2026-07-26', '2027-07-25');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000067-001', 'POL-AUTO-2026-000067', 'COV-AUTO-001', 25000.00, 500.00, '2026-08-15', '2027-07-29');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000067-002', 'POL-AUTO-2026-000067', 'COV-AUTO-004', 1500.00, 200.00, '2026-07-30', '2027-07-29');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000068-001', 'POL-LIAB-2026-000068', 'COV-LIAB-001', 150000.00, 1000.00, '2026-07-30', '2027-07-29');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000068-002', 'POL-LIAB-2026-000068', 'COV-LIAB-002', 112500.00, 1000.00, '2026-07-30', '2027-07-29');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000069-001', 'POL-AUTO-2026-000069', 'COV-AUTO-001', 12500.00, 1000.00, '2026-08-04', '2027-08-03');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000069-002', 'POL-AUTO-2026-000069', 'COV-AUTO-002', 30000.00, 1000.00, '2026-08-04', '2027-08-03');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000070-001', 'POL-HLTH-2026-000070', 'COV-HLTH-001', 20000.00, 500.00, '2026-09-17', '2027-08-04');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000070-002', 'POL-HLTH-2026-000070', 'COV-HLTH-003', 50000.00, 1000.00, '2026-08-05', '2027-08-04');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000071-001', 'POL-LIAB-2026-000071', 'COV-LIAB-001', 100000.00, 1000.00, '2026-08-11', '2027-08-10');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000071-002', 'POL-LIAB-2026-000071', 'COV-LIAB-002', 75000.00, 1000.00, '2026-08-11', '2027-08-10');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000072-001', 'POL-HLTH-2026-000072', 'COV-HLTH-001', 5000.00, 250.00, '2026-08-13', '2027-08-12');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000072-002', 'POL-HLTH-2026-000072', 'COV-HLTH-002', 150000.00, 2000.00, '2026-08-13', '2027-08-12');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000072-003', 'POL-HLTH-2026-000072', 'COV-HLTH-003', 75000.00, 1000.00, '2026-08-13', '2027-08-12');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000073-001', 'POL-AUTO-2026-000073', 'COV-AUTO-001', 37500.00, 1000.00, '2026-08-14', '2027-08-13');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000073-002', 'POL-AUTO-2026-000073', 'COV-AUTO-003', 25000.00, 0.00, '2026-08-14', '2027-08-13');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000074-001', 'POL-TRVL-2026-000074', 'COV-TRVL-002', 6000.00, 50.00, '2026-08-14', '2026-09-16');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000074-002', 'POL-TRVL-2026-000074', 'COV-TRVL-003', 100000.00, 500.00, '2026-08-14', '2026-09-16');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000075-001', 'POL-HOME-2026-000075', 'COV-HOME-002', 100000.00, 2000.00, '2026-08-19', '2027-08-18');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000075-002', 'POL-HOME-2026-000075', 'COV-HOME-004', 20000.00, 1000.00, '2026-08-19', '2027-08-18');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000076-001', 'POL-TRVL-2026-000076', 'COV-TRVL-001', 4000.00, 100.00, '2026-08-21', '2026-11-11');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000076-002', 'POL-TRVL-2026-000076', 'COV-TRVL-002', 6000.00, 100.00, '2026-08-21', '2026-11-11');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000076-003', 'POL-TRVL-2026-000076', 'COV-TRVL-003', 100000.00, 250.00, '2026-08-21', '2026-11-11');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000077-001', 'POL-AUTO-2026-000077', 'COV-AUTO-002', 45000.00, 500.00, '2026-08-22', '2027-08-21');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000077-002', 'POL-AUTO-2026-000077', 'COV-AUTO-003', 100000.00, 0.00, '2026-08-22', '2027-08-21');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000077-003', 'POL-AUTO-2026-000077', 'COV-AUTO-004', 4500.00, 200.00, '2026-08-22', '2027-08-21');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000078-001', 'POL-HOME-2026-000078', 'COV-HOME-001', 100000.00, 2000.00, '2026-08-24', '2027-08-23');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000078-002', 'POL-HOME-2026-000078', 'COV-HOME-004', 60000.00, 1000.00, '2026-08-24', '2027-08-23');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000079-001', 'POL-AUTO-2026-000079', 'COV-AUTO-001', 37500.00, 500.00, '2026-08-25', '2027-08-24');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000079-002', 'POL-AUTO-2026-000079', 'COV-AUTO-002', 60000.00, 1000.00, '2026-08-25', '2027-08-24');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000080-001', 'POL-AUTO-2026-000080', 'COV-AUTO-001', 25000.00, 500.00, '2026-08-27', '2027-08-26');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000080-002', 'POL-AUTO-2026-000080', 'COV-AUTO-002', 60000.00, 500.00, '2026-08-27', '2027-08-26');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000080-003', 'POL-AUTO-2026-000080', 'COV-AUTO-003', 75000.00, 0.00, '2026-08-27', '2027-08-26');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000081-001', 'POL-HOME-2026-000081', 'COV-HOME-001', 400000.00, 2000.00, '2026-09-05', '2027-08-28');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000081-002', 'POL-HOME-2026-000081', 'COV-HOME-002', 75000.00, 1000.00, '2026-08-29', '2027-08-28');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000081-003', 'POL-HOME-2026-000081', 'COV-HOME-004', 40000.00, 500.00, '2026-10-27', '2027-08-28');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000082-001', 'POL-AUTO-2026-000082', 'COV-AUTO-001', 25000.00, 500.00, '2026-08-30', '2027-08-29');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000082-002', 'POL-AUTO-2026-000082', 'COV-AUTO-003', 50000.00, 0.00, '2026-08-30', '2027-08-29');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000082-003', 'POL-AUTO-2026-000082', 'COV-AUTO-004', 4500.00, 100.00, '2026-08-30', '2027-08-29');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000083-001', 'POL-HOME-2026-000083', 'COV-HOME-002', 25000.00, 2000.00, '2026-08-31', '2027-08-30');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000083-002', 'POL-HOME-2026-000083', 'COV-HOME-004', 80000.00, 1000.00, '2026-08-31', '2027-08-30');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000084-001', 'POL-AUTO-2026-000084', 'COV-AUTO-002', 30000.00, 1000.00, '2026-09-05', '2027-09-04');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000084-002', 'POL-AUTO-2026-000084', 'COV-AUTO-004', 1500.00, 200.00, '2026-09-05', '2027-09-04');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000085-001', 'POL-LIAB-2026-000085', 'COV-LIAB-001', 50000.00, 2000.00, '2026-09-06', '2027-09-05');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000085-002', 'POL-LIAB-2026-000085', 'COV-LIAB-002', 37500.00, 1000.00, '2026-09-06', '2027-09-05');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000086-001', 'POL-HLTH-2026-000086', 'COV-HLTH-001', 15000.00, 250.00, '2026-09-12', '2027-09-11');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000086-002', 'POL-HLTH-2026-000086', 'COV-HLTH-002', 200000.00, 1000.00, '2026-09-12', '2027-09-11');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000086-003', 'POL-HLTH-2026-000086', 'COV-HLTH-003', 75000.00, 1000.00, '2026-09-12', '2027-09-11');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000087-001', 'POL-HLTH-2026-000087', 'COV-HLTH-001', 20000.00, 500.00, '2026-09-12', '2027-09-11');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000087-002', 'POL-HLTH-2026-000087', 'COV-HLTH-002', 50000.00, 2000.00, '2026-09-12', '2027-09-11');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000087-003', 'POL-HLTH-2026-000087', 'COV-HLTH-003', 25000.00, 1000.00, '2026-09-12', '2027-09-11');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000088-001', 'POL-LIAB-2026-000088', 'COV-LIAB-001', 100000.00, 2000.00, '2026-09-12', '2027-09-11');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000088-002', 'POL-LIAB-2026-000088', 'COV-LIAB-002', 75000.00, 1000.00, '2026-09-12', '2027-09-11');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000089-001', 'POL-LIAB-2026-000089', 'COV-LIAB-001', 150000.00, 2000.00, '2026-09-14', '2027-09-13');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-LIAB-2026-000089-002', 'POL-LIAB-2026-000089', 'COV-LIAB-002', 150000.00, 2000.00, '2026-09-14', '2027-09-13');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000090-001', 'POL-HOME-2026-000090', 'COV-HOME-001', 200000.00, 1000.00, '2026-09-16', '2027-09-15');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000090-002', 'POL-HOME-2026-000090', 'COV-HOME-003', 15000.00, 1000.00, '2026-09-16', '2027-09-15');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000091-001', 'POL-AUTO-2026-000091', 'COV-AUTO-001', 25000.00, 1000.00, '2026-09-18', '2027-09-17');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000091-002', 'POL-AUTO-2026-000091', 'COV-AUTO-002', 30000.00, 1000.00, '2026-09-18', '2027-09-17');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000092-001', 'POL-TRVL-2026-000092', 'COV-TRVL-001', 4000.00, 100.00, '2026-09-21', '2026-10-22');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000092-002', 'POL-TRVL-2026-000092', 'COV-TRVL-003', 50000.00, 500.00, '2026-09-21', '2026-10-22');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000093-001', 'POL-HLTH-2026-000093', 'COV-HLTH-001', 5000.00, 250.00, '2026-09-27', '2027-09-26');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000093-002', 'POL-HLTH-2026-000093', 'COV-HLTH-003', 100000.00, 1000.00, '2026-09-27', '2027-09-26');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000094-001', 'POL-HLTH-2026-000094', 'COV-HLTH-001', 10000.00, 500.00, '2026-10-04', '2027-10-03');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000094-002', 'POL-HLTH-2026-000094', 'COV-HLTH-002', 200000.00, 2000.00, '2026-10-04', '2027-10-03');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000095-001', 'POL-AUTO-2026-000095', 'COV-AUTO-001', 37500.00, 500.00, '2026-10-09', '2027-10-08');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000095-002', 'POL-AUTO-2026-000095', 'COV-AUTO-002', 45000.00, 500.00, '2026-10-09', '2027-10-08');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000095-003', 'POL-AUTO-2026-000095', 'COV-AUTO-003', 50000.00, 0.00, '2026-10-09', '2027-10-08');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000096-001', 'POL-HOME-2026-000096', 'COV-HOME-001', 100000.00, 1000.00, '2026-10-10', '2027-10-09');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HOME-2026-000096-002', 'POL-HOME-2026-000096', 'COV-HOME-004', 60000.00, 500.00, '2026-10-28', '2027-10-09');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000097-001', 'POL-TRVL-2026-000097', 'COV-TRVL-001', 12000.00, 200.00, '2026-10-10', '2026-12-27');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000097-002', 'POL-TRVL-2026-000097', 'COV-TRVL-003', 50000.00, 250.00, '2026-10-20', '2026-12-27');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000098-001', 'POL-TRVL-2026-000098', 'COV-TRVL-001', 12000.00, 100.00, '2026-10-26', '2026-12-21');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000098-002', 'POL-TRVL-2026-000098', 'COV-TRVL-002', 3000.00, 50.00, '2026-10-14', '2026-12-21');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-TRVL-2026-000098-003', 'POL-TRVL-2026-000098', 'COV-TRVL-003', 25000.00, 500.00, '2026-10-14', '2026-12-21');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000099-001', 'POL-AUTO-2026-000099', 'COV-AUTO-001', 12500.00, 1000.00, '2026-10-18', '2027-10-17');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-AUTO-2026-000099-002', 'POL-AUTO-2026-000099', 'COV-AUTO-002', 15000.00, 1000.00, '2026-12-12', '2027-10-17');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000100-001', 'POL-HLTH-2026-000100', 'COV-HLTH-001', 20000.00, 500.00, '2026-10-19', '2027-10-18');
INSERT INTO policy_coverage (policy_coverage_id, policy_id, coverage_id, limit_amount, deductible, effective_start, effective_end) VALUES ('PCV-POL-HLTH-2026-000100-002', 'POL-HLTH-2026-000100', 'COV-HLTH-002', 100000.00, 1000.00, '2026-10-19', '2027-10-18');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000001', 'POL-HOME-2026-000003', '2024-05-17', 'burglary');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000002', 'POL-HOME-2026-000003', '2024-05-21', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000003', 'POL-HOME-2026-000002', '2024-08-29', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000004', 'POL-HOME-2026-000003', '2024-09-18', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000005', 'POL-TRVL-2026-000006', '2024-11-12', 'trip_cancellation');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000006', 'POL-HOME-2026-000002', '2025-01-31', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000007', 'POL-AUTO-2026-000010', '2025-05-20', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000008', 'POL-LIAB-2026-000012', '2025-06-04', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000009', 'POL-LIAB-2026-000012', '2025-06-04', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000010', 'POL-AUTO-2026-000013', '2025-07-10', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000011', 'POL-AUTO-2026-000013', '2025-07-10', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000012', 'POL-AUTO-2026-000010', '2025-10-23', 'collision');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000013', 'POL-LIAB-2026-000022', '2025-12-22', 'third_party_injury');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000014', 'POL-HOME-2026-000011', '2025-12-20', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000015', 'POL-AUTO-2026-000009', '2026-01-17', 'theft');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000016', 'POL-HOME-2026-000031', '2026-02-02', 'burglary');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000017', 'POL-AUTO-2026-000017', '2026-03-20', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000018', 'POL-HOME-2026-000038', '2026-03-25', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000019', 'POL-AUTO-2026-000035', '2026-04-06', 'theft');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000020', 'POL-HOME-2026-000032', '2026-05-05', 'fire');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000021', 'POL-HOME-2026-000045', '2026-05-07', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000022', 'POL-LIAB-2026-000044', '2026-05-21', 'third_party_injury');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000023', 'POL-AUTO-2026-000059', '2026-06-05', 'collision');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000024', 'POL-HOME-2026-000025', '2026-06-11', 'fire');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000025', 'POL-HOME-2026-000037', '2026-06-21', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000026', 'POL-HLTH-2026-000053', '2026-07-17', 'illness');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000027', 'POL-HOME-2026-000058', '2026-07-19', 'burglary');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000028', 'POL-HOME-2026-000063', '2026-07-19', 'burglary');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000029', 'POL-HOME-2026-000062', '2026-07-23', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000030', 'POL-AUTO-2026-000073', '2026-08-08', 'collision');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000031', 'POL-HOME-2026-000061', '2026-08-18', 'burglary');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000032', 'POL-AUTO-2026-000056', '2026-08-24', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000033', 'POL-HLTH-2026-000039', '2026-08-24', 'injury');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000034', 'POL-LIAB-2026-000044', '2026-09-05', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000035', 'POL-AUTO-2026-000077', '2026-09-08', 'theft');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000036', 'POL-AUTO-2026-000056', '2026-08-30', 'collision');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000037', 'POL-TRVL-2026-000074', '2026-09-06', 'baggage_loss');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000038', 'POL-HOME-2026-000062', '2026-09-09', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000039', 'POL-HOME-2026-000036', '2026-09-16', 'fire');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000040', 'POL-AUTO-2026-000065', '2026-09-30', 'collision');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000041', 'POL-AUTO-2026-000055', '2026-09-20', 'collision');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000042', 'POL-AUTO-2026-000095', '2026-10-02', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000043', 'POL-AUTO-2026-000051', '2026-10-03', 'collision');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000044', 'POL-AUTO-2026-000080', '2026-10-08', 'collision');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000045', 'POL-AUTO-2026-000091', '2026-10-06', 'theft');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000046', 'POL-LIAB-2026-000071', '2026-10-10', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000047', 'POL-AUTO-2026-000065', '2026-09-30', 'collision');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000048', 'POL-HLTH-2026-000100', '2026-10-20', 'injury');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000049', 'POL-HOME-2026-000096', '2026-10-20', 'fire');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000050', 'POL-TRVL-2026-000097', '2026-10-20', 'injury');
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000001', 'POL-HOME-2026-000003', 'INC-2026-000001', 'HOME', '2024-05-17', 6681.75);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000002', 'POL-HOME-2026-000003', 'INC-2026-000002', 'HOME', '2024-05-23', 10800.75);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000003', 'POL-HOME-2026-000002', 'INC-2026-000003', 'HOME', '2024-09-12', 3597.31);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000004', 'POL-HOME-2026-000003', 'INC-2026-000004', 'HOME', '2024-09-23', 4619.56);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000005', 'POL-TRVL-2026-000006', 'INC-2026-000005', 'TRVL', '2024-11-12', 350.15);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000006', 'POL-HOME-2026-000002', 'INC-2026-000006', 'HOME', '2025-02-10', 8888.95);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000007', 'POL-AUTO-2026-000010', 'INC-2026-000007', 'AUTO', '2025-05-23', 2112.42);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000008', 'POL-LIAB-2026-000012', 'INC-2026-000008', 'LIAB', '2025-06-06', 7645.75);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000009', 'POL-LIAB-2026-000012', 'INC-2026-000009', 'LIAB', '2025-06-11', 7645.75);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000010', 'POL-AUTO-2026-000013', 'INC-2026-000010', 'AUTO', '2025-07-12', 751.05);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000011', 'POL-AUTO-2026-000013', 'INC-2026-000011', 'AUTO', '2025-07-15', 751.05);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000012', 'POL-AUTO-2026-000010', 'INC-2026-000012', 'AUTO', '2025-10-24', 13281.49);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000013', 'POL-LIAB-2026-000022', 'INC-2026-000013', 'LIAB', '2025-12-22', 17076.07);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000014', 'POL-HOME-2026-000011', 'INC-2026-000014', 'HOME', '2026-01-03', 8118.15);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000015', 'POL-AUTO-2026-000009', 'INC-2026-000015', 'AUTO', '2026-01-24', 6655.51);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000016', 'POL-HOME-2026-000031', 'INC-2026-000016', 'HOME', '2026-02-03', 2375.96);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000017', 'POL-AUTO-2026-000017', 'INC-2026-000017', 'AUTO', '2026-03-20', 5730.46);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000018', 'POL-HOME-2026-000038', 'INC-2026-000018', 'HOME', '2026-03-26', 72646.16);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000019', 'POL-AUTO-2026-000035', 'INC-2026-000019', 'AUTO', '2026-04-06', 5341.04);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000020', 'POL-HOME-2026-000032', 'INC-2026-000020', 'HOME', '2026-05-05', 11771.54);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000021', 'POL-HOME-2026-000045', 'INC-2026-000021', 'HOME', '2026-05-07', 50000.00);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000022', 'POL-LIAB-2026-000044', 'INC-2026-000022', 'LIAB', '2026-05-24', 2000.00);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000023', 'POL-AUTO-2026-000059', 'INC-2026-000023', 'AUTO', '2026-06-08', 5400.00);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000024', 'POL-HOME-2026-000025', 'INC-2026-000024', 'HOME', '2026-06-21', 8161.14);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000025', 'POL-HOME-2026-000037', 'INC-2026-000025', 'HOME', '2026-07-01', 5802.32);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000026', 'POL-HLTH-2026-000053', 'INC-2026-000026', 'HLTH', '2026-07-20', 3699.25);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000027', 'POL-HOME-2026-000058', 'INC-2026-000027', 'HOME', '2026-07-20', 1263.56);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000028', 'POL-HOME-2026-000063', 'INC-2026-000028', 'HOME', '2026-07-24', 2941.37);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000029', 'POL-HOME-2026-000062', 'INC-2026-000029', 'HOME', '2026-07-24', 1442.38);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000030', 'POL-AUTO-2026-000073', 'INC-2026-000030', 'AUTO', '2026-08-08', 1242.56);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000031', 'POL-HOME-2026-000061', 'INC-2026-000031', 'HOME', '2026-08-23', 23447.90);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000032', 'POL-AUTO-2026-000056', 'INC-2026-000032', 'AUTO', '2026-08-29', 1285.75);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000033', 'POL-HLTH-2026-000039', 'INC-2026-000033', 'HLTH', '2026-09-03', 25044.49);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000034', 'POL-LIAB-2026-000044', 'INC-2026-000034', 'LIAB', '2026-09-05', 21745.62);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000035', 'POL-AUTO-2026-000077', 'INC-2026-000035', 'AUTO', '2026-09-08', 1807.59);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000036', 'POL-AUTO-2026-000056', 'INC-2026-000036', 'AUTO', '2026-09-09', 3312.42);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000037', 'POL-TRVL-2026-000074', 'INC-2026-000037', 'TRVL', '2026-09-09', 393.18);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000038', 'POL-HOME-2026-000062', 'INC-2026-000038', 'HOME', '2026-09-09', 124790.38);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000039', 'POL-HOME-2026-000036', 'INC-2026-000039', 'HOME', '2026-09-30', 3950.24);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000040', 'POL-AUTO-2026-000065', 'INC-2026-000040', 'AUTO', '2026-10-03', 7855.82);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000041', 'POL-AUTO-2026-000055', 'INC-2026-000041', 'AUTO', '2026-10-04', 576.74);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000042', 'POL-AUTO-2026-000095', 'INC-2026-000042', 'AUTO', '2026-10-04', 3393.92);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000043', 'POL-AUTO-2026-000051', 'INC-2026-000043', 'AUTO', '2026-10-04', 2101.35);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000044', 'POL-AUTO-2026-000080', 'INC-2026-000044', 'AUTO', '2026-10-09', 4541.39);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000045', 'POL-AUTO-2026-000091', 'INC-2026-000045', 'AUTO', '2026-10-11', 3559.56);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000046', 'POL-LIAB-2026-000071', 'INC-2026-000046', 'LIAB', '2026-10-11', 8069.22);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000047', 'POL-AUTO-2026-000065', 'INC-2026-000047', 'AUTO', '2026-10-22', 7855.82);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000048', 'POL-HLTH-2026-000100', 'INC-2026-000048', 'HLTH', '2026-10-22', 4250.32);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000049', 'POL-HOME-2026-000096', 'INC-2026-000049', 'HOME', '2026-10-22', 21550.96);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000050', 'POL-TRVL-2026-000097', 'INC-2026-000050', 'TRVL', '2026-10-22', 2084.08);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000001-001', 'CLM-2026-000001', 'COV-HOME-003', 'replacement', 6681.75);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000002-001', 'CLM-2026-000002', 'COV-HOME-002', 'replacement', 865.77);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000002-002', 'CLM-2026-000002', 'COV-HOME-002', 'replacement', 9934.98);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000003-001', 'CLM-2026-000003', 'COV-HOME-002', 'repair', 3597.31);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000004-001', 'CLM-2026-000004', 'COV-HOME-002', 'repair', 4619.56);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000005-001', 'CLM-2026-000005', 'COV-TRVL-001', 'cancellation_fee', 350.15);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000006-001', 'CLM-2026-000006', 'COV-HOME-002', 'replacement', 2772.63);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000006-002', 'CLM-2026-000006', 'COV-HOME-002', 'replacement', 6116.32);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000007-001', 'CLM-2026-000007', 'COV-AUTO-003', 'liability_payment', 2112.42);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000008-001', 'CLM-2026-000008', 'COV-LIAB-002', 'repair', 2252.34);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000008-002', 'CLM-2026-000008', 'COV-LIAB-002', 'liability_payment', 1879.93);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000008-003', 'CLM-2026-000008', 'COV-LIAB-002', 'repair', 3513.48);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000009-001', 'CLM-2026-000009', 'COV-LIAB-002', 'repair', 2252.34);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000009-002', 'CLM-2026-000009', 'COV-LIAB-002', 'liability_payment', 1879.93);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000009-003', 'CLM-2026-000009', 'COV-LIAB-002', 'repair', 3513.48);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000010-001', 'CLM-2026-000010', 'COV-AUTO-003', 'liability_payment', 751.05);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000011-001', 'CLM-2026-000011', 'COV-AUTO-003', 'liability_payment', 751.05);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000012-001', 'CLM-2026-000012', 'COV-AUTO-001', 'repair', 9321.32);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000012-002', 'CLM-2026-000012', 'COV-AUTO-003', 'liability_payment', 3960.17);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000013-001', 'CLM-2026-000013', 'COV-LIAB-001', 'medical_treatment', 3393.47);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000013-002', 'CLM-2026-000013', 'COV-LIAB-001', 'medical_treatment', 13682.60);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000014-001', 'CLM-2026-000014', 'COV-HOME-002', 'replacement', 5421.87);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000014-002', 'CLM-2026-000014', 'COV-HOME-002', 'replacement', 2696.28);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000015-001', 'CLM-2026-000015', 'COV-AUTO-002', 'replacement', 5584.36);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000015-002', 'CLM-2026-000015', 'COV-AUTO-002', 'replacement', 1071.15);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000016-001', 'CLM-2026-000016', 'COV-HOME-003', 'replacement', 2375.96);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000017-001', 'CLM-2026-000017', 'COV-AUTO-003', 'liability_payment', 5730.46);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000018-001', 'CLM-2026-000018', 'COV-HOME-002', 'replacement', 72646.16);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000019-001', 'CLM-2026-000019', 'COV-AUTO-002', 'replacement', 1319.37);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000019-002', 'CLM-2026-000019', 'COV-AUTO-002', 'replacement', 787.66);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000019-003', 'CLM-2026-000019', 'COV-AUTO-003', 'liability_payment', 3234.01);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000020-001', 'CLM-2026-000020', 'COV-HOME-004', 'replacement', 8115.64);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000020-002', 'CLM-2026-000020', 'COV-HOME-004', 'replacement', 3655.90);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000021-001', 'CLM-2026-000021', 'COV-HOME-002', 'repair', 50000.00);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000022-001', 'CLM-2026-000022', 'COV-LIAB-001', 'medical_treatment', 2000.00);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000023-001', 'CLM-2026-000023', 'COV-AUTO-001', 'towing', 3724.24);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000023-002', 'CLM-2026-000023', 'COV-AUTO-001', 'towing', 1675.76);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000024-001', 'CLM-2026-000024', 'COV-HOME-002', 'replacement', 3784.55);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000024-002', 'CLM-2026-000024', 'COV-HOME-002', 'repair', 4376.59);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000025-001', 'CLM-2026-000025', 'COV-HOME-004', 'replacement', 5802.32);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000026-001', 'CLM-2026-000026', 'COV-HLTH-003', 'medical_treatment', 3699.25);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000027-001', 'CLM-2026-000027', 'COV-HOME-003', 'replacement', 1263.56);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000028-001', 'CLM-2026-000028', 'COV-HOME-004', 'replacement', 2941.37);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000029-001', 'CLM-2026-000029', 'COV-HOME-002', 'repair', 1442.38);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000030-001', 'CLM-2026-000030', 'COV-AUTO-001', 'repair', 1242.56);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000031-001', 'CLM-2026-000031', 'COV-HOME-002', 'repair', 23447.90);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000032-001', 'CLM-2026-000032', 'COV-AUTO-003', 'liability_payment', 1285.75);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000033-001', 'CLM-2026-000033', 'COV-HLTH-002', 'hospital_stay', 17959.56);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000033-002', 'CLM-2026-000033', 'COV-HLTH-002', 'hospital_stay', 4452.22);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000033-003', 'CLM-2026-000033', 'COV-HLTH-002', 'hospital_stay', 2632.71);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000034-001', 'CLM-2026-000034', 'COV-LIAB-002', 'repair', 6960.18);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000034-002', 'CLM-2026-000034', 'COV-LIAB-002', 'liability_payment', 4558.79);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000034-003', 'CLM-2026-000034', 'COV-LIAB-002', 'repair', 10226.65);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000035-001', 'CLM-2026-000035', 'COV-AUTO-002', 'replacement', 604.54);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000035-002', 'CLM-2026-000035', 'COV-AUTO-002', 'replacement', 1203.05);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000036-001', 'CLM-2026-000036', 'COV-AUTO-003', 'liability_payment', 3312.42);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000037-001', 'CLM-2026-000037', 'COV-TRVL-002', 'baggage', 141.49);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000037-002', 'CLM-2026-000037', 'COV-TRVL-002', 'baggage', 251.69);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000038-001', 'CLM-2026-000038', 'COV-HOME-002', 'repair', 124790.38);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000039-001', 'CLM-2026-000039', 'COV-HOME-001', 'replacement', 3950.24);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000040-001', 'CLM-2026-000040', 'COV-AUTO-002', 'replacement', 7855.82);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000041-001', 'CLM-2026-000041', 'COV-AUTO-004', 'towing', 360.19);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000041-002', 'CLM-2026-000041', 'COV-AUTO-004', 'towing', 216.55);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000042-001', 'CLM-2026-000042', 'COV-AUTO-003', 'liability_payment', 2032.69);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000042-002', 'CLM-2026-000042', 'COV-AUTO-003', 'liability_payment', 1361.23);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000043-001', 'CLM-2026-000043', 'COV-AUTO-001', 'towing', 805.57);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000043-002', 'CLM-2026-000043', 'COV-AUTO-001', 'repair', 1295.78);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000044-001', 'CLM-2026-000044', 'COV-AUTO-001', 'towing', 2194.06);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000044-002', 'CLM-2026-000044', 'COV-AUTO-001', 'towing', 2347.33);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000045-001', 'CLM-2026-000045', 'COV-AUTO-002', 'replacement', 2317.74);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000045-002', 'CLM-2026-000045', 'COV-AUTO-002', 'replacement', 1241.82);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000046-001', 'CLM-2026-000046', 'COV-LIAB-001', 'liability_payment', 8069.22);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000047-001', 'CLM-2026-000047', 'COV-AUTO-002', 'replacement', 7855.82);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000048-001', 'CLM-2026-000048', 'COV-HLTH-002', 'hospital_stay', 4250.32);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000049-001', 'CLM-2026-000049', 'COV-HOME-001', 'repair', 5224.44);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000049-002', 'CLM-2026-000049', 'COV-HOME-001', 'replacement', 16326.52);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000050-001', 'CLM-2026-000050', 'COV-TRVL-003', 'medical_treatment', 951.60);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000050-002', 'CLM-2026-000050', 'COV-TRVL-003', 'hospital_stay', 1132.48);
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000001-001', 'CLM-2026-000001', 'photo', '2024-05-18', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000001-002', 'CLM-2026-000001', 'repair_estimate', '2024-05-19', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000001-003', 'CLM-2026-000001', 'proof_of_ownership', '2024-05-18', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000002-001', 'CLM-2026-000002', 'photo', '2024-05-25', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000002-002', 'CLM-2026-000002', 'repair_estimate', '2024-05-24', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000003-001', 'CLM-2026-000003', 'photo', '2024-09-12', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000003-002', 'CLM-2026-000003', 'repair_estimate', '2024-09-13', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000003-003', 'CLM-2026-000003', 'proof_of_ownership', '2024-09-15', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000004-001', 'CLM-2026-000004', 'photo', '2024-09-24', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000004-002', 'CLM-2026-000004', 'repair_estimate', '2024-09-25', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000004-003', 'CLM-2026-000004', 'proof_of_ownership', '2024-09-24', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000005-001', 'CLM-2026-000005', 'itinerary', '2024-11-13', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000005-002', 'CLM-2026-000005', 'invoice', '2024-11-13', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000006-001', 'CLM-2026-000006', 'photo', '2025-02-12', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000006-002', 'CLM-2026-000006', 'repair_estimate', '2025-02-13', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000006-003', 'CLM-2026-000006', 'proof_of_ownership', '2025-02-10', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000007-001', 'CLM-2026-000007', 'photo', '2025-05-24', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000007-002', 'CLM-2026-000007', 'police_report', '2025-05-25', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000007-003', 'CLM-2026-000007', 'repair_estimate', '2025-05-25', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000008-001', 'CLM-2026-000008', 'incident_statement', '2025-06-09', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000008-002', 'CLM-2026-000008', 'police_report', '2025-06-07', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000009-001', 'CLM-2026-000009', 'incident_statement', '2025-06-14', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000009-002', 'CLM-2026-000009', 'police_report', '2025-06-12', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000010-001', 'CLM-2026-000010', 'photo', '2025-07-14', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000010-002', 'CLM-2026-000010', 'police_report', '2025-07-15', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000011-001', 'CLM-2026-000011', 'photo', '2025-07-17', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000011-002', 'CLM-2026-000011', 'police_report', '2025-07-18', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000012-001', 'CLM-2026-000012', 'photo', '2025-10-24', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000012-002', 'CLM-2026-000012', 'police_report', '2025-10-26', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000013-001', 'CLM-2026-000013', 'incident_statement', '2025-12-22', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000013-002', 'CLM-2026-000013', 'police_report', '2025-12-24', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000014-001', 'CLM-2026-000014', 'photo', '2026-01-03', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000014-002', 'CLM-2026-000014', 'repair_estimate', '2026-01-06', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000014-003', 'CLM-2026-000014', 'proof_of_ownership', '2026-01-03', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000015-001', 'CLM-2026-000015', 'photo', '2026-01-26', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000015-002', 'CLM-2026-000015', 'police_report', '2026-01-26', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000016-001', 'CLM-2026-000016', 'photo', '2026-02-03', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000016-002', 'CLM-2026-000016', 'repair_estimate', '2026-02-03', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000017-001', 'CLM-2026-000017', 'photo', '2026-03-20', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000017-002', 'CLM-2026-000017', 'police_report', '2026-03-23', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000017-003', 'CLM-2026-000017', 'repair_estimate', '2026-03-21', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000018-001', 'CLM-2026-000018', 'photo', '2026-03-29', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000018-002', 'CLM-2026-000018', 'repair_estimate', '2026-03-28', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000018-003', 'CLM-2026-000018', 'proof_of_ownership', '2026-03-26', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000019-001', 'CLM-2026-000019', 'photo', '2026-04-08', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000019-002', 'CLM-2026-000019', 'police_report', '2026-04-09', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000019-003', 'CLM-2026-000019', 'repair_estimate', '2026-04-08', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000020-001', 'CLM-2026-000020', 'photo', '2026-05-15', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000020-002', 'CLM-2026-000020', 'repair_estimate', '2026-05-07', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000020-003', 'CLM-2026-000020', 'proof_of_ownership', '2026-05-08', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000021-001', 'CLM-2026-000021', 'photo', '2026-05-09', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000021-002', 'CLM-2026-000021', 'repair_estimate', '2026-05-09', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000022-001', 'CLM-2026-000022', 'incident_statement', '2026-05-27', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000022-002', 'CLM-2026-000022', 'police_report', '2026-05-27', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000023-001', 'CLM-2026-000023', 'photo', '2026-06-10', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000023-002', 'CLM-2026-000023', 'police_report', '2026-06-09', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000023-003', 'CLM-2026-000023', 'repair_estimate', '2026-06-11', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000024-001', 'CLM-2026-000024', 'photo', '2026-06-24', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000024-002', 'CLM-2026-000024', 'repair_estimate', '2026-06-21', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000025-001', 'CLM-2026-000025', 'photo', '2026-07-01', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000025-002', 'CLM-2026-000025', 'repair_estimate', '2026-07-02', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000025-003', 'CLM-2026-000025', 'proof_of_ownership', '2026-07-02', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000026-001', 'CLM-2026-000026', 'medical_report', '2026-07-21', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000027-001', 'CLM-2026-000027', 'photo', '2026-07-23', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000027-002', 'CLM-2026-000027', 'proof_of_ownership', '2026-07-20', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000028-001', 'CLM-2026-000028', 'photo', '2026-07-25', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000028-002', 'CLM-2026-000028', 'repair_estimate', '2026-07-24', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000028-003', 'CLM-2026-000028', 'proof_of_ownership', '2026-07-26', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000029-001', 'CLM-2026-000029', 'photo', '2026-07-25', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000029-002', 'CLM-2026-000029', 'repair_estimate', '2026-08-07', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000030-001', 'CLM-2026-000030', 'photo', '2026-08-08', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000030-002', 'CLM-2026-000030', 'police_report', '2026-08-11', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000030-003', 'CLM-2026-000030', 'repair_estimate', '2026-08-10', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000031-001', 'CLM-2026-000031', 'photo', '2026-08-24', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000031-002', 'CLM-2026-000031', 'repair_estimate', '2026-08-25', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000031-003', 'CLM-2026-000031', 'proof_of_ownership', '2026-08-26', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000032-001', 'CLM-2026-000032', 'photo', '2026-08-29', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000032-002', 'CLM-2026-000032', 'police_report', '2026-08-30', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000033-001', 'CLM-2026-000033', 'medical_report', '2026-09-05', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000033-002', 'CLM-2026-000033', 'invoice', '2026-09-04', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000034-001', 'CLM-2026-000034', 'incident_statement', '2026-09-07', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000034-002', 'CLM-2026-000034', 'police_report', '2026-09-08', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000035-001', 'CLM-2026-000035', 'photo', '2026-09-11', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000035-002', 'CLM-2026-000035', 'police_report', '2026-09-08', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000036-001', 'CLM-2026-000036', 'photo', '2026-09-11', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000036-002', 'CLM-2026-000036', 'police_report', '2026-09-12', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000037-001', 'CLM-2026-000037', 'itinerary', '2026-09-09', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000037-002', 'CLM-2026-000037', 'invoice', '2026-09-11', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000038-001', 'CLM-2026-000038', 'photo', '2026-09-11', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000038-002', 'CLM-2026-000038', 'repair_estimate', '2026-09-11', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000039-001', 'CLM-2026-000039', 'photo', '2026-10-02', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000039-002', 'CLM-2026-000039', 'repair_estimate', '2026-09-30', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000040-001', 'CLM-2026-000040', 'photo', '2026-10-06', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000040-002', 'CLM-2026-000040', 'police_report', '2026-10-03', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000041-001', 'CLM-2026-000041', 'photo', '2026-10-05', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000041-002', 'CLM-2026-000041', 'police_report', '2026-10-06', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000042-001', 'CLM-2026-000042', 'photo', '2026-10-06', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000042-002', 'CLM-2026-000042', 'police_report', '2026-10-05', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000043-001', 'CLM-2026-000043', 'photo', '2026-10-04', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000043-002', 'CLM-2026-000043', 'police_report', '2026-10-04', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000044-001', 'CLM-2026-000044', 'photo', '2026-10-11', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000044-002', 'CLM-2026-000044', 'police_report', '2026-10-12', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000044-003', 'CLM-2026-000044', 'repair_estimate', '2026-10-10', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000045-001', 'CLM-2026-000045', 'photo', '2026-10-14', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000046-001', 'CLM-2026-000046', 'incident_statement', '2026-10-13', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000046-002', 'CLM-2026-000046', 'police_report', '2026-10-12', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000047-001', 'CLM-2026-000047', 'photo', '2026-10-22', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000047-002', 'CLM-2026-000047', 'police_report', '2026-10-22', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000048-001', 'CLM-2026-000048', 'medical_report', '2026-10-22', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000048-002', 'CLM-2026-000048', 'invoice', '2026-10-22', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000049-001', 'CLM-2026-000049', 'photo', '2026-10-22', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000049-002', 'CLM-2026-000049', 'repair_estimate', '2026-10-22', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000050-001', 'CLM-2026-000050', 'itinerary', '2026-10-22', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000050-002', 'CLM-2026-000050', 'invoice', '2026-10-22', 'received');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000001-001', 'CLM-2026-000001', 'ADJ-002', '2024-05-17', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000002-001', 'CLM-2026-000002', 'ADJ-007', '2024-05-23', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000003-001', 'CLM-2026-000003', 'ADJ-007', '2024-09-12', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000004-001', 'CLM-2026-000004', 'ADJ-007', '2024-09-23', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000005-001', 'CLM-2026-000005', 'ADJ-009', '2024-11-12', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000006-001', 'CLM-2026-000006', 'ADJ-002', '2025-02-10', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000007-001', 'CLM-2026-000007', 'ADJ-006', '2025-05-23', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000008-001', 'CLM-2026-000008', 'ADJ-010', '2025-06-06', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000009-001', 'CLM-2026-000009', 'ADJ-010', '2025-06-11', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000010-001', 'CLM-2026-000010', 'ADJ-006', '2025-07-12', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000011-001', 'CLM-2026-000011', 'ADJ-006', '2025-07-15', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000012-001', 'CLM-2026-000012', 'ADJ-006', '2025-10-24', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000013-001', 'CLM-2026-000013', 'ADJ-010', '2025-12-22', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000014-001', 'CLM-2026-000014', 'ADJ-002', '2026-01-03', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000015-001', 'CLM-2026-000015', 'ADJ-006', '2026-01-24', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000016-001', 'CLM-2026-000016', 'ADJ-007', '2026-02-03', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000017-001', 'CLM-2026-000017', 'ADJ-006', '2026-03-20', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000018-001', 'CLM-2026-000018', 'ADJ-007', '2026-03-26', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000019-001', 'CLM-2026-000019', 'ADJ-006', '2026-04-06', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000020-001', 'CLM-2026-000020', 'ADJ-007', '2026-05-05', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000021-001', 'CLM-2026-000021', 'ADJ-002', '2026-05-07', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000022-001', 'CLM-2026-000022', 'ADJ-010', '2026-05-24', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000023-001', 'CLM-2026-000023', 'ADJ-001', '2026-06-08', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000024-001', 'CLM-2026-000024', 'ADJ-007', '2026-06-21', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000025-001', 'CLM-2026-000025', 'ADJ-002', '2026-07-01', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000026-001', 'CLM-2026-000026', 'ADJ-008', '2026-07-20', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000027-001', 'CLM-2026-000027', 'ADJ-002', '2026-07-20', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000028-001', 'CLM-2026-000028', 'ADJ-002', '2026-07-24', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000029-001', 'CLM-2026-000029', 'ADJ-002', '2026-07-24', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000030-001', 'CLM-2026-000030', 'ADJ-006', '2026-08-08', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000031-001', 'CLM-2026-000031', 'ADJ-002', '2026-08-23', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000032-001', 'CLM-2026-000032', 'ADJ-006', '2026-08-29', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000033-001', 'CLM-2026-000033', 'ADJ-003', '2026-09-03', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000034-001', 'CLM-2026-000034', 'ADJ-010', '2026-09-05', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000035-001', 'CLM-2026-000035', 'ADJ-001', '2026-09-08', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000036-001', 'CLM-2026-000036', 'ADJ-001', '2026-09-09', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000037-001', 'CLM-2026-000037', 'ADJ-004', '2026-09-09', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000038-001', 'CLM-2026-000038', 'ADJ-007', '2026-09-09', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000039-001', 'CLM-2026-000039', 'ADJ-002', '2026-09-30', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000040-001', 'CLM-2026-000040', 'ADJ-001', '2026-10-03', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000041-001', 'CLM-2026-000041', 'ADJ-006', '2026-10-04', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000042-001', 'CLM-2026-000042', 'ADJ-001', '2026-10-04', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000043-001', 'CLM-2026-000043', 'ADJ-006', '2026-10-04', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000044-001', 'CLM-2026-000044', 'ADJ-006', '2026-10-09', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000045-001', 'CLM-2026-000045', 'ADJ-006', '2026-10-11', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000046-001', 'CLM-2026-000046', 'ADJ-005', '2026-10-11', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000047-001', 'CLM-2026-000047', 'ADJ-006', '2026-10-22', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000048-001', 'CLM-2026-000048', 'ADJ-008', '2026-10-22', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000049-001', 'CLM-2026-000049', 'ADJ-007', '2026-10-22', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000050-001', 'CLM-2026-000050', 'ADJ-009', '2026-10-22', 'initial');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000001-001', 'CLM-2026-000001', 'ADJ-002', '2024-05-20', 'approve', 'R-PAY-01', 'eligible', 6681.75, 500.00, 6181.75, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000002-001', 'CLM-2026-000002', 'ADJ-007', '2024-05-26', 'approve', 'R-PAY-01', 'eligible', 10800.75, 2000.00, 8800.75, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000003-001', 'CLM-2026-000003', 'ADJ-007', '2024-09-15', 'approve', 'R-PAY-01', 'eligible', 3597.31, 2000.00, 1597.31, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000004-001', 'CLM-2026-000004', 'ADJ-007', '2024-09-25', 'deny', 'R-COV-02', 'policy_not_in_force', 0.00, 0.00, 0.00, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000005-001', 'CLM-2026-000005', 'ADJ-009', '2024-11-16', 'approve', 'R-PAY-01', 'eligible', 350.15, 100.00, 250.15, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000006-001', 'CLM-2026-000006', 'ADJ-002', '2025-02-13', 'approve', 'R-PAY-01', 'eligible', 8888.95, 2000.00, 6888.95, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000007-001', 'CLM-2026-000007', 'ADJ-006', '2025-05-25', 'approve', 'R-PAY-01', 'eligible', 2112.42, 0.00, 2112.42, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000008-001', 'CLM-2026-000008', 'ADJ-010', '2025-06-10', 'approve', 'R-PAY-01', 'eligible', 7645.75, 2000.00, 5645.75, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000009-001', 'CLM-2026-000009', 'ADJ-010', '2025-06-14', 'refer_review', 'R-ELG-03', 'duplicate_claim', 0.00, 0.00, 0.00, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000010-001', 'CLM-2026-000010', 'ADJ-006', '2025-07-16', 'approve', 'R-PAY-01', 'eligible', 751.05, 0.00, 751.05, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000011-001', 'CLM-2026-000011', 'ADJ-006', '2025-07-18', 'refer_review', 'R-ELG-03', 'duplicate_claim', 0.00, 0.00, 0.00, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000012-001', 'CLM-2026-000012', 'ADJ-006', '2025-10-26', 'approve', 'R-PAY-01', 'eligible', 13281.49, 500.00, 12781.49, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000013-001', 'CLM-2026-000013', 'ADJ-010', '2025-12-24', 'approve', 'R-PAY-01', 'eligible', 17076.07, 2000.00, 15076.07, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000014-001', 'CLM-2026-000014', 'ADJ-002', '2026-01-08', 'approve', 'R-PAY-01', 'eligible', 8118.15, 2000.00, 6118.15, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000015-001', 'CLM-2026-000015', 'ADJ-006', '2026-01-29', 'approve', 'R-PAY-01', 'eligible', 6655.51, 1000.00, 5655.51, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000016-001', 'CLM-2026-000016', 'ADJ-007', '2026-02-05', 'deny', 'R-COV-03', 'outside_coverage_period', 0.00, 0.00, 0.00, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000017-001', 'CLM-2026-000017', 'ADJ-006', '2026-03-23', 'approve', 'R-PAY-01', 'eligible', 5730.46, 0.00, 5730.46, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000018-001', 'CLM-2026-000018', 'ADJ-007', '2026-03-31', 'refer_review', 'R-FRD-05', 'suspected_fraud', 0.00, 0.00, 0.00, 0.50);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000019-001', 'CLM-2026-000019', 'ADJ-006', '2026-04-10', 'approve', 'R-PAY-01', 'eligible', 5341.04, 500.00, 4841.04, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000020-001', 'CLM-2026-000020', 'ADJ-007', '2026-05-09', 'pend_docs', 'R-DOC-01', 'missing_document', 0.00, 0.00, 0.00, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000020-002', 'CLM-2026-000020', 'ADJ-007', '2026-05-15', 'approve', 'R-PAY-01', 'eligible', 11771.54, 500.00, 11271.54, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000021-001', 'CLM-2026-000021', 'ADJ-002', '2026-05-12', 'approve', 'R-PAY-01', 'eligible', 50000.00, 2000.00, 48000.00, 0.25);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000022-001', 'CLM-2026-000022', 'ADJ-010', '2026-05-27', 'deny', 'R-PAY-01', 'within_deductible', 2000.00, 2000.00, 0.00, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000023-001', 'CLM-2026-000023', 'ADJ-001', '2026-06-13', 'approve', 'R-PAY-01', 'eligible', 5400.00, 500.00, 4900.00, 0.25);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000024-001', 'CLM-2026-000024', 'ADJ-007', '2026-06-26', 'approve', 'R-PAY-01', 'eligible', 8161.14, 2000.00, 6161.14, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000025-001', 'CLM-2026-000025', 'ADJ-002', '2026-07-05', 'approve', 'R-PAY-01', 'eligible', 5802.32, 500.00, 5302.32, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000026-001', 'CLM-2026-000026', 'ADJ-008', '2026-07-23', 'pend_docs', 'R-DOC-01', 'missing_document', 0.00, 0.00, 0.00, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000027-001', 'CLM-2026-000027', 'ADJ-002', '2026-07-23', 'pend_docs', 'R-DOC-01', 'missing_document', 0.00, 0.00, 0.00, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000028-001', 'CLM-2026-000028', 'ADJ-002', '2026-07-29', 'deny', 'R-COV-02', 'policy_not_in_force', 0.00, 0.00, 0.00, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000029-001', 'CLM-2026-000029', 'ADJ-002', '2026-07-27', 'pend_docs', 'R-DOC-01', 'missing_document', 0.00, 0.00, 0.00, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000029-002', 'CLM-2026-000029', 'ADJ-002', '2026-08-07', 'approve', 'R-PAY-01', 'eligible', 1442.38, 1000.00, 442.38, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000030-001', 'CLM-2026-000030', 'ADJ-006', '2026-08-11', 'deny', 'R-COV-01', 'before_policy_start', 0.00, 0.00, 0.00, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000031-001', 'CLM-2026-000031', 'ADJ-002', '2026-08-28', 'approve', 'R-PAY-01', 'eligible', 23447.90, 1000.00, 22447.90, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000032-001', 'CLM-2026-000032', 'ADJ-006', '2026-08-30', 'approve', 'R-PAY-01', 'eligible', 1285.75, 0.00, 1285.75, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000033-001', 'CLM-2026-000033', 'ADJ-003', '2026-09-07', 'approve', 'R-PAY-01', 'eligible', 25044.49, 1000.00, 24044.49, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000034-001', 'CLM-2026-000034', 'ADJ-010', '2026-09-09', 'approve', 'R-PAY-01', 'eligible', 21745.62, 1000.00, 20745.62, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000035-001', 'CLM-2026-000035', 'ADJ-001', '2026-09-11', 'approve', 'R-PAY-01', 'eligible', 1807.59, 500.00, 1307.59, 0.25);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000036-001', 'CLM-2026-000036', 'ADJ-001', '2026-09-14', 'approve', 'R-PAY-01', 'eligible', 3312.42, 0.00, 3312.42, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000037-001', 'CLM-2026-000037', 'ADJ-004', '2026-09-11', 'deny', 'R-COV-02', 'policy_not_in_force', 0.00, 0.00, 0.00, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000038-001', 'CLM-2026-000038', 'ADJ-007', '2026-09-11', 'approve', 'R-PAY-01', 'limit_reached', 124790.38, 1000.00, 99557.62, 0.25);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000039-001', 'CLM-2026-000039', 'ADJ-002', '2026-10-02', 'approve', 'R-PAY-01', 'eligible', 3950.24, 2000.00, 1950.24, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000040-001', 'CLM-2026-000040', 'ADJ-001', '2026-10-06', 'approve', 'R-PAY-01', 'eligible', 7855.82, 1000.00, 6855.82, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000041-001', 'CLM-2026-000041', 'ADJ-006', '2026-10-08', 'approve', 'R-PAY-01', 'eligible', 576.74, 200.00, 376.74, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000042-001', 'CLM-2026-000042', 'ADJ-001', '2026-10-06', 'deny', 'R-COV-01', 'before_policy_start', 0.00, 0.00, 0.00, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000043-001', 'CLM-2026-000043', 'ADJ-006', '2026-10-07', 'deny', 'R-COV-02', 'policy_not_in_force', 0.00, 0.00, 0.00, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000044-001', 'CLM-2026-000044', 'ADJ-006', '2026-10-12', 'approve', 'R-PAY-01', 'eligible', 4541.39, 500.00, 4041.39, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000045-001', 'CLM-2026-000045', 'ADJ-006', '2026-10-14', 'pend_docs', 'R-DOC-01', 'missing_document', 0.00, 0.00, 0.00, 0.00);
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score) VALUES ('ASM-CLM-2026-000046-001', 'CLM-2026-000046', 'ADJ-005', '2026-10-16', 'approve', 'R-PAY-01', 'eligible', 8069.22, 1000.00, 7069.22, 0.00);
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000001-001', 'CLM-2026-000001', '2024-05-20', 6181.75, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000002-001', 'CLM-2026-000002', '2024-05-26', 8800.75, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000003-001', 'CLM-2026-000003', '2024-09-15', 1597.31, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000005-001', 'CLM-2026-000005', '2024-11-16', 250.15, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000006-001', 'CLM-2026-000006', '2025-02-13', 6888.95, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000007-001', 'CLM-2026-000007', '2025-05-25', 2112.42, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000008-001', 'CLM-2026-000008', '2025-06-10', 5645.75, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000010-001', 'CLM-2026-000010', '2025-07-16', 751.05, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000012-001', 'CLM-2026-000012', '2025-10-26', 12781.49, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000013-001', 'CLM-2026-000013', '2025-12-24', 15076.07, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000014-001', 'CLM-2026-000014', '2026-01-08', 6118.15, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000015-001', 'CLM-2026-000015', '2026-01-29', 5655.51, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000017-001', 'CLM-2026-000017', '2026-03-23', 5730.46, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000019-001', 'CLM-2026-000019', '2026-04-10', 4841.04, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000020-001', 'CLM-2026-000020', '2026-05-15', 11271.54, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000021-001', 'CLM-2026-000021', '2026-05-12', 48000.00, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000023-001', 'CLM-2026-000023', '2026-06-13', 4900.00, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000024-001', 'CLM-2026-000024', '2026-06-26', 6161.14, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000025-001', 'CLM-2026-000025', '2026-07-05', 5302.32, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000029-001', 'CLM-2026-000029', '2026-08-07', 442.38, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000031-001', 'CLM-2026-000031', '2026-08-28', 22447.90, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000032-001', 'CLM-2026-000032', '2026-08-30', 1285.75, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000033-001', 'CLM-2026-000033', '2026-09-07', 24044.49, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000034-001', 'CLM-2026-000034', '2026-09-09', 20745.62, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000035-001', 'CLM-2026-000035', '2026-09-11', 1307.59, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000036-001', 'CLM-2026-000036', '2026-09-14', 3312.42, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000038-001', 'CLM-2026-000038', '2026-09-11', 99557.62, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000039-001', 'CLM-2026-000039', '2026-10-02', 1950.24, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000040-001', 'CLM-2026-000040', '2026-10-06', 6855.82, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000041-001', 'CLM-2026-000041', '2026-10-08', 376.74, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000044-001', 'CLM-2026-000044', '2026-10-12', 4041.39, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000046-001', 'CLM-2026-000046', '2026-10-16', 7069.22, 'preliminary', 'R-RSV-01');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000001-001', 'CLM-2026-000001', 6181.75, '2024-05-20', 6181.75, '2024-05-21', 'process_owner', 6181.75, '2024-05-23');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000002-001', 'CLM-2026-000002', 8800.75, '2024-05-26', 8800.75, '2024-05-28', 'process_owner', 8800.75, '2024-05-29');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000003-001', 'CLM-2026-000003', 1597.31, '2024-09-15', 1597.31, '2024-09-18', 'process_owner', 1597.31, '2024-09-23');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000005-001', 'CLM-2026-000005', 250.15, '2024-11-16', 250.15, '2024-11-17', 'process_owner', 250.15, '2024-11-18');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000006-001', 'CLM-2026-000006', 6888.95, '2025-02-13', 6888.95, '2025-02-14', 'process_owner', 6888.95, '2025-02-15');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000007-001', 'CLM-2026-000007', 2112.42, '2025-05-25', 2112.42, '2025-05-27', 'process_owner', 2112.42, '2025-05-31');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000008-001', 'CLM-2026-000008', 5645.75, '2025-06-10', 5645.75, '2025-06-11', 'process_owner', 5645.75, '2025-06-13');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000010-001', 'CLM-2026-000010', 751.05, '2025-07-16', 751.05, '2025-07-19', 'process_owner', 751.05, '2025-07-22');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000012-001', 'CLM-2026-000012', 12781.49, '2025-10-26', 12781.49, '2025-10-28', 'approver', 12781.49, '2025-10-30');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000013-001', 'CLM-2026-000013', 15076.07, '2025-12-24', 15076.07, '2025-12-27', 'approver', 15076.07, '2025-12-29');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000014-001', 'CLM-2026-000014', 6118.15, '2026-01-08', 6118.15, '2026-01-11', 'process_owner', 6118.15, '2026-01-15');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000015-001', 'CLM-2026-000015', 5655.51, '2026-01-29', 5655.51, '2026-01-31', 'process_owner', 5655.51, '2026-02-05');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000017-001', 'CLM-2026-000017', 5730.46, '2026-03-23', 5730.46, '2026-03-25', 'process_owner', 5730.46, '2026-03-26');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000019-001', 'CLM-2026-000019', 4841.04, '2026-04-10', 4841.04, '2026-04-13', 'process_owner', 4841.04, '2026-04-18');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000020-001', 'CLM-2026-000020', 11271.54, '2026-05-15', 11271.54, '2026-05-16', 'approver', 11271.54, '2026-05-18');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000021-001', 'CLM-2026-000021', 48000.00, '2026-05-12', 48000.00, '2026-05-14', 'approver', 48000.00, '2026-05-16');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000023-001', 'CLM-2026-000023', 4900.00, '2026-06-13', 4900.00, '2026-06-16', 'process_owner', 4900.00, '2026-06-19');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000024-001', 'CLM-2026-000024', 6161.14, '2026-06-26', 6161.14, '2026-06-27', 'process_owner', 6161.14, '2026-06-29');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000024-002', 'CLM-2026-000024', 6161.14, '2026-06-26', 6161.14, '2026-06-27', 'process_owner', 6161.14, '2026-07-03');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000025-001', 'CLM-2026-000025', 5302.32, '2026-07-05', 5302.32, '2026-07-08', 'process_owner', 5302.32, '2026-07-12');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000029-001', 'CLM-2026-000029', 442.38, '2026-08-07', 442.38, '2026-08-10', 'process_owner', 442.38, '2026-08-11');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000031-001', 'CLM-2026-000031', 22447.90, '2026-08-28', 22447.90, '2026-08-29', 'approver', 22447.90, '2026-09-01');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000031-002', 'CLM-2026-000031', 22447.90, '2026-08-28', 22447.90, '2026-08-29', 'approver', 22447.90, '2026-09-02');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000032-001', 'CLM-2026-000032', 1285.75, '2026-08-30', 1285.75, '2026-09-02', 'process_owner', 1285.75, '2026-09-05');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000033-001', 'CLM-2026-000033', 164532.46, '2026-09-07', 164532.46, '2026-09-09', 'approver', 164532.46, '2026-09-11');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000034-001', 'CLM-2026-000034', 20745.62, '2026-09-09', 20745.62, '2026-09-10', 'approver', 20745.62, '2026-09-12');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000035-001', 'CLM-2026-000035', 1307.59, '2026-09-11', 1307.59, '2026-09-14', 'process_owner', 1307.59, '2026-09-16');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000036-001', 'CLM-2026-000036', 3312.42, '2026-09-14', 3312.42, '2026-09-17', 'process_owner', 3312.42, '2026-09-22');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000038-001', 'CLM-2026-000038', 99557.62, '2026-09-11', 99557.62, '2026-09-14', 'approver', 99557.62, '2026-09-15');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000039-001', 'CLM-2026-000039', 1950.24, '2026-10-02', 1950.24, '2026-10-04', 'process_owner', 1950.24, '2026-10-07');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000040-001', 'CLM-2026-000040', 6855.82, '2026-10-06', 6855.82, '2026-10-09', 'process_owner', 6855.82, '2026-10-14');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000041-001', 'CLM-2026-000041', 376.74, '2026-10-08', 376.74, '2026-10-09', 'process_owner', 376.74, '2026-10-10');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000044-001', 'CLM-2026-000044', 4041.39, '2026-10-12', 4041.39, '2026-10-13', 'process_owner', 4041.39, '2026-10-18');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000046-001', 'CLM-2026-000046', 139150.84, '2026-10-16', 139150.84, '2026-10-18', 'process_owner', 139150.84, '2026-10-19');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000001-001', 'CLM-2026-000001', '', 'submitted', '2024-05-17', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000001-002', 'CLM-2026-000001', 'submitted', 'assessed', '2024-05-20', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000001-003', 'CLM-2026-000001', 'assessed', 'approved', '2024-05-21', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000001-004', 'CLM-2026-000001', 'approved', 'paid', '2024-05-23', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000002-001', 'CLM-2026-000002', '', 'submitted', '2024-05-23', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000002-002', 'CLM-2026-000002', 'submitted', 'assessed', '2024-05-26', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000002-003', 'CLM-2026-000002', 'assessed', 'approved', '2024-05-28', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000002-004', 'CLM-2026-000002', 'approved', 'paid', '2024-05-29', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000003-001', 'CLM-2026-000003', '', 'submitted', '2024-09-12', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000003-002', 'CLM-2026-000003', 'submitted', 'assessed', '2024-09-15', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000003-003', 'CLM-2026-000003', 'assessed', 'approved', '2024-09-18', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000003-004', 'CLM-2026-000003', 'approved', 'paid', '2024-09-23', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000004-001', 'CLM-2026-000004', '', 'submitted', '2024-09-23', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000004-002', 'CLM-2026-000004', 'submitted', 'denied', '2024-09-25', 'operations_analyst', 'R-COV-02', 'policy_not_in_force');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000005-001', 'CLM-2026-000005', '', 'submitted', '2024-11-12', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000005-002', 'CLM-2026-000005', 'submitted', 'assessed', '2024-11-16', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000005-003', 'CLM-2026-000005', 'assessed', 'approved', '2024-11-17', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000005-004', 'CLM-2026-000005', 'approved', 'paid', '2024-11-18', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000006-001', 'CLM-2026-000006', '', 'submitted', '2025-02-10', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000006-002', 'CLM-2026-000006', 'submitted', 'assessed', '2025-02-13', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000006-003', 'CLM-2026-000006', 'assessed', 'approved', '2025-02-14', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000006-004', 'CLM-2026-000006', 'approved', 'paid', '2025-02-15', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000007-001', 'CLM-2026-000007', '', 'submitted', '2025-05-23', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000007-002', 'CLM-2026-000007', 'submitted', 'assessed', '2025-05-25', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000007-003', 'CLM-2026-000007', 'assessed', 'approved', '2025-05-27', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000007-004', 'CLM-2026-000007', 'approved', 'paid', '2025-05-31', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000008-001', 'CLM-2026-000008', '', 'submitted', '2025-06-06', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000008-002', 'CLM-2026-000008', 'submitted', 'assessed', '2025-06-10', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000008-003', 'CLM-2026-000008', 'assessed', 'approved', '2025-06-11', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000008-004', 'CLM-2026-000008', 'approved', 'paid', '2025-06-13', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000009-001', 'CLM-2026-000009', '', 'submitted', '2025-06-11', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000009-002', 'CLM-2026-000009', 'submitted', 'under_review', '2025-06-14', 'operations_analyst', 'R-ELG-03', 'duplicate_claim');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000010-001', 'CLM-2026-000010', '', 'submitted', '2025-07-12', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000010-002', 'CLM-2026-000010', 'submitted', 'assessed', '2025-07-16', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000010-003', 'CLM-2026-000010', 'assessed', 'approved', '2025-07-19', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000010-004', 'CLM-2026-000010', 'approved', 'paid', '2025-07-22', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000011-001', 'CLM-2026-000011', '', 'submitted', '2025-07-15', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000011-002', 'CLM-2026-000011', 'submitted', 'under_review', '2025-07-18', 'operations_analyst', 'R-ELG-03', 'duplicate_claim');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000012-001', 'CLM-2026-000012', '', 'submitted', '2025-10-24', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000012-002', 'CLM-2026-000012', 'submitted', 'assessed', '2025-10-26', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000012-003', 'CLM-2026-000012', 'assessed', 'approved', '2025-10-28', 'approver', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000012-004', 'CLM-2026-000012', 'approved', 'paid', '2025-10-30', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000013-001', 'CLM-2026-000013', '', 'submitted', '2025-12-22', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000013-002', 'CLM-2026-000013', 'submitted', 'assessed', '2025-12-24', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000013-003', 'CLM-2026-000013', 'assessed', 'approved', '2025-12-27', 'approver', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000013-004', 'CLM-2026-000013', 'approved', 'paid', '2025-12-29', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000014-001', 'CLM-2026-000014', '', 'submitted', '2026-01-03', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000014-002', 'CLM-2026-000014', 'submitted', 'assessed', '2026-01-08', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000014-003', 'CLM-2026-000014', 'assessed', 'approved', '2026-01-11', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000014-004', 'CLM-2026-000014', 'approved', 'paid', '2026-01-15', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000015-001', 'CLM-2026-000015', '', 'submitted', '2026-01-24', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000015-002', 'CLM-2026-000015', 'submitted', 'assessed', '2026-01-29', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000015-003', 'CLM-2026-000015', 'assessed', 'approved', '2026-01-31', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000015-004', 'CLM-2026-000015', 'approved', 'paid', '2026-02-05', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000016-001', 'CLM-2026-000016', '', 'submitted', '2026-02-03', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000016-002', 'CLM-2026-000016', 'submitted', 'denied', '2026-02-05', 'operations_analyst', 'R-COV-03', 'outside_coverage_period');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000017-001', 'CLM-2026-000017', '', 'submitted', '2026-03-20', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000017-002', 'CLM-2026-000017', 'submitted', 'assessed', '2026-03-23', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000017-003', 'CLM-2026-000017', 'assessed', 'approved', '2026-03-25', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000017-004', 'CLM-2026-000017', 'approved', 'paid', '2026-03-26', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000018-001', 'CLM-2026-000018', '', 'submitted', '2026-03-26', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000018-002', 'CLM-2026-000018', 'submitted', 'under_review', '2026-03-31', 'operations_analyst', 'R-FRD-05', 'suspected_fraud');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000019-001', 'CLM-2026-000019', '', 'submitted', '2026-04-06', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000019-002', 'CLM-2026-000019', 'submitted', 'assessed', '2026-04-10', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000019-003', 'CLM-2026-000019', 'assessed', 'approved', '2026-04-13', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000019-004', 'CLM-2026-000019', 'approved', 'paid', '2026-04-18', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000020-001', 'CLM-2026-000020', '', 'submitted', '2026-05-05', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000020-002', 'CLM-2026-000020', 'submitted', 'docs_pending', '2026-05-09', 'operations_analyst', 'R-DOC-01', 'missing_document');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000020-003', 'CLM-2026-000020', 'docs_pending', 'assessed', '2026-05-15', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000020-004', 'CLM-2026-000020', 'assessed', 'approved', '2026-05-16', 'approver', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000020-005', 'CLM-2026-000020', 'approved', 'paid', '2026-05-18', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000021-001', 'CLM-2026-000021', '', 'submitted', '2026-05-07', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000021-002', 'CLM-2026-000021', 'submitted', 'assessed', '2026-05-12', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000021-003', 'CLM-2026-000021', 'assessed', 'approved', '2026-05-14', 'approver', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000021-004', 'CLM-2026-000021', 'approved', 'paid', '2026-05-16', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000022-001', 'CLM-2026-000022', '', 'submitted', '2026-05-24', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000022-002', 'CLM-2026-000022', 'submitted', 'denied', '2026-05-27', 'operations_analyst', 'R-PAY-01', 'within_deductible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000023-001', 'CLM-2026-000023', '', 'submitted', '2026-06-08', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000023-002', 'CLM-2026-000023', 'submitted', 'assessed', '2026-06-13', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000023-003', 'CLM-2026-000023', 'assessed', 'approved', '2026-06-16', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000023-004', 'CLM-2026-000023', 'approved', 'paid', '2026-06-19', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000024-001', 'CLM-2026-000024', '', 'submitted', '2026-06-21', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000024-002', 'CLM-2026-000024', 'submitted', 'assessed', '2026-06-26', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000024-003', 'CLM-2026-000024', 'assessed', 'approved', '2026-06-27', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000024-004', 'CLM-2026-000024', 'approved', 'paid', '2026-06-29', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000025-001', 'CLM-2026-000025', '', 'submitted', '2026-07-01', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000025-002', 'CLM-2026-000025', 'submitted', 'assessed', '2026-07-05', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000025-003', 'CLM-2026-000025', 'assessed', 'approved', '2026-07-08', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000025-004', 'CLM-2026-000025', 'approved', 'paid', '2026-07-12', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000026-001', 'CLM-2026-000026', '', 'submitted', '2026-07-20', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000026-002', 'CLM-2026-000026', 'submitted', 'docs_pending', '2026-07-23', 'operations_analyst', 'R-DOC-01', 'missing_document');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000027-001', 'CLM-2026-000027', '', 'submitted', '2026-07-20', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000027-002', 'CLM-2026-000027', 'submitted', 'docs_pending', '2026-07-23', 'operations_analyst', 'R-DOC-01', 'missing_document');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000028-001', 'CLM-2026-000028', '', 'submitted', '2026-07-24', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000028-002', 'CLM-2026-000028', 'submitted', 'denied', '2026-07-29', 'operations_analyst', 'R-COV-02', 'policy_not_in_force');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000029-001', 'CLM-2026-000029', '', 'submitted', '2026-07-24', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000029-002', 'CLM-2026-000029', 'submitted', 'docs_pending', '2026-07-27', 'operations_analyst', 'R-DOC-01', 'missing_document');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000029-003', 'CLM-2026-000029', 'docs_pending', 'assessed', '2026-08-07', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000029-004', 'CLM-2026-000029', 'assessed', 'approved', '2026-08-10', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000029-005', 'CLM-2026-000029', 'approved', 'paid', '2026-08-11', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000030-001', 'CLM-2026-000030', '', 'submitted', '2026-08-08', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000030-002', 'CLM-2026-000030', 'submitted', 'denied', '2026-08-11', 'operations_analyst', 'R-COV-01', 'before_policy_start');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000031-001', 'CLM-2026-000031', '', 'submitted', '2026-08-23', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000031-002', 'CLM-2026-000031', 'submitted', 'assessed', '2026-08-28', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000031-003', 'CLM-2026-000031', 'assessed', 'approved', '2026-08-29', 'approver', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000031-004', 'CLM-2026-000031', 'approved', 'paid', '2026-09-01', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000032-001', 'CLM-2026-000032', '', 'submitted', '2026-08-29', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000032-002', 'CLM-2026-000032', 'submitted', 'assessed', '2026-08-30', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000032-003', 'CLM-2026-000032', 'assessed', 'approved', '2026-09-02', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000032-004', 'CLM-2026-000032', 'approved', 'paid', '2026-09-05', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000033-001', 'CLM-2026-000033', '', 'submitted', '2026-09-03', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000033-002', 'CLM-2026-000033', 'submitted', 'assessed', '2026-09-07', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000033-003', 'CLM-2026-000033', 'assessed', 'approved', '2026-09-09', 'approver', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000033-004', 'CLM-2026-000033', 'approved', 'paid', '2026-09-11', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000034-001', 'CLM-2026-000034', '', 'submitted', '2026-09-05', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000034-002', 'CLM-2026-000034', 'submitted', 'assessed', '2026-09-09', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000034-003', 'CLM-2026-000034', 'assessed', 'approved', '2026-09-10', 'approver', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000034-004', 'CLM-2026-000034', 'approved', 'paid', '2026-09-12', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000035-001', 'CLM-2026-000035', '', 'submitted', '2026-09-08', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000035-002', 'CLM-2026-000035', 'submitted', 'assessed', '2026-09-11', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000035-003', 'CLM-2026-000035', 'assessed', 'approved', '2026-09-14', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000035-004', 'CLM-2026-000035', 'approved', 'paid', '2026-09-16', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000036-001', 'CLM-2026-000036', '', 'submitted', '2026-09-09', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000036-002', 'CLM-2026-000036', 'submitted', 'assessed', '2026-09-14', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000036-003', 'CLM-2026-000036', 'assessed', 'approved', '2026-09-17', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000036-004', 'CLM-2026-000036', 'approved', 'paid', '2026-09-22', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000037-001', 'CLM-2026-000037', '', 'submitted', '2026-09-09', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000037-002', 'CLM-2026-000037', 'submitted', 'denied', '2026-09-11', 'operations_analyst', 'R-COV-02', 'policy_not_in_force');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000038-001', 'CLM-2026-000038', '', 'submitted', '2026-09-09', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000038-002', 'CLM-2026-000038', 'submitted', 'assessed', '2026-09-11', 'operations_analyst', 'R-PAY-01', 'limit_reached');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000038-003', 'CLM-2026-000038', 'assessed', 'approved', '2026-09-14', 'approver', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000038-004', 'CLM-2026-000038', 'approved', 'paid', '2026-09-15', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000039-001', 'CLM-2026-000039', '', 'submitted', '2026-09-30', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000039-002', 'CLM-2026-000039', 'submitted', 'assessed', '2026-10-02', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000039-003', 'CLM-2026-000039', 'assessed', 'approved', '2026-10-04', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000039-004', 'CLM-2026-000039', 'approved', 'paid', '2026-10-07', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000040-001', 'CLM-2026-000040', '', 'submitted', '2026-10-03', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000040-002', 'CLM-2026-000040', 'submitted', 'assessed', '2026-10-06', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000040-003', 'CLM-2026-000040', 'assessed', 'approved', '2026-10-09', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000040-004', 'CLM-2026-000040', 'approved', 'paid', '2026-10-14', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000041-001', 'CLM-2026-000041', '', 'submitted', '2026-10-04', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000041-002', 'CLM-2026-000041', 'submitted', 'assessed', '2026-10-08', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000041-003', 'CLM-2026-000041', 'assessed', 'approved', '2026-10-09', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000041-004', 'CLM-2026-000041', 'approved', 'paid', '2026-10-10', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000042-001', 'CLM-2026-000042', '', 'submitted', '2026-10-04', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000042-002', 'CLM-2026-000042', 'submitted', 'denied', '2026-10-06', 'operations_analyst', 'R-COV-01', 'before_policy_start');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000043-001', 'CLM-2026-000043', '', 'submitted', '2026-10-04', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000043-002', 'CLM-2026-000043', 'submitted', 'denied', '2026-10-07', 'operations_analyst', 'R-COV-02', 'policy_not_in_force');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000044-001', 'CLM-2026-000044', '', 'submitted', '2026-10-09', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000044-002', 'CLM-2026-000044', 'submitted', 'assessed', '2026-10-12', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000044-003', 'CLM-2026-000044', 'assessed', 'approved', '2026-10-13', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000044-004', 'CLM-2026-000044', 'approved', 'paid', '2026-10-18', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000045-001', 'CLM-2026-000045', '', 'submitted', '2026-10-11', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000045-002', 'CLM-2026-000045', 'submitted', 'docs_pending', '2026-10-14', 'operations_analyst', 'R-DOC-01', 'missing_document');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000046-001', 'CLM-2026-000046', '', 'submitted', '2026-10-11', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000046-002', 'CLM-2026-000046', 'submitted', 'assessed', '2026-10-16', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000046-003', 'CLM-2026-000046', 'assessed', 'approved', '2026-10-18', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000046-004', 'CLM-2026-000046', 'approved', 'paid', '2026-10-19', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000047-001', 'CLM-2026-000047', '', 'submitted', '2026-10-22', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000048-001', 'CLM-2026-000048', '', 'submitted', '2026-10-22', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000049-001', 'CLM-2026-000049', '', 'submitted', '2026-10-22', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000050-001', 'CLM-2026-000050', '', 'submitted', '2026-10-22', 'requester', '', 'submitted');
COMMIT;
