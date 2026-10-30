# finalize (`src/claimsgen/finalize.py`)

**Purpose:** assigns final claim-derived IDs once, after injection, through a single old->new map.
**Brief items:** step 3 (zero-padded immutable IDs, identical across files), review b, and not leaking injected rows by ID position.

| Step | What happens |
|---|---|
| order | claims sorted by (submission_date, incident_date, policy_id, old claim_id), numbered `CLM-2026-000001..N`; incident `n` follows claim `n` |
| children | item, document, assignment, assessment, reserve, settlement and history rows renumbered per claim in their existing order |
| map | every renamed id is recorded in `idmap`; ground_truth is translated by lookup, never sequentially (an old id may equal another row's new id) |

Also re-sorts `policy_event` by (policy row order, date, id) so injected cancellations are not a block at the end of the table, and asserts no child row points to an unknown claim and no row is lost.

Gotchas: deleted documents leave no gaps; the appended `SET-...-002` stays second for its claim (the unavoidable paid-twice tell, documented). After finalize, ids are immutable.

## Tests
Covered in `tests/test_inject.py` (contiguous ids, order, document numbering) and by the engine-reproduction test.
