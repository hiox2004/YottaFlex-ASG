# claim_prompt

Source: `src/claimsgen/claim_prompt.py`. Tests: `tests/test_claim_prompt.py`.

## Purpose
`build(tables, scenario)` returns a copy-and-paste prompt for any AI chat that asks it to write one test claim as JSON for the
Submit a claim tab. It lists one real policy per product (dates, incident types, mandatory documents, each coverage with limit,
deductible and covered item types) taken from the dataset INPUT tables, plus the form rules, so the JSON that comes back validates.
The last line is the scenario the reviewer wants to test.

## Notes
- Placeholders are `@HORIZON@` and `@WINDOW@` replaced with `str.replace`, because the JSON shape in the text contains braces.
- The pasted claim still goes through `intake.parse_and_validate` and the rules; the chat never decides an outcome.
- No ground_truth, randomness or clock. Shown in an expander in `app_intake.py` with `st.code` (copy button).
