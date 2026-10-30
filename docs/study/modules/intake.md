# intake (`src/claimsgen/intake.py`)

**Purpose:** turn one raw claim submission (a dict or JSON text) into a `Draft`, or into a complete list of field errors. This is the first step of the workflow; it decides only whether the input is well formed.
**Pipeline stage:** step 1 of the workflow (intake). It runs before coverage, documents, eligibility and settlement routing, which all read the `Draft` it returns.
**Brief items served:** "intake claims"; the input contract in `docs/SPEC.md`.

## Inputs and outputs
- Takes: `raw` (a dict or a JSON string) and `tables` (the dataset tables: `policy`, `policy_coverage`, `coverage`).
- Produces: `(draft, [])` when valid, or `(None, errors)` where each error is `{"field": "items[0].amount", "message": "..."}`. Invalid JSON gives one error with field `"$"`.

## Input template
```json
{
  "policy_id": "POL-HLTH-2026-000001",
  "incident_date": "2026-10-01",
  "incident_type": "illness",
  "submission_date": "2026-10-10",
  "items": [{"coverage_id": "COV-HLTH-001", "item_type": "medical_treatment", "amount": "420.50"}],
  "documents": [{"doc_type": "invoice", "received_date": "2026-10-10", "status": "received"}]
}
```
`documents` is optional. `status` is optional and defaults to `"received"`. `claim_type` is never an input.

## Rule table

| Rule | Checked | Error field |
|---|---|---|
| Input is a JSON object (dict or parseable JSON text) | yes | `$` |
| Required keys present: policy_id, incident_date, incident_type, submission_date, items | yes | the key name |
| Unknown keys are errors | yes | the key path |
| `claim_type` supplied: "derived from the policy and must be removed" | yes | `claim_type` |
| `policy_id` exists in `tables["policy"]` | yes | `policy_id` |
| `incident_date`, `submission_date`, `received_date` are ISO dates | yes | the date field |
| `incident_date <= submission_date` | yes | `incident_date` |
| `submission_date <= config.intake_horizon()` | yes | `submission_date` |
| `received_date >= submission_date` and `<= intake_horizon()` | yes | `documents[i].received_date` |
| `incident_type` is valid for the policy product (union of the incident types of the product's coverages) | yes | `incident_type` |
| `items`: 1 to 20 entries | yes | `items` |
| `coverage_id` is a coverage on THAT policy (`policy_coverage` rows) | yes | `items[i].coverage_id` |
| `item_type` in `vocab.ITEM_TYPES` | yes | `items[i].item_type` |
| `amount` parsed with `Decimal(str(value))`, finite, > 0, at most 2 decimal places, at most 10,000,000 USD, converted to integer cents | yes | `items[i].amount` |
| `documents`: at most 20 entries | yes | `documents` |
| `doc_type` in `vocab.DOC_TYPES` | yes | `documents[i].doc_type` |
| `status` in ("received", "rejected") when given | yes | `documents[i].status` |
| Duplicate doc types | allowed (the engine uses sets) | none |
| Numbers accepted for `amount`; bools, null and lists are not | yes | `items[i].amount` |

### Deliberately NOT validated (the rules engine decides these)
These are VALID inputs. Rejecting them at intake would hide the business outcome the workflow must record.
- Coverage not effective on the incident date.
- Incident before the policy start, or after a lapse or cancellation.
- Submission before the policy start.
- An excluded item type (for example `cosmetic` on a coverage that excludes it).
- An amount over the policy limit, or within the deductible.

The tests in `tests/test_intake.py` prove each of these is accepted.

## How errors look
Every problem is collected, not only the first. An example with three errors:
```python
[
    {"field": "claim_type", "message": "claim_type is derived from the policy and must be removed"},
    {"field": "items[0].amount", "message": "must be greater than 0"},
    {"field": "documents[0].received_date", "message": "must be on or after 2026-10-10"},
]
```
If the `policy_id` is unknown, the policy-dependent checks (incident type, coverage on the policy) are skipped, so the errors stay about the input that is actually wrong.

## Key functions
| Function | What it does | Why it exists / gotcha |
|---|---|---|
| `parse_and_validate(raw, tables)` | Returns `(draft, [])` or `(None, errors)` | The single entry point |
| `_parse_amount(value)` | Exact decimal parse to integer cents, or a problem message | Never float math. `Decimal(str(12.5))` is exact; the quantize check rejects `0.001` |
| `_incident_types(tables, product)` | Sorted union of the incident types of the product's coverages | Uses `masterdata.COVERAGE_PROFILE` |
| `_check_keys(obj, required, optional, prefix, errors)` | Missing and unknown keys | Gives the `claim_type` message |

## Rules / invariants it must keep
- Validation never rejects a business outcome (see the table above).
- Money is integer cents; amounts are parsed with `Decimal`, never `float`.
- Every error is `{"field", "message"}`; the function never raises on bad input.
- A draft that comes back has passed every rule, so `Draft.to_json()` round-trips to an equal draft.

## Worked example
`"4200.50"` becomes `Item(..., cents=420050)`. `"0.001"` is rejected (more than 2 decimal places). `"-5"` is rejected (not greater than 0). `12.5` (a number) becomes `1250`.

## How to test / inspect
`python -m pytest tests/test_intake.py -q`. The module fixture builds the starter dataset (`generate.build_dataset(0.05)`) once and picks a real policy from it.

## Open questions / next
- The incident-type union reads the coverage catalogue, not the policy's own coverages; a policy sells only some of them. This matches the brief's rule, and the engine checks coverage on the policy.
