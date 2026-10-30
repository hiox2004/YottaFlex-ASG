# claim_build (`src/claimsgen/claim_build.py`)

**Purpose:** shared building blocks for claims: the `Spec` and `Ctx` dataclasses, legal incident windows, items, documents, and ordinary (clean) claims.
**Used by:** `claims.py` (scenario builders and assembly). Split out to keep files near 300 lines.

| Function | Role | Gotcha |
|---|---|---|
| `make_ctx(master, pol)` | indexes policies, coverages, lapse/cancel dates, document requirements, and scenario pools (lapsed, late-coverage, expired) | pools are sorted lists, so draws are deterministic |
| `draw_lag(rng)` | days between incident and submission (0-14, mostly short) | fraud scenario uses 0-3 instead |
| `latest_incident(ctx, p, lag)` | latest legal incident date: policy end, AS_OF minus lag, day before lapse/cancel | keeps ordinary claims inside the in-force window |
| `_items` | 1-3 items, lognormal amounts (right-skewed), capped at 90% of each coverage limit | cosmetic (excluded) items 8% of the time |
| `make_docs` | all mandatory docs, optional ones 50%; one doc can be omitted or arrive 10-30 days late | received_date never after AS_OF |
| `build_spec` | turns a chosen policy-coverage + incident date into a `Spec` | single-item mode is used for exact-amount boundary cases |
| `normal_spec` | draws a clean claim; optional `cents` callback fixes the amount for scenario variants | returns `None` when a drawn policy has no legal window (caller retries) |

## Tests
Covered by `tests/test_claims.py` (normal-claim cleanliness, amounts, dates, documents).
