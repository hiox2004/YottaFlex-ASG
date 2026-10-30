# One claim, end to end

Customer Asha holds `POL-AUTO-2026-000123` (AUTO, 2025-11-01 to 2026-10-31, collision limit 20,000, deductible 500).

1. **Incident** 2026-06-10 collision -> `INC-2026-000321`.
2. **Claim** filed 2026-06-12 -> `CLM-2026-000210`, one item 4,200 on the collision coverage. History: `submitted` (requester).
3. **Coverage checks** R-COV-01 (filed after start) ok; R-COV-02 (policy in force on 06-10) ok; R-COV-03 (inside coverage dates) ok.
4. **Duplicate check** R-ELG-03: no earlier claim on same policy/date/type -> ok.
5. **Documents** R-DOC-01: AUTO needs photo + police report; only the photo exists -> `docs_pending`, no payout. History records the pause with reason `missing_document`.
6. Police report arrives 06-20 -> re-run: docs ok.
7. **Fraud flags** F1-F4: none -> score 0.
8. **Eligibility** item covered, no exclusion -> eligible 4,200.
9. **Payable** R-PAY-01: min(max(0, 4,200 - 500), remaining limit 20,000) = 3,700. **Reserve** RSV row: 3,700 (preliminary, then revised since the first run had none).
10. **Settlement** recommended 3,700; under threshold so `process_owner` approves; payment recorded. Each step is one row in `claim_status_history` with actor role + rule ID.

Later, the generator may *inject* a defect (e.g. a second paid settlement) and write the label only to `ground_truth`.
The validator then must find exactly that row; the precision/recall report scores it.

Pipeline: master data -> policies -> incidents/claims/items/docs -> rules engine -> baseline validation -> injection -> final IDs -> export + reports.
