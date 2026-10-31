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
  covered_incident_types TEXT NOT NULL,
  covered_item_types TEXT NOT NULL,
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
  missing_doc_types TEXT,
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
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes, covered_incident_types, covered_item_types) VALUES ('COV-AUTO-001', 'AUTO', 'Collision', 25000.00, 500.00, 'cosmetic', 'collision', 'repair|towing|cosmetic');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes, covered_incident_types, covered_item_types) VALUES ('COV-AUTO-002', 'AUTO', 'Theft', 30000.00, 500.00, '', 'theft', 'replacement');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes, covered_incident_types, covered_item_types) VALUES ('COV-AUTO-003', 'AUTO', 'Third-party liability', 50000.00, 0.00, '', 'third_party_property', 'liability_payment');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes, covered_incident_types, covered_item_types) VALUES ('COV-AUTO-004', 'AUTO', 'Towing and rental', 3000.00, 100.00, '', 'collision', 'towing|rental_car');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes, covered_incident_types, covered_item_types) VALUES ('COV-HOME-001', 'HOME', 'Fire', 200000.00, 1000.00, 'cosmetic', 'fire', 'repair|replacement|cosmetic');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes, covered_incident_types, covered_item_types) VALUES ('COV-HOME-002', 'HOME', 'Water damage', 50000.00, 1000.00, '', 'water_damage', 'repair|replacement');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes, covered_incident_types, covered_item_types) VALUES ('COV-HOME-003', 'HOME', 'Burglary', 30000.00, 500.00, '', 'burglary', 'replacement');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes, covered_incident_types, covered_item_types) VALUES ('COV-HOME-004', 'HOME', 'Contents', 40000.00, 500.00, 'cosmetic', 'fire|burglary|water_damage', 'replacement|cosmetic');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes, covered_incident_types, covered_item_types) VALUES ('COV-HLTH-001', 'HLTH', 'Outpatient', 10000.00, 250.00, 'cosmetic', 'illness|injury', 'medical_treatment|cosmetic');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes, covered_incident_types, covered_item_types) VALUES ('COV-HLTH-002', 'HLTH', 'Hospital stay', 100000.00, 1000.00, 'cosmetic', 'illness|injury', 'hospital_stay');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes, covered_incident_types, covered_item_types) VALUES ('COV-HLTH-003', 'HLTH', 'Emergency care', 50000.00, 500.00, '', 'injury|illness', 'medical_treatment|hospital_stay');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes, covered_incident_types, covered_item_types) VALUES ('COV-TRVL-001', 'TRVL', 'Trip cancellation', 8000.00, 100.00, '', 'trip_cancellation', 'cancellation_fee');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes, covered_incident_types, covered_item_types) VALUES ('COV-TRVL-002', 'TRVL', 'Baggage loss', 3000.00, 50.00, '', 'baggage_loss', 'baggage');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes, covered_incident_types, covered_item_types) VALUES ('COV-TRVL-003', 'TRVL', 'Medical abroad', 50000.00, 250.00, '', 'illness|injury', 'medical_treatment|hospital_stay');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes, covered_incident_types, covered_item_types) VALUES ('COV-LIAB-001', 'LIAB', 'Third-party injury', 100000.00, 1000.00, '', 'third_party_injury', 'liability_payment|medical_treatment');
INSERT INTO coverage (coverage_id, product, name, default_limit, default_deductible, exclusion_codes, covered_incident_types, covered_item_types) VALUES ('COV-LIAB-002', 'LIAB', 'Third-party property', 75000.00, 1000.00, '', 'third_party_property', 'liability_payment|repair');
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
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-AUTO-2026-000017-002', 'POL-AUTO-2026-000017', 'cancelled', '2026-07-11');
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
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000064-001', 'POL-HOME-2026-000064', 'issued', '2026-07-08');
INSERT INTO policy_event (event_id, policy_id, event_type, event_date) VALUES ('PEV-POL-HOME-2026-000064-002', 'POL-HOME-2026-000064', 'cancelled', '2026-09-19');
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
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000001', 'POL-HOME-2026-000002', '2024-06-04', 'fire');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000002', 'POL-HLTH-2026-000001', '2024-08-18', 'illness');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000003', 'POL-HOME-2026-000002', '2024-10-19', 'fire');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000004', 'POL-AUTO-2026-000005', '2024-10-28', 'theft');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000005', 'POL-AUTO-2026-000005', '2025-01-07', 'theft');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000006', 'POL-TRVL-2026-000014', '2025-07-21', 'baggage_loss');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000007', 'POL-AUTO-2026-000008', '2025-08-17', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000008', 'POL-AUTO-2026-000009', '2025-09-15', 'collision');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000009', 'POL-AUTO-2026-000009', '2025-09-15', 'collision');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000010', 'POL-LIAB-2026-000012', '2025-08-11', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000011', 'POL-LIAB-2026-000012', '2025-09-14', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000012', 'POL-LIAB-2026-000022', '2025-11-17', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000013', 'POL-AUTO-2026-000008', '2025-12-12', 'theft');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000014', 'POL-AUTO-2026-000013', '2025-12-27', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000015', 'POL-HOME-2026-000011', '2025-12-27', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000016', 'POL-HOME-2026-000011', '2025-12-27', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000017', 'POL-AUTO-2026-000034', '2026-01-25', 'collision');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000018', 'POL-HLTH-2026-000021', '2026-02-03', 'injury');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000019', 'POL-HOME-2026-000032', '2026-03-12', 'fire');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000020', 'POL-HOME-2026-000038', '2026-03-23', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000021', 'POL-HLTH-2026-000039', '2026-03-30', 'illness');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000022', 'POL-AUTO-2026-000020', '2026-03-30', 'collision');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000023', 'POL-AUTO-2026-000033', '2026-04-12', 'collision');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000024', 'POL-HOME-2026-000037', '2026-04-18', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000025', 'POL-HOME-2026-000045', '2026-04-20', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000026', 'POL-HLTH-2026-000021', '2026-05-15', 'illness');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000027', 'POL-HOME-2026-000045', '2026-05-25', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000028', 'POL-AUTO-2026-000013', '2026-05-31', 'collision');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000029', 'POL-LIAB-2026-000012', '2026-02-22', 'third_party_injury');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000030', 'POL-AUTO-2026-000034', '2026-07-01', 'theft');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000031', 'POL-HLTH-2026-000028', '2026-07-28', 'illness');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000032', 'POL-AUTO-2026-000017', '2026-07-31', 'theft');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000033', 'POL-LIAB-2026-000071', '2026-08-04', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000034', 'POL-HOME-2026-000019', '2026-08-19', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000035', 'POL-HOME-2026-000083', '2026-08-25', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000036', 'POL-HLTH-2026-000021', '2026-08-29', 'illness');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000037', 'POL-LIAB-2026-000050', '2026-08-08', 'third_party_injury');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000038', 'POL-HLTH-2026-000029', '2026-07-27', 'injury');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000039', 'POL-LIAB-2026-000041', '2026-06-29', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000040', 'POL-HOME-2026-000061', '2026-09-25', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000041', 'POL-AUTO-2026-000082', '2026-09-08', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000042', 'POL-HOME-2026-000061', '2026-09-25', 'water_damage');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000043', 'POL-HLTH-2026-000072', '2026-09-30', 'illness');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000044', 'POL-HOME-2026-000064', '2026-10-04', 'fire');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000045', 'POL-AUTO-2026-000079', '2026-10-04', 'collision');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000046', 'POL-AUTO-2026-000095', '2026-10-09', 'third_party_property');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000047', 'POL-TRVL-2026-000097', '2026-10-13', 'illness');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000048', 'POL-AUTO-2026-000060', '2026-10-11', 'theft');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000049', 'POL-HOME-2026-000031', '2026-10-16', 'burglary');
INSERT INTO incident (incident_id, policy_id, incident_date, incident_type) VALUES ('INC-2026-000050', 'POL-HOME-2026-000058', '2026-10-22', 'burglary');
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000001', 'POL-HOME-2026-000002', 'INC-2026-000001', 'HOME', '2024-06-05', 27070.51);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000002', 'POL-HLTH-2026-000001', 'INC-2026-000002', 'HLTH', '2024-08-23', 78.16);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000003', 'POL-HOME-2026-000002', 'INC-2026-000003', 'HOME', '2024-10-21', 33000.62);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000004', 'POL-AUTO-2026-000005', 'INC-2026-000004', 'AUTO', '2024-10-30', 41010.21);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000005', 'POL-AUTO-2026-000005', 'INC-2026-000005', 'AUTO', '2025-01-17', 13891.12);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000006', 'POL-TRVL-2026-000014', 'INC-2026-000006', 'TRVL', '2025-07-28', 817.84);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000007', 'POL-AUTO-2026-000008', 'INC-2026-000007', 'AUTO', '2025-08-18', 17185.20);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000008', 'POL-AUTO-2026-000009', 'INC-2026-000008', 'AUTO', '2025-09-18', 1610.31);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000009', 'POL-AUTO-2026-000009', 'INC-2026-000009', 'AUTO', '2025-09-21', 1610.31);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000010', 'POL-LIAB-2026-000012', 'INC-2026-000010', 'LIAB', '2025-09-25', 4212.21);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000011', 'POL-LIAB-2026-000012', 'INC-2026-000011', 'LIAB', '2025-10-14', 2000.00);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000012', 'POL-LIAB-2026-000022', 'INC-2026-000012', 'LIAB', '2025-11-24', 31685.11);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000013', 'POL-AUTO-2026-000008', 'INC-2026-000013', 'AUTO', '2025-12-13', 2208.94);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000014', 'POL-AUTO-2026-000013', 'INC-2026-000014', 'AUTO', '2025-12-28', 5082.74);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000015', 'POL-HOME-2026-000011', 'INC-2026-000015', 'HOME', '2025-12-28', 63709.94);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000016', 'POL-HOME-2026-000011', 'INC-2026-000016', 'HOME', '2026-01-06', 63709.94);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000017', 'POL-AUTO-2026-000034', 'INC-2026-000017', 'AUTO', '2026-01-25', 302.04);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000018', 'POL-HLTH-2026-000021', 'INC-2026-000018', 'HLTH', '2026-02-03', 207.31);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000019', 'POL-HOME-2026-000032', 'INC-2026-000019', 'HOME', '2026-03-17', 77481.15);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000020', 'POL-HOME-2026-000038', 'INC-2026-000020', 'HOME', '2026-03-25', 57378.96);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000021', 'POL-HLTH-2026-000039', 'INC-2026-000021', 'HLTH', '2026-04-01', 1867.89);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000022', 'POL-AUTO-2026-000020', 'INC-2026-000022', 'AUTO', '2026-04-02', 222.16);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000023', 'POL-AUTO-2026-000033', 'INC-2026-000023', 'AUTO', '2026-04-14', 497.86);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000024', 'POL-HOME-2026-000037', 'INC-2026-000024', 'HOME', '2026-04-18', 1456.78);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000025', 'POL-HOME-2026-000045', 'INC-2026-000025', 'HOME', '2026-04-30', 38739.80);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000026', 'POL-HLTH-2026-000021', 'INC-2026-000026', 'HLTH', '2026-05-15', 650.10);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000027', 'POL-HOME-2026-000045', 'INC-2026-000027', 'HOME', '2026-05-30', 28833.57);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000028', 'POL-AUTO-2026-000013', 'INC-2026-000028', 'AUTO', '2026-06-10', 1715.99);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000029', 'POL-LIAB-2026-000012', 'INC-2026-000029', 'LIAB', '2026-06-22', 39251.71);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000030', 'POL-AUTO-2026-000034', 'INC-2026-000030', 'AUTO', '2026-07-06', 5326.85);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000031', 'POL-HLTH-2026-000028', 'INC-2026-000031', 'HLTH', '2026-07-29', 371.01);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000032', 'POL-AUTO-2026-000017', 'INC-2026-000032', 'AUTO', '2026-08-01', 17229.63);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000033', 'POL-LIAB-2026-000071', 'INC-2026-000033', 'LIAB', '2026-08-06', 12990.93);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000034', 'POL-HOME-2026-000019', 'INC-2026-000034', 'HOME', '2026-08-21', 9210.19);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000035', 'POL-HOME-2026-000083', 'INC-2026-000035', 'HOME', '2026-08-25', 17785.39);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000036', 'POL-HLTH-2026-000021', 'INC-2026-000036', 'HLTH', '2026-08-30', 404.12);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000037', 'POL-LIAB-2026-000050', 'INC-2026-000037', 'LIAB', '2026-09-07', 3704.22);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000038', 'POL-HLTH-2026-000029', 'INC-2026-000038', 'HLTH', '2026-09-10', 2640.08);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000039', 'POL-LIAB-2026-000041', 'INC-2026-000039', 'LIAB', '2026-09-12', 4370.54);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000040', 'POL-HOME-2026-000061', 'INC-2026-000040', 'HOME', '2026-09-25', 6141.11);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000041', 'POL-AUTO-2026-000082', 'INC-2026-000041', 'AUTO', '2026-09-29', 12165.10);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000042', 'POL-HOME-2026-000061', 'INC-2026-000042', 'HOME', '2026-09-30', 6141.11);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000043', 'POL-HLTH-2026-000072', 'INC-2026-000043', 'HLTH', '2026-09-30', 253.57);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000044', 'POL-HOME-2026-000064', 'INC-2026-000044', 'HOME', '2026-10-05', 8400.86);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000045', 'POL-AUTO-2026-000079', 'INC-2026-000045', 'AUTO', '2026-10-07', 6948.06);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000046', 'POL-AUTO-2026-000095', 'INC-2026-000046', 'AUTO', '2026-10-09', 1564.44);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000047', 'POL-TRVL-2026-000097', 'INC-2026-000047', 'TRVL', '2026-10-14', 779.64);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000048', 'POL-AUTO-2026-000060', 'INC-2026-000048', 'AUTO', '2026-10-16', 14703.63);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000049', 'POL-HOME-2026-000031', 'INC-2026-000049', 'HOME', '2026-10-17', 7613.99);
INSERT INTO claim (claim_id, policy_id, incident_id, claim_type, submission_date, claimed_amount) VALUES ('CLM-2026-000050', 'POL-HOME-2026-000058', 'INC-2026-000050', 'HOME', '2026-10-22', 20000.00);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000001-001', 'CLM-2026-000001', 'COV-HOME-001', 'repair', 15696.74);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000001-002', 'CLM-2026-000001', 'COV-HOME-001', 'replacement', 11373.77);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000002-001', 'CLM-2026-000002', 'COV-HLTH-001', 'medical_treatment', 78.16);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000003-001', 'CLM-2026-000003', 'COV-HOME-001', 'repair', 8743.18);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000003-002', 'CLM-2026-000003', 'COV-HOME-001', 'repair', 21124.43);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000003-003', 'CLM-2026-000003', 'COV-HOME-001', 'repair', 3133.01);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000004-001', 'CLM-2026-000004', 'COV-AUTO-002', 'replacement', 41010.21);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000005-001', 'CLM-2026-000005', 'COV-AUTO-002', 'replacement', 13891.12);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000006-001', 'CLM-2026-000006', 'COV-TRVL-002', 'baggage', 817.84);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000007-001', 'CLM-2026-000007', 'COV-AUTO-003', 'liability_payment', 895.99);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000007-002', 'CLM-2026-000007', 'COV-AUTO-003', 'liability_payment', 4774.87);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000007-003', 'CLM-2026-000007', 'COV-AUTO-003', 'liability_payment', 11514.34);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000008-001', 'CLM-2026-000008', 'COV-AUTO-004', 'towing', 576.38);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000008-002', 'CLM-2026-000008', 'COV-AUTO-004', 'rental_car', 680.82);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000008-003', 'CLM-2026-000008', 'COV-AUTO-004', 'towing', 353.11);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000009-001', 'CLM-2026-000009', 'COV-AUTO-004', 'towing', 576.38);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000009-002', 'CLM-2026-000009', 'COV-AUTO-004', 'rental_car', 680.82);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000009-003', 'CLM-2026-000009', 'COV-AUTO-004', 'towing', 353.11);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000010-001', 'CLM-2026-000010', 'COV-LIAB-002', 'liability_payment', 4212.21);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000011-001', 'CLM-2026-000011', 'COV-LIAB-002', 'liability_payment', 2000.00);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000012-001', 'CLM-2026-000012', 'COV-LIAB-002', 'liability_payment', 10845.09);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000012-002', 'CLM-2026-000012', 'COV-LIAB-002', 'repair', 20840.02);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000013-001', 'CLM-2026-000013', 'COV-AUTO-002', 'replacement', 2208.94);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000014-001', 'CLM-2026-000014', 'COV-AUTO-003', 'liability_payment', 5082.74);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000015-001', 'CLM-2026-000015', 'COV-HOME-002', 'repair', 7753.99);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000015-002', 'CLM-2026-000015', 'COV-HOME-002', 'replacement', 43839.31);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000015-003', 'CLM-2026-000015', 'COV-HOME-002', 'replacement', 12116.64);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000016-001', 'CLM-2026-000016', 'COV-HOME-002', 'repair', 7753.99);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000016-002', 'CLM-2026-000016', 'COV-HOME-002', 'replacement', 43839.31);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000016-003', 'CLM-2026-000016', 'COV-HOME-002', 'replacement', 12116.64);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000017-001', 'CLM-2026-000017', 'COV-AUTO-004', 'rental_car', 302.04);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000018-001', 'CLM-2026-000018', 'COV-HLTH-001', 'medical_treatment', 207.31);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000019-001', 'CLM-2026-000019', 'COV-HOME-001', 'repair', 20531.40);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000019-002', 'CLM-2026-000019', 'COV-HOME-001', 'repair', 54255.58);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000019-003', 'CLM-2026-000019', 'COV-HOME-004', 'replacement', 2694.17);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000020-001', 'CLM-2026-000020', 'COV-HOME-004', 'replacement', 57378.96);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000021-001', 'CLM-2026-000021', 'COV-HLTH-003', 'hospital_stay', 1867.89);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000022-001', 'CLM-2026-000022', 'COV-AUTO-004', 'rental_car', 222.16);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000023-001', 'CLM-2026-000023', 'COV-AUTO-004', 'towing', 497.86);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000024-001', 'CLM-2026-000024', 'COV-HOME-004', 'replacement', 1456.78);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000025-001', 'CLM-2026-000025', 'COV-HOME-002', 'repair', 25351.76);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000025-002', 'CLM-2026-000025', 'COV-HOME-002', 'replacement', 5701.78);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000025-003', 'CLM-2026-000025', 'COV-HOME-002', 'replacement', 7686.26);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000026-001', 'CLM-2026-000026', 'COV-HLTH-001', 'medical_treatment', 569.87);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000026-002', 'CLM-2026-000026', 'COV-HLTH-001', 'medical_treatment', 80.23);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000027-001', 'CLM-2026-000027', 'COV-HOME-002', 'replacement', 2944.64);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000027-002', 'CLM-2026-000027', 'COV-HOME-002', 'replacement', 12367.59);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000027-003', 'CLM-2026-000027', 'COV-HOME-002', 'replacement', 13521.34);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000028-001', 'CLM-2026-000028', 'COV-AUTO-004', 'rental_car', 742.97);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000028-002', 'CLM-2026-000028', 'COV-AUTO-004', 'towing', 696.92);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000028-003', 'CLM-2026-000028', 'COV-AUTO-004', 'towing', 276.10);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000029-001', 'CLM-2026-000029', 'COV-LIAB-001', 'medical_treatment', 39251.71);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000030-001', 'CLM-2026-000030', 'COV-AUTO-002', 'replacement', 5326.85);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000031-001', 'CLM-2026-000031', 'COV-HLTH-001', 'medical_treatment', 371.01);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000032-001', 'CLM-2026-000032', 'COV-AUTO-002', 'replacement', 9239.32);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000032-002', 'CLM-2026-000032', 'COV-AUTO-002', 'replacement', 6323.68);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000032-003', 'CLM-2026-000032', 'COV-AUTO-002', 'replacement', 1666.63);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000033-001', 'CLM-2026-000033', 'COV-LIAB-002', 'repair', 12990.93);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000034-001', 'CLM-2026-000034', 'COV-HOME-004', 'replacement', 5516.31);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000034-002', 'CLM-2026-000034', 'COV-HOME-004', 'replacement', 3693.88);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000035-001', 'CLM-2026-000035', 'COV-HOME-002', 'replacement', 8778.86);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000035-002', 'CLM-2026-000035', 'COV-HOME-002', 'replacement', 9006.53);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000036-001', 'CLM-2026-000036', 'COV-HLTH-001', 'medical_treatment', 263.30);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000036-002', 'CLM-2026-000036', 'COV-HLTH-001', 'medical_treatment', 140.82);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000037-001', 'CLM-2026-000037', 'COV-LIAB-001', 'medical_treatment', 3704.22);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000038-001', 'CLM-2026-000038', 'COV-HLTH-002', 'hospital_stay', 2640.08);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000039-001', 'CLM-2026-000039', 'COV-LIAB-002', 'liability_payment', 4370.54);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000040-001', 'CLM-2026-000040', 'COV-HOME-004', 'replacement', 6141.11);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000041-001', 'CLM-2026-000041', 'COV-AUTO-003', 'liability_payment', 12165.10);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000042-001', 'CLM-2026-000042', 'COV-HOME-004', 'replacement', 6141.11);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000043-001', 'CLM-2026-000043', 'COV-HLTH-001', 'medical_treatment', 253.57);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000044-001', 'CLM-2026-000044', 'COV-HOME-004', 'replacement', 8400.86);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000045-001', 'CLM-2026-000045', 'COV-AUTO-001', 'repair', 6948.06);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000046-001', 'CLM-2026-000046', 'COV-AUTO-003', 'liability_payment', 1564.44);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000047-001', 'CLM-2026-000047', 'COV-TRVL-003', 'hospital_stay', 779.64);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000048-001', 'CLM-2026-000048', 'COV-AUTO-002', 'replacement', 14703.63);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000049-001', 'CLM-2026-000049', 'COV-HOME-003', 'replacement', 1190.60);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000049-002', 'CLM-2026-000049', 'COV-HOME-003', 'replacement', 6423.39);
INSERT INTO claim_item (item_id, claim_id, coverage_id, item_type, claimed_amount) VALUES ('ITM-CLM-2026-000050-001', 'CLM-2026-000050', 'COV-HOME-004', 'replacement', 20000.00);
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000001-001', 'CLM-2026-000001', 'photo', '2024-06-07', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000001-002', 'CLM-2026-000001', 'repair_estimate', '2024-06-05', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000001-003', 'CLM-2026-000001', 'proof_of_ownership', '2024-06-07', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000002-001', 'CLM-2026-000002', 'medical_report', '2024-08-25', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000002-002', 'CLM-2026-000002', 'invoice', '2024-08-23', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000003-001', 'CLM-2026-000003', 'photo', '2024-10-21', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000003-002', 'CLM-2026-000003', 'repair_estimate', '2024-10-21', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000004-001', 'CLM-2026-000004', 'photo', '2024-11-02', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000004-002', 'CLM-2026-000004', 'police_report', '2024-11-01', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000005-001', 'CLM-2026-000005', 'photo', '2025-01-18', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000005-002', 'CLM-2026-000005', 'police_report', '2025-01-20', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000006-001', 'CLM-2026-000006', 'itinerary', '2025-07-28', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000006-002', 'CLM-2026-000006', 'invoice', '2025-07-29', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000006-003', 'CLM-2026-000006', 'incident_statement', '2025-07-29', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000007-001', 'CLM-2026-000007', 'photo', '2025-08-19', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000007-002', 'CLM-2026-000007', 'police_report', '2025-08-21', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000008-001', 'CLM-2026-000008', 'photo', '2025-09-18', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000008-002', 'CLM-2026-000008', 'police_report', '2025-09-18', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000008-003', 'CLM-2026-000008', 'repair_estimate', '2025-09-20', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000009-001', 'CLM-2026-000009', 'photo', '2025-09-21', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000009-002', 'CLM-2026-000009', 'police_report', '2025-09-21', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000009-003', 'CLM-2026-000009', 'repair_estimate', '2025-09-23', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000010-001', 'CLM-2026-000010', 'incident_statement', '2025-09-25', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000010-002', 'CLM-2026-000010', 'police_report', '2025-09-25', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000011-001', 'CLM-2026-000011', 'incident_statement', '2025-10-17', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000011-002', 'CLM-2026-000011', 'police_report', '2025-10-17', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000012-001', 'CLM-2026-000012', 'incident_statement', '2025-12-24', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000012-002', 'CLM-2026-000012', 'police_report', '2025-11-25', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000013-001', 'CLM-2026-000013', 'photo', '2025-12-14', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000013-002', 'CLM-2026-000013', 'police_report', '2025-12-13', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000013-003', 'CLM-2026-000013', 'repair_estimate', '2025-12-14', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000014-001', 'CLM-2026-000014', 'photo', '2025-12-31', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000014-002', 'CLM-2026-000014', 'police_report', '2025-12-30', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000015-001', 'CLM-2026-000015', 'photo', '2025-12-28', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000015-002', 'CLM-2026-000015', 'repair_estimate', '2025-12-28', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000015-003', 'CLM-2026-000015', 'proof_of_ownership', '2025-12-29', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000016-001', 'CLM-2026-000016', 'photo', '2026-01-06', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000016-002', 'CLM-2026-000016', 'repair_estimate', '2026-01-06', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000016-003', 'CLM-2026-000016', 'proof_of_ownership', '2026-01-07', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000017-001', 'CLM-2026-000017', 'photo', '2026-01-27', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000017-002', 'CLM-2026-000017', 'police_report', '2026-01-26', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000018-001', 'CLM-2026-000018', 'medical_report', '2026-02-04', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000018-002', 'CLM-2026-000018', 'invoice', '2026-02-05', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000019-001', 'CLM-2026-000019', 'repair_estimate', '2026-03-19', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000019-002', 'CLM-2026-000019', 'proof_of_ownership', '2026-03-18', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000020-001', 'CLM-2026-000020', 'photo', '2026-03-26', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000020-002', 'CLM-2026-000020', 'repair_estimate', '2026-03-28', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000020-003', 'CLM-2026-000020', 'proof_of_ownership', '2026-03-26', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000021-001', 'CLM-2026-000021', 'medical_report', '2026-04-02', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000022-001', 'CLM-2026-000022', 'photo', '2026-04-04', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000022-002', 'CLM-2026-000022', 'police_report', '2026-04-04', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000023-001', 'CLM-2026-000023', 'photo', '2026-04-17', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000023-002', 'CLM-2026-000023', 'police_report', '2026-04-16', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000024-001', 'CLM-2026-000024', 'photo', '2026-04-18', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000024-002', 'CLM-2026-000024', 'repair_estimate', '2026-04-21', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000024-003', 'CLM-2026-000024', 'proof_of_ownership', '2026-04-20', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000025-001', 'CLM-2026-000025', 'photo', '2026-05-03', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000025-002', 'CLM-2026-000025', 'repair_estimate', '2026-05-03', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000025-003', 'CLM-2026-000025', 'proof_of_ownership', '2026-05-01', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000026-001', 'CLM-2026-000026', 'medical_report', '2026-05-18', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000026-002', 'CLM-2026-000026', 'invoice', '2026-05-15', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000027-001', 'CLM-2026-000027', 'photo', '2026-06-02', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000027-002', 'CLM-2026-000027', 'repair_estimate', '2026-05-31', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000027-003', 'CLM-2026-000027', 'proof_of_ownership', '2026-05-31', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000028-001', 'CLM-2026-000028', 'photo', '2026-06-13', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000028-002', 'CLM-2026-000028', 'police_report', '2026-06-12', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000028-003', 'CLM-2026-000028', 'repair_estimate', '2026-06-10', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000029-001', 'CLM-2026-000029', 'incident_statement', '2026-06-23', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000029-002', 'CLM-2026-000029', 'police_report', '2026-06-24', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000030-001', 'CLM-2026-000030', 'photo', '2026-07-06', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000030-002', 'CLM-2026-000030', 'police_report', '2026-07-08', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000031-001', 'CLM-2026-000031', 'medical_report', '2026-07-31', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000031-002', 'CLM-2026-000031', 'invoice', '2026-08-01', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000032-001', 'CLM-2026-000032', 'photo', '2026-08-03', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000032-002', 'CLM-2026-000032', 'police_report', '2026-08-04', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000032-003', 'CLM-2026-000032', 'repair_estimate', '2026-08-01', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000033-001', 'CLM-2026-000033', 'incident_statement', '2026-08-09', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000033-002', 'CLM-2026-000033', 'police_report', '2026-08-08', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000034-001', 'CLM-2026-000034', 'photo', '2026-08-22', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000034-002', 'CLM-2026-000034', 'repair_estimate', '2026-08-21', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000035-001', 'CLM-2026-000035', 'photo', '2026-08-28', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000035-002', 'CLM-2026-000035', 'repair_estimate', '2026-08-25', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000036-001', 'CLM-2026-000036', 'medical_report', '2026-09-01', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000036-002', 'CLM-2026-000036', 'invoice', '2026-08-30', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000037-001', 'CLM-2026-000037', 'incident_statement', '2026-09-10', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000037-002', 'CLM-2026-000037', 'police_report', '2026-09-10', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000038-001', 'CLM-2026-000038', 'medical_report', '2026-09-11', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000038-002', 'CLM-2026-000038', 'invoice', '2026-09-10', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000039-001', 'CLM-2026-000039', 'incident_statement', '2026-09-13', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000039-002', 'CLM-2026-000039', 'police_report', '2026-09-14', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000040-001', 'CLM-2026-000040', 'photo', '2026-09-28', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000040-002', 'CLM-2026-000040', 'repair_estimate', '2026-09-26', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000041-001', 'CLM-2026-000041', 'photo', '2026-09-30', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000042-001', 'CLM-2026-000042', 'photo', '2026-09-30', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000042-002', 'CLM-2026-000042', 'repair_estimate', '2026-10-01', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000043-001', 'CLM-2026-000043', 'medical_report', '2026-10-02', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000043-002', 'CLM-2026-000043', 'invoice', '2026-10-01', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000044-001', 'CLM-2026-000044', 'photo', '2026-10-08', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000044-002', 'CLM-2026-000044', 'repair_estimate', '2026-10-08', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000044-003', 'CLM-2026-000044', 'proof_of_ownership', '2026-10-08', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000045-001', 'CLM-2026-000045', 'photo', '2026-10-07', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000045-002', 'CLM-2026-000045', 'police_report', '2026-10-09', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000046-001', 'CLM-2026-000046', 'photo', '2026-10-11', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000046-002', 'CLM-2026-000046', 'police_report', '2026-10-11', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000046-003', 'CLM-2026-000046', 'repair_estimate', '2026-10-10', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000047-001', 'CLM-2026-000047', 'itinerary', '2026-10-16', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000047-002', 'CLM-2026-000047', 'invoice', '2026-10-17', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000047-003', 'CLM-2026-000047', 'incident_statement', '2026-10-15', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000048-001', 'CLM-2026-000048', 'photo', '2026-10-16', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000048-002', 'CLM-2026-000048', 'police_report', '2026-10-18', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000049-001', 'CLM-2026-000049', 'photo', '2026-10-17', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000049-002', 'CLM-2026-000049', 'repair_estimate', '2026-10-17', 'rejected');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000049-003', 'CLM-2026-000049', 'proof_of_ownership', '2026-10-18', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000050-001', 'CLM-2026-000050', 'photo', '2026-10-22', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000050-002', 'CLM-2026-000050', 'repair_estimate', '2026-10-22', 'received');
INSERT INTO document (document_id, claim_id, doc_type, received_date, status) VALUES ('DOC-CLM-2026-000050-003', 'CLM-2026-000050', 'proof_of_ownership', '2026-10-22', 'received');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000001-001', 'CLM-2026-000001', 'ADJ-007', '2024-06-05', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000002-001', 'CLM-2026-000002', 'ADJ-003', '2024-08-23', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000003-001', 'CLM-2026-000003', 'ADJ-002', '2024-10-21', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000004-001', 'CLM-2026-000004', 'ADJ-001', '2024-10-30', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000005-001', 'CLM-2026-000005', 'ADJ-006', '2025-01-17', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000006-001', 'CLM-2026-000006', 'ADJ-009', '2025-07-28', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000007-001', 'CLM-2026-000007', 'ADJ-001', '2025-08-18', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000008-001', 'CLM-2026-000008', 'ADJ-006', '2025-09-18', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000009-001', 'CLM-2026-000009', 'ADJ-006', '2025-09-21', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000010-001', 'CLM-2026-000010', 'ADJ-010', '2025-09-25', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000011-001', 'CLM-2026-000011', 'ADJ-005', '2025-10-14', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000012-001', 'CLM-2026-000012', 'ADJ-010', '2025-11-24', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000013-001', 'CLM-2026-000013', 'ADJ-001', '2025-12-13', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000014-001', 'CLM-2026-000014', 'ADJ-006', '2025-12-28', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000015-001', 'CLM-2026-000015', 'ADJ-007', '2025-12-28', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000016-001', 'CLM-2026-000016', 'ADJ-002', '2026-01-06', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000016-002', 'CLM-2026-000016', 'ADJ-007', '2026-01-07', 'reassigned');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000017-001', 'CLM-2026-000017', 'ADJ-001', '2026-01-25', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000018-001', 'CLM-2026-000018', 'ADJ-003', '2026-02-03', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000019-001', 'CLM-2026-000019', 'ADJ-007', '2026-03-17', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000020-001', 'CLM-2026-000020', 'ADJ-007', '2026-03-25', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000021-001', 'CLM-2026-000021', 'ADJ-008', '2026-04-01', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000022-001', 'CLM-2026-000022', 'ADJ-001', '2026-04-02', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000023-001', 'CLM-2026-000023', 'ADJ-001', '2026-04-14', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000024-001', 'CLM-2026-000024', 'ADJ-002', '2026-04-18', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000025-001', 'CLM-2026-000025', 'ADJ-007', '2026-04-30', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000026-001', 'CLM-2026-000026', 'ADJ-003', '2026-05-15', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000027-001', 'CLM-2026-000027', 'ADJ-002', '2026-05-30', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000028-001', 'CLM-2026-000028', 'ADJ-001', '2026-06-10', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000029-001', 'CLM-2026-000029', 'ADJ-005', '2026-06-22', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000030-001', 'CLM-2026-000030', 'ADJ-006', '2026-07-06', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000031-001', 'CLM-2026-000031', 'ADJ-008', '2026-07-29', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000032-001', 'CLM-2026-000032', 'ADJ-006', '2026-08-01', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000033-001', 'CLM-2026-000033', 'ADJ-010', '2026-08-06', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000034-001', 'CLM-2026-000034', 'ADJ-002', '2026-08-21', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000034-002', 'CLM-2026-000034', 'ADJ-007', '2026-08-22', 'reassigned');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000035-001', 'CLM-2026-000035', 'ADJ-007', '2026-08-25', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000036-001', 'CLM-2026-000036', 'ADJ-008', '2026-08-30', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000037-001', 'CLM-2026-000037', 'ADJ-010', '2026-09-07', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000038-001', 'CLM-2026-000038', 'ADJ-008', '2026-09-10', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000039-001', 'CLM-2026-000039', 'ADJ-005', '2026-09-12', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000039-002', 'CLM-2026-000039', 'ADJ-010', '2026-09-13', 'reassigned');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000040-001', 'CLM-2026-000040', 'ADJ-007', '2026-09-25', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000040-002', 'CLM-2026-000040', 'ADJ-002', '2026-09-26', 'reassigned');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000041-001', 'CLM-2026-000041', 'ADJ-001', '2026-09-29', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000042-001', 'CLM-2026-000042', 'ADJ-002', '2026-09-30', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000043-001', 'CLM-2026-000043', 'ADJ-008', '2026-09-30', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000043-002', 'CLM-2026-000043', 'ADJ-003', '2026-10-01', 'reassigned');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000044-001', 'CLM-2026-000044', 'ADJ-007', '2026-10-05', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000044-002', 'CLM-2026-000044', 'ADJ-002', '2026-10-06', 'reassigned');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000045-001', 'CLM-2026-000045', 'ADJ-006', '2026-10-07', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000046-001', 'CLM-2026-000046', 'ADJ-001', '2026-10-09', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000047-001', 'CLM-2026-000047', 'ADJ-004', '2026-10-14', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000048-001', 'CLM-2026-000048', 'ADJ-001', '2026-10-16', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000049-001', 'CLM-2026-000049', 'ADJ-007', '2026-10-17', 'initial');
INSERT INTO claim_adjuster_assignment (assignment_id, claim_id, adjuster_id, assigned_date, reason) VALUES ('ASN-CLM-2026-000050-001', 'CLM-2026-000050', 'ADJ-007', '2026-10-22', 'initial');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000001-001', 'CLM-2026-000001', 'ADJ-007', '2024-06-07', 'approve', 'R-PAY-01', 'eligible', 27070.51, 2000.00, 25070.51, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000002-001', 'CLM-2026-000002', 'ADJ-003', '2024-08-27', 'deny', 'R-PAY-01', 'within_deductible', 78.16, 78.16, 0.00, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000003-001', 'CLM-2026-000003', 'ADJ-002', '2024-10-23', 'approve', 'R-PAY-01', 'eligible', 33000.62, 2000.00, 31000.62, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000004-001', 'CLM-2026-000004', 'ADJ-001', '2024-11-04', 'approve', 'R-PAY-01', 'limit_reached', 41010.21, 1000.00, 30000.00, 0.25, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000005-001', 'CLM-2026-000005', 'ADJ-006', '2025-01-20', 'deny', 'R-PAY-01', 'limit_reached', 13891.12, 1000.00, 0.00, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000006-001', 'CLM-2026-000006', 'ADJ-009', '2025-08-02', 'approve', 'R-PAY-01', 'eligible', 817.84, 100.00, 717.84, 0.25, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000007-001', 'CLM-2026-000007', 'ADJ-001', '2025-08-23', 'approve', 'R-PAY-01', 'eligible', 17185.20, 0.00, 17185.20, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000008-001', 'CLM-2026-000008', 'ADJ-006', '2025-09-20', 'approve', 'R-PAY-01', 'eligible', 1610.31, 100.00, 1510.31, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000009-001', 'CLM-2026-000009', 'ADJ-006', '2025-09-24', 'refer_review', 'R-ELG-03', 'duplicate_claim', 0.00, 0.00, 0.00, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000010-001', 'CLM-2026-000010', 'ADJ-010', '2025-09-27', 'approve', 'R-PAY-01', 'eligible', 4212.21, 2000.00, 2212.21, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000011-001', 'CLM-2026-000011', 'ADJ-005', '2025-10-17', 'deny', 'R-PAY-01', 'within_deductible', 2000.00, 2000.00, 0.00, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000012-001', 'CLM-2026-000012', 'ADJ-010', '2025-11-25', 'pend_docs', 'R-DOC-01', 'missing_document', 0.00, 0.00, 0.00, 0.00, 'incident_statement');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000012-002', 'CLM-2026-000012', 'ADJ-010', '2025-12-24', 'approve', 'R-PAY-01', 'eligible', 31685.11, 2000.00, 29685.11, 0.25, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000013-001', 'CLM-2026-000013', 'ADJ-001', '2025-12-14', 'deny', 'R-COV-02', 'policy_not_in_force', 0.00, 0.00, 0.00, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000014-001', 'CLM-2026-000014', 'ADJ-006', '2025-12-31', 'approve', 'R-PAY-01', 'eligible', 5082.74, 0.00, 5082.74, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000015-001', 'CLM-2026-000015', 'ADJ-007', '2026-01-01', 'approve', 'R-PAY-01', 'eligible', 63709.94, 2000.00, 61709.94, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000016-001', 'CLM-2026-000016', 'ADJ-007', '2026-01-09', 'refer_review', 'R-ELG-03', 'duplicate_claim', 0.00, 0.00, 0.00, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000017-001', 'CLM-2026-000017', 'ADJ-001', '2026-01-28', 'approve', 'R-PAY-01', 'eligible', 302.04, 100.00, 202.04, 0.25, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000018-001', 'CLM-2026-000018', 'ADJ-003', '2026-02-05', 'deny', 'R-PAY-01', 'within_deductible', 207.31, 207.31, 0.00, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000019-001', 'CLM-2026-000019', 'ADJ-007', '2026-03-20', 'pend_docs', 'R-DOC-01', 'missing_document', 0.00, 0.00, 0.00, 0.00, 'photo');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000020-001', 'CLM-2026-000020', 'ADJ-007', '2026-03-28', 'refer_review', 'R-FRD-05', 'suspected_fraud', 0.00, 0.00, 0.00, 0.50, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000021-001', 'CLM-2026-000021', 'ADJ-008', '2026-04-03', 'pend_docs', 'R-DOC-01', 'missing_document', 0.00, 0.00, 0.00, 0.00, 'invoice');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000022-001', 'CLM-2026-000022', 'ADJ-001', '2026-04-07', 'approve', 'R-PAY-01', 'eligible', 222.16, 200.00, 22.16, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000023-001', 'CLM-2026-000023', 'ADJ-001', '2026-04-17', 'approve', 'R-PAY-01', 'eligible', 497.86, 200.00, 297.86, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000024-001', 'CLM-2026-000024', 'ADJ-002', '2026-04-23', 'approve', 'R-PAY-01', 'eligible', 1456.78, 500.00, 956.78, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000025-001', 'CLM-2026-000025', 'ADJ-007', '2026-05-05', 'approve', 'R-PAY-01', 'eligible', 38739.80, 2000.00, 36739.80, 0.25, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000026-001', 'CLM-2026-000026', 'ADJ-003', '2026-05-18', 'approve', 'R-PAY-01', 'eligible', 650.10, 500.00, 150.10, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000027-001', 'CLM-2026-000027', 'ADJ-002', '2026-06-04', 'approve', 'R-PAY-01', 'limit_reached', 28833.57, 2000.00, 13260.20, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000028-001', 'CLM-2026-000028', 'ADJ-001', '2026-06-13', 'approve', 'R-PAY-01', 'eligible', 1715.99, 100.00, 1615.99, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000029-001', 'CLM-2026-000029', 'ADJ-005', '2026-06-24', 'deny', 'R-COV-02', 'policy_not_in_force', 0.00, 0.00, 0.00, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000030-001', 'CLM-2026-000030', 'ADJ-006', '2026-07-10', 'approve', 'R-PAY-01', 'eligible', 5326.85, 500.00, 4826.85, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000031-001', 'CLM-2026-000031', 'ADJ-008', '2026-08-01', 'approve', 'R-PAY-01', 'eligible', 371.01, 250.00, 121.01, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000032-001', 'CLM-2026-000032', 'ADJ-006', '2026-08-05', 'deny', 'R-COV-02', 'policy_not_in_force', 0.00, 0.00, 0.00, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000033-001', 'CLM-2026-000033', 'ADJ-010', '2026-08-09', 'deny', 'R-COV-01', 'before_policy_start', 0.00, 0.00, 0.00, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000034-001', 'CLM-2026-000034', 'ADJ-007', '2026-08-24', 'approve', 'R-PAY-01', 'eligible', 9210.19, 1000.00, 8210.19, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000035-001', 'CLM-2026-000035', 'ADJ-007', '2026-08-28', 'deny', 'R-COV-01', 'before_policy_start', 0.00, 0.00, 0.00, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000036-001', 'CLM-2026-000036', 'ADJ-008', '2026-09-03', 'deny', 'R-PAY-01', 'within_deductible', 404.12, 404.12, 0.00, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000037-001', 'CLM-2026-000037', 'ADJ-010', '2026-09-10', 'approve', 'R-PAY-01', 'eligible', 3704.22, 2000.00, 1704.22, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000038-001', 'CLM-2026-000038', 'ADJ-008', '2026-09-14', 'approve', 'R-PAY-01', 'eligible', 2640.08, 2000.00, 640.08, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000039-001', 'CLM-2026-000039', 'ADJ-010', '2026-09-17', 'approve', 'R-PAY-01', 'eligible', 4370.54, 2000.00, 2370.54, 0.25, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000040-001', 'CLM-2026-000040', 'ADJ-002', '2026-09-29', 'approve', 'R-PAY-01', 'eligible', 6141.11, 1000.00, 5141.11, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000041-001', 'CLM-2026-000041', 'ADJ-001', '2026-09-30', 'pend_docs', 'R-DOC-01', 'missing_document', 0.00, 0.00, 0.00, 0.00, 'police_report');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000042-001', 'CLM-2026-000042', 'ADJ-002', '2026-10-03', 'refer_review', 'R-ELG-03', 'duplicate_claim', 0.00, 0.00, 0.00, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000043-001', 'CLM-2026-000043', 'ADJ-003', '2026-10-05', 'approve', 'R-PAY-01', 'eligible', 253.57, 250.00, 3.57, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000044-001', 'CLM-2026-000044', 'ADJ-002', '2026-10-08', 'deny', 'R-COV-02', 'policy_not_in_force', 0.00, 0.00, 0.00, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000045-001', 'CLM-2026-000045', 'ADJ-006', '2026-10-11', 'approve', 'R-PAY-01', 'eligible', 6948.06, 500.00, 6448.06, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000046-001', 'CLM-2026-000046', 'ADJ-001', '2026-10-11', 'approve', 'R-PAY-01', 'eligible', 1564.44, 0.00, 1564.44, 0.25, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000047-001', 'CLM-2026-000047', 'ADJ-004', '2026-10-17', 'deny', 'R-COV-03', 'outside_coverage_period', 0.00, 0.00, 0.00, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000048-001', 'CLM-2026-000048', 'ADJ-001', '2026-10-18', 'approve', 'R-PAY-01', 'eligible', 14703.63, 500.00, 14203.63, 0.00, '');
INSERT INTO assessment (assessment_id, claim_id, adjuster_id, assessment_date, decision, rule_id, reason_code, eligible_amount, deductible_applied, payable_amount, fraud_score, missing_doc_types) VALUES ('ASM-CLM-2026-000049-001', 'CLM-2026-000049', 'ADJ-007', '2026-10-18', 'pend_docs', 'R-DOC-01', 'missing_document', 0.00, 0.00, 0.00, 0.00, 'repair_estimate');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000001-001', 'CLM-2026-000001', '2024-06-07', 25070.51, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000003-001', 'CLM-2026-000003', '2024-10-23', 31000.62, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000004-001', 'CLM-2026-000004', '2024-11-04', 30000.00, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000006-001', 'CLM-2026-000006', '2025-08-02', 717.84, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000007-001', 'CLM-2026-000007', '2025-08-23', 17185.20, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000008-001', 'CLM-2026-000008', '2025-09-20', 1510.31, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000010-001', 'CLM-2026-000010', '2025-09-27', 2212.21, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000012-001', 'CLM-2026-000012', '2025-12-24', 29685.11, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000014-001', 'CLM-2026-000014', '2025-12-31', 5082.74, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000015-001', 'CLM-2026-000015', '2026-01-01', 61709.94, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000017-001', 'CLM-2026-000017', '2026-01-28', 202.04, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000022-001', 'CLM-2026-000022', '2026-04-07', 22.16, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000023-001', 'CLM-2026-000023', '2026-04-17', 297.86, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000024-001', 'CLM-2026-000024', '2026-04-23', 956.78, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000025-001', 'CLM-2026-000025', '2026-05-05', 36739.80, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000026-001', 'CLM-2026-000026', '2026-05-18', 150.10, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000027-001', 'CLM-2026-000027', '2026-06-04', 13260.20, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000028-001', 'CLM-2026-000028', '2026-06-13', 1615.99, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000030-001', 'CLM-2026-000030', '2026-07-10', 4826.85, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000031-001', 'CLM-2026-000031', '2026-08-01', 121.01, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000034-001', 'CLM-2026-000034', '2026-08-24', 8210.19, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000037-001', 'CLM-2026-000037', '2026-09-10', 1704.22, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000038-001', 'CLM-2026-000038', '2026-09-14', 640.08, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000039-001', 'CLM-2026-000039', '2026-09-17', 2370.54, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000040-001', 'CLM-2026-000040', '2026-09-29', 5141.11, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000043-001', 'CLM-2026-000043', '2026-10-05', 3.57, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000045-001', 'CLM-2026-000045', '2026-10-11', 6448.06, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000046-001', 'CLM-2026-000046', '2026-10-11', 1564.44, 'preliminary', 'R-RSV-01');
INSERT INTO reserve (reserve_id, claim_id, reserve_date, amount, basis, rule_id) VALUES ('RSV-CLM-2026-000048-001', 'CLM-2026-000048', '2026-10-18', 14203.63, 'preliminary', 'R-RSV-01');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000001-001', 'CLM-2026-000001', 25070.51, '2024-06-07', 25070.51, '2024-06-08', 'process_owner', 25070.51, '2024-06-13');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000003-001', 'CLM-2026-000003', 31000.62, '2024-10-23', 31000.62, '2024-10-26', 'approver', 31000.62, '2024-10-28');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000004-001', 'CLM-2026-000004', 30000.00, '2024-11-04', 30000.00, '2024-11-07', 'process_owner', 30000.00, '2024-11-08');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000006-001', 'CLM-2026-000006', 717.84, '2025-08-02', 717.84, '2025-08-04', 'process_owner', 717.84, '2025-08-09');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000007-001', 'CLM-2026-000007', 17185.20, '2025-08-23', 17185.20, '2025-08-24', 'process_owner', 17185.20, '2025-08-26');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000008-001', 'CLM-2026-000008', 1510.31, '2025-09-20', 1510.31, '2025-09-23', 'process_owner', 1510.31, '2025-09-28');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000010-001', 'CLM-2026-000010', 2212.21, '2025-09-27', 2212.21, '2025-09-30', 'process_owner', 2212.21, '2025-10-04');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000012-001', 'CLM-2026-000012', 29685.11, '2025-12-24', 29685.11, '2025-12-25', 'process_owner', 29685.11, '2025-12-30');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000014-001', 'CLM-2026-000014', 5082.74, '2025-12-31', 5082.74, '2026-01-01', 'process_owner', 5082.74, '2026-01-03');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000015-001', 'CLM-2026-000015', 61709.94, '2026-01-01', 61709.94, '2026-01-04', 'approver', 61709.94, '2026-01-09');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000017-001', 'CLM-2026-000017', 202.04, '2026-01-28', 202.04, '2026-01-31', 'process_owner', 202.04, '2026-02-01');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000022-001', 'CLM-2026-000022', 22.16, '2026-04-07', 22.16, '2026-04-09', 'process_owner', 22.16, '2026-04-13');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000023-001', 'CLM-2026-000023', 297.86, '2026-04-17', 297.86, '2026-04-20', 'process_owner', 297.86, '2026-04-25');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000023-002', 'CLM-2026-000023', 297.86, '2026-04-17', 297.86, '2026-04-20', 'process_owner', 297.86, '2026-04-29');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000024-001', 'CLM-2026-000024', 956.78, '2026-04-23', 956.78, '2026-04-25', 'process_owner', 956.78, '2026-04-27');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000025-001', 'CLM-2026-000025', 36739.80, '2026-05-05', 36739.80, '2026-05-06', 'approver', 36739.80, '2026-05-07');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000026-001', 'CLM-2026-000026', 150.10, '2026-05-18', 150.10, '2026-05-21', 'process_owner', 150.10, '2026-05-26');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000027-001', 'CLM-2026-000027', 13260.20, '2026-06-04', 13260.20, '2026-06-07', 'process_owner', 13260.20, '2026-06-11');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000028-001', 'CLM-2026-000028', 1615.99, '2026-06-13', 1615.99, '2026-06-15', 'process_owner', 1615.99, '2026-06-19');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000030-001', 'CLM-2026-000030', 4826.85, '2026-07-10', 4826.85, '2026-07-12', 'process_owner', 4826.85, '2026-07-13');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000031-001', 'CLM-2026-000031', 121.01, '2026-08-01', 121.01, '2026-08-04', 'process_owner', 121.01, '2026-08-07');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000034-001', 'CLM-2026-000034', 87750.64, '2026-08-24', 87750.64, '2026-08-26', 'process_owner', 87750.64, '2026-08-31');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000037-001', 'CLM-2026-000037', 1704.22, '2026-09-10', 1704.22, '2026-09-13', 'process_owner', 1704.22, '2026-09-14');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000037-002', 'CLM-2026-000037', 1704.22, '2026-09-10', 1704.22, '2026-09-13', 'process_owner', 1704.22, '2026-09-15');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000038-001', 'CLM-2026-000038', 640.08, '2026-09-14', 640.08, '2026-09-15', 'process_owner', 640.08, '2026-09-18');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000039-001', 'CLM-2026-000039', 2370.54, '2026-09-17', 2370.54, '2026-09-20', 'process_owner', 2370.54, '2026-09-25');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000040-001', 'CLM-2026-000040', 5141.11, '2026-09-29', 5141.11, '2026-10-02', 'process_owner', 5141.11, '2026-10-06');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000043-001', 'CLM-2026-000043', 3.57, '2026-10-05', 3.57, '2026-10-08', 'process_owner', 3.57, '2026-10-13');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000045-001', 'CLM-2026-000045', 6448.06, '2026-10-11', 6448.06, '2026-10-14', 'process_owner', 6448.06, '2026-10-18');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000046-001', 'CLM-2026-000046', 1564.44, '2026-10-11', 1564.44, '2026-10-14', 'process_owner', 1564.44, '2026-10-15');
INSERT INTO settlement (settlement_id, claim_id, recommended_amount, recommended_date, approved_amount, approved_date, approver_role, paid_amount, paid_date) VALUES ('SET-CLM-2026-000048-001', 'CLM-2026-000048', 83490.50, '2026-10-18', 83490.50, '2026-10-19', 'process_owner', 83490.50, '2026-10-21');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000001-001', 'CLM-2026-000001', '', 'submitted', '2024-06-05', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000001-002', 'CLM-2026-000001', 'submitted', 'assessed', '2024-06-07', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000001-003', 'CLM-2026-000001', 'assessed', 'approved', '2024-06-08', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000001-004', 'CLM-2026-000001', 'approved', 'paid', '2024-06-13', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000002-001', 'CLM-2026-000002', '', 'submitted', '2024-08-23', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000002-002', 'CLM-2026-000002', 'submitted', 'denied', '2024-08-27', 'operations_analyst', 'R-PAY-01', 'within_deductible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000003-001', 'CLM-2026-000003', '', 'submitted', '2024-10-21', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000003-002', 'CLM-2026-000003', 'submitted', 'assessed', '2024-10-23', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000003-003', 'CLM-2026-000003', 'assessed', 'approved', '2024-10-26', 'approver', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000003-004', 'CLM-2026-000003', 'approved', 'paid', '2024-10-28', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000004-001', 'CLM-2026-000004', '', 'submitted', '2024-10-30', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000004-002', 'CLM-2026-000004', 'submitted', 'assessed', '2024-11-04', 'operations_analyst', 'R-PAY-01', 'limit_reached');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000004-003', 'CLM-2026-000004', 'assessed', 'approved', '2024-11-07', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000004-004', 'CLM-2026-000004', 'approved', 'paid', '2024-11-08', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000005-001', 'CLM-2026-000005', '', 'submitted', '2025-01-17', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000005-002', 'CLM-2026-000005', 'submitted', 'denied', '2025-01-20', 'operations_analyst', 'R-PAY-01', 'limit_reached');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000006-001', 'CLM-2026-000006', '', 'submitted', '2025-07-28', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000006-002', 'CLM-2026-000006', 'submitted', 'assessed', '2025-08-02', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000006-003', 'CLM-2026-000006', 'assessed', 'approved', '2025-08-04', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000006-004', 'CLM-2026-000006', 'approved', 'paid', '2025-08-09', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000007-001', 'CLM-2026-000007', '', 'submitted', '2025-08-18', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000007-002', 'CLM-2026-000007', 'submitted', 'assessed', '2025-08-23', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000007-003', 'CLM-2026-000007', 'assessed', 'approved', '2025-08-24', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000007-004', 'CLM-2026-000007', 'approved', 'paid', '2025-08-26', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000008-001', 'CLM-2026-000008', '', 'submitted', '2025-09-18', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000008-002', 'CLM-2026-000008', 'submitted', 'assessed', '2025-09-20', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000008-003', 'CLM-2026-000008', 'assessed', 'approved', '2025-09-23', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000008-004', 'CLM-2026-000008', 'approved', 'paid', '2025-09-28', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000009-001', 'CLM-2026-000009', '', 'submitted', '2025-09-21', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000009-002', 'CLM-2026-000009', 'submitted', 'under_review', '2025-09-24', 'operations_analyst', 'R-ELG-03', 'duplicate_claim');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000010-001', 'CLM-2026-000010', '', 'submitted', '2025-09-25', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000010-002', 'CLM-2026-000010', 'submitted', 'assessed', '2025-09-27', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000010-003', 'CLM-2026-000010', 'assessed', 'approved', '2025-09-30', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000010-004', 'CLM-2026-000010', 'approved', 'paid', '2025-10-04', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000011-001', 'CLM-2026-000011', '', 'submitted', '2025-10-14', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000011-002', 'CLM-2026-000011', 'submitted', 'denied', '2025-10-17', 'operations_analyst', 'R-PAY-01', 'within_deductible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000012-001', 'CLM-2026-000012', '', 'submitted', '2025-11-24', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000012-002', 'CLM-2026-000012', 'submitted', 'docs_pending', '2025-11-25', 'operations_analyst', 'R-DOC-01', 'missing_document');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000012-003', 'CLM-2026-000012', 'docs_pending', 'assessed', '2025-12-24', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000012-004', 'CLM-2026-000012', 'assessed', 'approved', '2025-12-25', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000012-005', 'CLM-2026-000012', 'approved', 'paid', '2025-12-30', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000013-001', 'CLM-2026-000013', '', 'submitted', '2025-12-13', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000013-002', 'CLM-2026-000013', 'submitted', 'denied', '2025-12-14', 'operations_analyst', 'R-COV-02', 'policy_not_in_force');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000014-001', 'CLM-2026-000014', '', 'submitted', '2025-12-28', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000014-002', 'CLM-2026-000014', 'submitted', 'assessed', '2025-12-31', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000014-003', 'CLM-2026-000014', 'assessed', 'approved', '2026-01-01', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000014-004', 'CLM-2026-000014', 'approved', 'paid', '2026-01-03', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000015-001', 'CLM-2026-000015', '', 'submitted', '2025-12-28', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000015-002', 'CLM-2026-000015', 'submitted', 'assessed', '2026-01-01', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000015-003', 'CLM-2026-000015', 'assessed', 'approved', '2026-01-04', 'approver', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000015-004', 'CLM-2026-000015', 'approved', 'paid', '2026-01-09', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000016-001', 'CLM-2026-000016', '', 'submitted', '2026-01-06', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000016-002', 'CLM-2026-000016', 'submitted', 'under_review', '2026-01-09', 'operations_analyst', 'R-ELG-03', 'duplicate_claim');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000017-001', 'CLM-2026-000017', '', 'submitted', '2026-01-25', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000017-002', 'CLM-2026-000017', 'submitted', 'assessed', '2026-01-28', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000017-003', 'CLM-2026-000017', 'assessed', 'approved', '2026-01-31', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000017-004', 'CLM-2026-000017', 'approved', 'paid', '2026-02-01', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000018-001', 'CLM-2026-000018', '', 'submitted', '2026-02-03', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000018-002', 'CLM-2026-000018', 'submitted', 'denied', '2026-02-05', 'operations_analyst', 'R-PAY-01', 'within_deductible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000019-001', 'CLM-2026-000019', '', 'submitted', '2026-03-17', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000019-002', 'CLM-2026-000019', 'submitted', 'docs_pending', '2026-03-20', 'operations_analyst', 'R-DOC-01', 'missing_document');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000020-001', 'CLM-2026-000020', '', 'submitted', '2026-03-25', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000020-002', 'CLM-2026-000020', 'submitted', 'under_review', '2026-03-28', 'operations_analyst', 'R-FRD-05', 'suspected_fraud');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000021-001', 'CLM-2026-000021', '', 'submitted', '2026-04-01', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000021-002', 'CLM-2026-000021', 'submitted', 'docs_pending', '2026-04-03', 'operations_analyst', 'R-DOC-01', 'missing_document');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000022-001', 'CLM-2026-000022', '', 'submitted', '2026-04-02', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000022-002', 'CLM-2026-000022', 'submitted', 'assessed', '2026-04-07', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000022-003', 'CLM-2026-000022', 'assessed', 'approved', '2026-04-09', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000022-004', 'CLM-2026-000022', 'approved', 'paid', '2026-04-13', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000023-001', 'CLM-2026-000023', '', 'submitted', '2026-04-14', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000023-002', 'CLM-2026-000023', 'submitted', 'assessed', '2026-04-17', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000023-003', 'CLM-2026-000023', 'assessed', 'approved', '2026-04-20', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000023-004', 'CLM-2026-000023', 'approved', 'paid', '2026-04-25', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000024-001', 'CLM-2026-000024', '', 'submitted', '2026-04-18', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000024-002', 'CLM-2026-000024', 'submitted', 'assessed', '2026-04-23', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000024-003', 'CLM-2026-000024', 'assessed', 'approved', '2026-04-25', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000024-004', 'CLM-2026-000024', 'approved', 'paid', '2026-04-27', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000025-001', 'CLM-2026-000025', '', 'submitted', '2026-04-30', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000025-002', 'CLM-2026-000025', 'submitted', 'assessed', '2026-05-05', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000025-003', 'CLM-2026-000025', 'assessed', 'approved', '2026-05-06', 'approver', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000025-004', 'CLM-2026-000025', 'approved', 'paid', '2026-05-07', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000026-001', 'CLM-2026-000026', '', 'submitted', '2026-05-15', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000026-002', 'CLM-2026-000026', 'submitted', 'assessed', '2026-05-18', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000026-003', 'CLM-2026-000026', 'assessed', 'approved', '2026-05-21', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000026-004', 'CLM-2026-000026', 'approved', 'paid', '2026-05-26', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000027-001', 'CLM-2026-000027', '', 'submitted', '2026-05-30', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000027-002', 'CLM-2026-000027', 'submitted', 'assessed', '2026-06-04', 'operations_analyst', 'R-PAY-01', 'limit_reached');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000027-003', 'CLM-2026-000027', 'assessed', 'approved', '2026-06-07', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000027-004', 'CLM-2026-000027', 'approved', 'paid', '2026-06-11', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000028-001', 'CLM-2026-000028', '', 'submitted', '2026-06-10', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000028-002', 'CLM-2026-000028', 'submitted', 'assessed', '2026-06-13', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000028-003', 'CLM-2026-000028', 'assessed', 'approved', '2026-06-15', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000028-004', 'CLM-2026-000028', 'approved', 'paid', '2026-06-19', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000029-001', 'CLM-2026-000029', '', 'submitted', '2026-06-22', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000029-002', 'CLM-2026-000029', 'submitted', 'denied', '2026-06-24', 'operations_analyst', 'R-COV-02', 'policy_not_in_force');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000030-001', 'CLM-2026-000030', '', 'submitted', '2026-07-06', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000030-002', 'CLM-2026-000030', 'submitted', 'assessed', '2026-07-10', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000030-003', 'CLM-2026-000030', 'assessed', 'approved', '2026-07-12', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000030-004', 'CLM-2026-000030', 'approved', 'paid', '2026-07-13', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000031-001', 'CLM-2026-000031', '', 'submitted', '2026-07-29', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000031-002', 'CLM-2026-000031', 'submitted', 'assessed', '2026-08-01', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000031-003', 'CLM-2026-000031', 'assessed', 'approved', '2026-08-04', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000031-004', 'CLM-2026-000031', 'approved', 'paid', '2026-08-07', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000032-001', 'CLM-2026-000032', '', 'submitted', '2026-08-01', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000032-002', 'CLM-2026-000032', 'submitted', 'denied', '2026-08-05', 'operations_analyst', 'R-COV-02', 'policy_not_in_force');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000033-001', 'CLM-2026-000033', '', 'submitted', '2026-08-06', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000033-002', 'CLM-2026-000033', 'submitted', 'denied', '2026-08-09', 'operations_analyst', 'R-COV-01', 'before_policy_start');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000034-001', 'CLM-2026-000034', '', 'submitted', '2026-08-21', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000034-002', 'CLM-2026-000034', 'submitted', 'assessed', '2026-08-24', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000034-003', 'CLM-2026-000034', 'assessed', 'approved', '2026-08-26', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000034-004', 'CLM-2026-000034', 'approved', 'paid', '2026-08-31', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000035-001', 'CLM-2026-000035', '', 'submitted', '2026-08-25', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000035-002', 'CLM-2026-000035', 'submitted', 'denied', '2026-08-28', 'operations_analyst', 'R-COV-01', 'before_policy_start');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000036-001', 'CLM-2026-000036', '', 'submitted', '2026-08-30', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000036-002', 'CLM-2026-000036', 'submitted', 'denied', '2026-09-03', 'operations_analyst', 'R-PAY-01', 'within_deductible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000037-001', 'CLM-2026-000037', '', 'submitted', '2026-09-07', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000037-002', 'CLM-2026-000037', 'submitted', 'assessed', '2026-09-10', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000037-003', 'CLM-2026-000037', 'assessed', 'approved', '2026-09-13', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000037-004', 'CLM-2026-000037', 'approved', 'paid', '2026-09-14', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000038-001', 'CLM-2026-000038', '', 'submitted', '2026-09-10', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000038-002', 'CLM-2026-000038', 'submitted', 'assessed', '2026-09-14', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000038-003', 'CLM-2026-000038', 'assessed', 'approved', '2026-09-15', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000038-004', 'CLM-2026-000038', 'approved', 'paid', '2026-09-18', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000039-001', 'CLM-2026-000039', '', 'submitted', '2026-09-12', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000039-002', 'CLM-2026-000039', 'submitted', 'assessed', '2026-09-17', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000039-003', 'CLM-2026-000039', 'assessed', 'approved', '2026-09-20', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000039-004', 'CLM-2026-000039', 'approved', 'paid', '2026-09-25', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000040-001', 'CLM-2026-000040', '', 'submitted', '2026-09-25', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000040-002', 'CLM-2026-000040', 'submitted', 'assessed', '2026-09-29', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000040-003', 'CLM-2026-000040', 'assessed', 'approved', '2026-10-02', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000040-004', 'CLM-2026-000040', 'approved', 'paid', '2026-10-06', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000041-001', 'CLM-2026-000041', '', 'submitted', '2026-09-29', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000041-002', 'CLM-2026-000041', 'submitted', 'docs_pending', '2026-09-30', 'operations_analyst', 'R-DOC-01', 'missing_document');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000042-001', 'CLM-2026-000042', '', 'submitted', '2026-09-30', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000042-002', 'CLM-2026-000042', 'submitted', 'under_review', '2026-10-03', 'operations_analyst', 'R-ELG-03', 'duplicate_claim');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000043-001', 'CLM-2026-000043', '', 'submitted', '2026-09-30', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000043-002', 'CLM-2026-000043', 'submitted', 'assessed', '2026-10-05', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000043-003', 'CLM-2026-000043', 'assessed', 'approved', '2026-10-08', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000043-004', 'CLM-2026-000043', 'approved', 'paid', '2026-10-13', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000044-001', 'CLM-2026-000044', '', 'submitted', '2026-10-05', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000044-002', 'CLM-2026-000044', 'submitted', 'denied', '2026-10-08', 'operations_analyst', 'R-COV-02', 'policy_not_in_force');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000045-001', 'CLM-2026-000045', '', 'submitted', '2026-10-07', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000045-002', 'CLM-2026-000045', 'submitted', 'assessed', '2026-10-11', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000045-003', 'CLM-2026-000045', 'assessed', 'approved', '2026-10-14', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000045-004', 'CLM-2026-000045', 'approved', 'paid', '2026-10-18', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000046-001', 'CLM-2026-000046', '', 'submitted', '2026-10-09', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000046-002', 'CLM-2026-000046', 'submitted', 'assessed', '2026-10-11', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000046-003', 'CLM-2026-000046', 'assessed', 'approved', '2026-10-14', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000046-004', 'CLM-2026-000046', 'approved', 'paid', '2026-10-15', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000047-001', 'CLM-2026-000047', '', 'submitted', '2026-10-14', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000047-002', 'CLM-2026-000047', 'submitted', 'denied', '2026-10-17', 'operations_analyst', 'R-COV-03', 'outside_coverage_period');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000048-001', 'CLM-2026-000048', '', 'submitted', '2026-10-16', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000048-002', 'CLM-2026-000048', 'submitted', 'assessed', '2026-10-18', 'operations_analyst', 'R-PAY-01', 'eligible');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000048-003', 'CLM-2026-000048', 'assessed', 'approved', '2026-10-19', 'process_owner', 'R-APR-01', 'approved_by_authority');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000048-004', 'CLM-2026-000048', 'approved', 'paid', '2026-10-21', 'administrator', 'R-APR-01', 'payment_recorded');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000049-001', 'CLM-2026-000049', '', 'submitted', '2026-10-17', 'requester', '', 'submitted');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000049-002', 'CLM-2026-000049', 'submitted', 'docs_pending', '2026-10-18', 'operations_analyst', 'R-DOC-01', 'missing_document');
INSERT INTO claim_status_history (event_id, claim_id, from_status, to_status, event_date, actor_role, rule_id, reason_code) VALUES ('EVT-CLM-2026-000050-001', 'CLM-2026-000050', '', 'submitted', '2026-10-22', 'requester', '', 'submitted');
COMMIT;
