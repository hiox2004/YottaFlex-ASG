# ids (`src/claimsgen/ids.py`)

**Purpose:** the only place IDs are formatted; zero-padded and deterministic. Child IDs embed the parent ID.
**Brief items:** step 3 / deliverable 3 (five given formats, plus ours), review b.

| Function | Example |
|---|---|
| `pol(product, n)` | `POL-AUTO-2026-000001` |
| `doc(claim_id, n)` | `DOC-CLM-2026-000001-001` (literal reading of `DOC-<claim-id>-001`) |
| `settlement(claim_id, n)` | `SET-CLM-2026-000001-001`; `-002` only for paid_twice |
| `asn / asm / rsv / evt / itm / pev / pcv` | same child pattern |

Gotcha: `settlement` avoids the name `set`. 2026 is the ID series year, not the start year.
## Tests
`tests/test_ids.py` matches every formatter against the schema's PK pattern.
