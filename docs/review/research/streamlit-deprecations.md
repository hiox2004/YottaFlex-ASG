# Research note: Streamlit deprecations (Haiku worker, 2026-10-31)

Snippet-level web research; items marked UNVERIFIED were not confirmed. Context for the reviewer, not a citation source.

Sources: https://docs.streamlit.io/develop/quick-reference/release-notes/2025 , .../release-notes/2026 , https://docs.streamlit.io/develop/api-reference/data/st.dataframe , .../widgets/st.button , .../app-testing/st.testing.v1.apptest

## Findings
- `st.button` gained `width` in 1.48.0 (5 Aug 2025); `use_container_width=True` maps to `width="stretch"`, False to `"content"`.
- `st.dataframe` / `st.data_editor`: general width support from 1.46.0; `width="content"` is documented from 1.52.0. The lowest version for `width="stretch"` on `st.dataframe` is UNVERIFIED (likely 1.46.0).
- The docs call `use_container_width` deprecated "in a future release" with no date; the 2025-12-31 date appears in the runtime message only. It was not removed as of 1.66.0.
- Removed APIs we do NOT use: `st.cache` (1.62.0), `st.experimental_*` (1.49.0), `st.write(**kwargs)` (1.50.0), `use_column_width` (1.61.0), `use_container_width` on plotly/vega charts (1.57.0).
- `AppTest` (`streamlit.testing.v1`) is still supported. Behaviour changes to watch: single query params are `str` (1.65.0), form widgets commit on submit (1.65.0), stale elements cleared each rerun (1.61.0), disabled widgets raise on interaction (1.63.0).

## Recommendation from the worker
Declare `streamlit>=1.52` and migrate `use_container_width=True` to `width="stretch"`. (Done in the repo: 22 calls migrated; pin raised.)
