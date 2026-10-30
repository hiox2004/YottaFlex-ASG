# draft (`src/claimsgen/draft.py`)

**Purpose:** the shape of a claim submitted through intake: `Item`, `Doc` and `Draft` (frozen dataclasses). It is the contract shared by `intake` (validation), `whatif` (evaluation), `intake_examples` and the UI.
**Brief items:** "intake claims" (the first step of the workflow).

- `claim_type` is NOT an input: the engine derives it from the policy product (the schema requires `claim_type == product`).
- Money is integer cents; `to_json()` writes amounts as exact `dollars.cents` text; `canonical()` is the one stable text form (used as a cache key).
- A draft is a claim before any rule has seen it. Business outcomes (coverage not effective, excluded item, over limit...) are decided by the engine, not rejected at validation.

## Tests
`tests/test_draft.py`.
