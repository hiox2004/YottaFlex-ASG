# masterdata (`src/claimsgen/masterdata.py`)

**Purpose:** pipeline step 1: customer, coverage catalogue, adjuster, document_requirement (parents first).
**Brief items:** step 2 parent tables, deliverable 2; document_requirement makes "missing mandatory document" a computed result.

| Function | What it does | Gotcha |
|---|---|---|
| `customers(n)` | names/dob/region/created_date | `created_date` is always before 2024 so any policy start follows it; dob gives age 19-85 |
| `coverage()` | 16 catalogue rows (2-4 per product) from `CATALOGUE` | money in integer cents; exclusion codes are `ITEM_TYPES` (`cosmetic`) |
| `adjusters(n)` | specialty cycles through products so every product is covered | |
| `document_requirements()` | 2+ mandatory doc types per claim type | `drq` ID uses the upper-cased doc type |
| `generate(scale)` | returns `{table: rows}` | rows are dicts keyed by schema field names; dates are `date`, money is int cents |

`COVERAGE_PROFILE` maps each coverage name to its incident types and item types (used by claims).

Name lists are our own, so no Faker and no outside data (see SOURCE_MANIFEST).
## Tests
`tests/test_generation.py`: counts, FK/ID/schema match, age range, specialty coverage, catalogue sanity.
