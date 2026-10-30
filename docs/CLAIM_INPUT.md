# Claim intake template

**Purpose.** This is the form a reviewer fills in to submit one new claim to the workflow. The workflow checks the form for structure and format only, then evaluates the claim against the rules. Rules decide the outcome; the form does not.

## Template

```json
{
  "policy_id": "POL-AUTO-2026-000001",
  "incident_date": "2026-09-14",
  "incident_type": "collision",
  "submission_date": "2026-09-18",
  "items": [
    {"coverage_id": "COV-AUTO-001", "item_type": "repair", "amount": 1850.00}
  ],
  "documents": [
    {"doc_type": "repair_estimate", "received_date": "2026-09-19", "status": "received"}
  ]
}
```

The IDs in the example are illustrative. Use a policy, coverage and dates from the dataset you are reviewing.

## Fields

| Field | Type | Required | Rule |
|---|---|---|---|
| `policy_id` | text (id) | yes | Must exist in the policy table. Format `POL-<PRODUCT>-2026-NNNNNN`. |
| `incident_date` | date (`YYYY-MM-DD`) | yes | ISO date. Must not be after `submission_date`. |
| `incident_type` | enum | yes | One of the incident types. Must be valid for the policy product. |
| `submission_date` | date (`YYYY-MM-DD`) | yes | ISO date. Between `incident_date` and the intake horizon. |
| `items` | list, 1 to 20 objects | yes | Each object is one claimed line. |
| `items[].coverage_id` | text (id) | yes | Format `COV-<PRODUCT>-NNN`. Must exist and belong to the policy. |
| `items[].item_type` | enum | yes | One of the item types. |
| `items[].amount` | number (USD) | yes | Greater than 0, at most 2 decimals. Stored as integer cents. |
| `documents` | list of objects | no | Zero or more. Missing documents are decided by rules, not by the form. |
| `documents[].doc_type` | enum | yes | One of the document types. |
| `documents[].received_date` | date (`YYYY-MM-DD`) | yes | ISO date. Between `submission_date` and the intake horizon. |
| `documents[].status` | enum | yes | `received` or `rejected`. |

The intake horizon is the dataset date 2026-10-22 plus 30 days, which is 2026-11-21.

## What validation rejects

These are structure and format checks only. A form that fails one of them is not evaluated.

| Check | Rejects when |
|---|---|
| Policy exists | `policy_id` is not in the policy table. |
| ISO dates | Any date is not `YYYY-MM-DD` or is not a real calendar date. |
| Date order | `incident_date` is after `submission_date`, or `submission_date` is after the intake horizon. |
| Document dates | A `received_date` is before `submission_date` or after the intake horizon. |
| Incident type | `incident_type` is not valid for the policy product. |
| Coverage belongs to policy | An item's `coverage_id` does not exist or is not a coverage of the policy. |
| Vocabularies | An `item_type` or `doc_type` is outside its vocabulary. |
| Amount | An `amount` is 0 or negative, or has more than 2 decimals. |
| Item count | There are fewer than 1 or more than 20 items. |

## What validation does not reject

The following are outcomes of the rules. The form is accepted and the claim is decided, denied, pended or referred by the rule shown.

| Situation | Rule |
|---|---|
| Coverage not effective on the incident date | R-COV-03 |
| Incident before policy start, or after lapse or cancellation | R-COV-02 |
| Submission before policy start | R-COV-01 |
| Excluded item types | R-ELG-02 |
| Amount over the limit | R-PAY-01 |
| Amount within the deductible | R-PAY-01 |
| Mandatory documents missing or late | R-DOC-01 |
| Duplicate of an earlier claim (same policy, incident date and claim type) | R-ELG-03 |

## Notes

- `claim_type` is derived from the policy product. It is not an input.
- A submitted claim is evaluated as a what-if on a copy of the dataset. The dataset is never changed. The claim is treated as inserted at its `submission_date`. Existing claims submitted after that date are ignored.
- The evaluation horizon is the dataset date plus 30 days, so a recent claim shows the whole workflow rather than stopping at the as-of date.
- "Request missing documents" adds the documents that were received after the 5-day document window, then re-evaluates the claim. This is the pend-and-resume path: a claim pended for documents resumes once they arrive.
- No AI is involved in intake. The decision path is deterministic rules, so the same form on the same dataset always gives the same result.
