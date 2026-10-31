# claim_build (`src/claimsgen/claim_build.py`)

**Purpose:** shared building blocks for claims: the `Spec` and `Ctx` dataclasses, legal incident windows, items, documents, and ordinary (clean) claims.
**Used by:** `claims.py` (scenario builders and assembly). Split out to keep files near 300 lines.

| Function | Role | Gotcha |
|---|---|---|
| `make_ctx(master, pol)` | indexes policies, coverages, lapse/cancel dates, document requirements, and scenario pools (lapsed, late-coverage, expired) | pools are sorted lists, so draws are deterministic |
| `draw_lag(rng, product, max_lag=None)` | days between incident and submission: 0 to 120, mostly short with a long tail (LIAB reports later, `LIAB_LAG_WEIGHTS`); `max_lag` keeps the over-limit and at-limit scenarios inside the F4 window | fraud scenario uses 0-3 instead; every caller passes the policy product |
| `Ctx.exposure`, `Ctx.cum_exposure` | days each policy was in force before AS_OF (at least 1), and the running total | `normal_spec` picks the policy with `rng.choices(ids, cum_weights=cum_exposure)`, so claims follow exposure: young policies get fewer claims and F1 falls to its organic rate; short TRVL terms mean fewer travel claims |
| `latest_incident(ctx, p, lag)` | latest legal incident date: policy end, AS_OF minus lag, day before lapse/cancel | keeps ordinary claims inside the in-force window |
| `_items` | 1-3 items (the incident type is drawn first in `build_spec`; a secondary coverage is used only if it covers that incident type), lognormal amounts with a per-coverage median and sigma from `masterdata.SEVERITY` (independent of the limit), capped at 90% of each coverage limit; an overflowing coverage is scaled to a random 40-100% of the cap so totals do not pile up at 90% | cosmetic (excluded) items 8% of the time |
| `make_docs` | all mandatory docs, optional ones 50%; one doc can be omitted, arrive 10-30 days late, or arrive on time as `rejected` (docs are `(doc_type, received_date, status)` triples) | received_date never after AS_OF |
| `build_spec` | turns a chosen policy-coverage + incident date into a `Spec` | single-item mode is used for exact-amount boundary cases |
| `normal_spec` | draws a clean claim; optional `cents` callback fixes the amount for scenario variants | returns `None` when a drawn policy has no legal window (caller retries) |

## Tests
Covered by `tests/test_claims.py` (normal-claim cleanliness, amounts, dates, documents).
