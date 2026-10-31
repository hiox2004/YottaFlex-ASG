# checks_business (`src/claimsgen/checks_business.py`)

**Purpose:** business validation: date order, arithmetic reconciliation, lifecycle legality, duplicates.
**Brief items:** step 8 (date ordering, arithmetic, lifecycle, duplicates), review c (lifecycle) and d (derived values).

| Check | What it verifies | Failing id |
|---|---|---|
| date order | incident <= submission; incident within policy start..end; assignment, document and assessment dates >= submission; settlement dates ordered; policy events ordered | claim, settlement or policy id |
| arithmetic | items sum to claim; assessment and settlement REPLAY from source records via `rules.payable` in processing order; first reserve = FNOL recomputed by `rules.fnol_reserve`; latest reserve = the decisive assessment's payable (0 on denial), FNOL when undecided; approved/paid amounts | assessment, settlement or reserve id |
| lifecycle | history starts at submitted and follows `TRANSITIONS`; one settlement per claim; settlement only after an approving assessment; paid needs approval; approver role matches R-APR-01; stage agrees with history | claim or settlement id (extra settlement id for paid-twice) |
| duplicates | a repeated (policy, incident date, type) must be referred or denied, never approved/pended; no repeated document type per claim | claim or document id |

Gotchas:
- Each assessment's `missing_doc_types` is recomputed from documents and requirements (pend_docs only, empty otherwise); a mismatch fails the arithmetic check.
- The replay filters items by coverage terms (R-ELG-01) before the exclusion filter, exactly as the engine does.
- The replay commits the EXPECTED amounts, so one corrupted settlement is flagged alone and later claims are unaffected.
- Only claims denied at intake by R-COV-01 may have activity before the policy start (derived from history, never from labels).

## Tests
`tests/test_validate.py`: baseline zero failures; settlement above limit flagged alone; paid-twice flags only the second settlement; illegal transition; wrong approver role; date order exemption; unreferred duplicate.
