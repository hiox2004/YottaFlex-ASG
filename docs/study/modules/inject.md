# inject (`src/claimsgen/inject.py`)

**Purpose:** pipeline step 5: plants the six mandatory labelled edge cases into a clean baseline (15 rows each at full scale).
**Brief items:** step 5 (inject after a clean baseline, labelled), review e (failure/exception coverage), review f (labels kept out of inputs).

## How targets are chosen
Clean (never planted) claims, live status (assessed/approved/paid), whose policy AND customer have exactly one claim. That isolation means
changing one claim cannot alter limits, duplicate detection or the customer's F2 window for any other claim. Target sets are disjoint
(`_take` marks used claims). Integrity defects are drawn first from the scarcer paid single-coverage pool.

| Case | Kind | Mutation | Engine outcome |
|---|---|---|---|
| claim_before_policy_start | business | incident and submission moved before start, docs shifted | denied R-COV-01 |
| cancelled_before_incident | business | `cancelled` policy_event before the incident | denied R-COV-02 |
| duplicate_incident | business | new claim cloning policy/date/type/items/docs, submitted 1-10 days later | later claim under_review R-ELG-03 |
| missing_mandatory_doc | business | delete one mandatory document | docs_pending, no settlement |
| settlement_exceeds_limit | integrity | settlement amounts raised to 105-140% of the limit AFTER the engine | validator flags the SET row |
| paid_twice | integrity | second paid settlement `SET-...-002` appended AFTER the engine | validator flags the second SET row |

Business cases mutate inputs then re-run the whole engine; integrity cases patch outputs and are never re-run (a re-run would repair them).
Injected duplicates have temporary ids (900001+); `finalize` renumbers everything. `inject()` returns labels separately as `injected` entries.

## Tests
`tests/test_inject.py`: counts, label shape, validator flags exactly the defects, rules decide the business cases, engine reproduces outputs except the patched rows, ids final and contiguous, targets isolated and unique, determinism, starter scale.
