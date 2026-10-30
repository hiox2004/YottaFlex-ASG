# vocab (`src/claimsgen/vocab.py`)

**Purpose:** the shared enum tuples (products, roles, claim statuses, decisions, doc/incident/item types, reason codes, ground-truth labels) plus the `PRODUCT_ALT` and `RULE_RE` regex fragments.
**Pipeline stage:** read by `schema`, and later by the generator and rules engine, so allowed values live in exactly one place.
**Brief items served:** deliverable 1 (allowed values), 5 (the six labels).

## Key items
| Item | What it does | Gotcha |
|---|---|---|
| `PRODUCTS` | AUTO HOME HLTH TRVL LIAB, one per claim type | `PRODUCT_ALT` joins them with `\|` for ID regexes |
| `CLAIM_STATUSES` | submitted, denied, docs_pending, under_review, assessed, approved, paid | claim status is the last history event, never a stored column |
| `REASON_CODES` | Why a rule decided as it did | pairs with a rule ID like `R-COV-02` (`RULE_RE`) |
| `LABELS` | 6 injected cases + baseline conditions + boundary cases | used only in `ground_truth` |

## How to test
Covered through `tests/test_schema.py` (enums feed the dictionary). Change a tuple, then rerun `python -m claimsgen.schema_docs`.
