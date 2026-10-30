"""Quality panel for the claims workflow: validation checks, planted defects, answer key and data reference.

Rendering only; every number comes from validate, schema, rules and view_data. ground_truth is shown as the answer key
and is never passed to decisions or exceptions. The panel is meant to be called from app.py as one tab.
"""

from collections import Counter

import streamlit as st

from claimsgen import rules, schema, validate, view_data

BROWSE_LIMIT = 200


def _validation_checks(checks: list) -> None:
    st.subheader("Validation checks")
    rows = [
        {
            "category": c.category,
            "name": c.name,
            "rows checked": c.checked,
            "failures": len(c.failures),
            "result": "PASS" if c.ok else "FAIL",
        }
        for c in checks
    ]
    st.dataframe(rows, hide_index=True, width="stretch")
    st.caption(
        "The failures are the two planted integrity defects: paid twice and settlement above the replayed limit."
    )


def _planted_vs_flagged(ground_truth: list, checks: list) -> None:
    st.subheader("Planted defects vs flagged")
    planted = {r["entity_id"] for r in ground_truth if r["kind"] == "integrity_defect"}
    flagged = validate.failing_ids(checks)
    cols = st.columns(3)
    cols[0].metric("Planted integrity defects", len(planted))
    cols[1].metric("Flagged by validation", len(flagged))
    cols[2].metric("Sets match exactly", "yes" if planted == flagged else "no")
    st.write(
        f"Planted but not flagged: {len(planted - flagged)}. "
        f"Flagged but not planted: {len(flagged - planted)}."
    )


def _edge_cases(ground_truth: list) -> None:
    st.subheader("Edge cases present and counted")
    counts = Counter((r["label"], r["origin"], r["kind"]) for r in ground_truth)
    rows = [
        {"label": label, "origin": origin, "kind": kind, "rows": n}
        for (label, origin, kind), n in sorted(counts.items())
    ]
    st.dataframe(rows, hide_index=True, width="stretch")


def _answer_key(ground_truth: list) -> None:
    st.subheader("Answer key (ground_truth)")
    st.caption("Used for scoring only; decisions and exceptions never read it")
    st.dataframe(ground_truth, hide_index=True, width="stretch")


def _data_dictionary() -> None:
    st.subheader("Data dictionary")
    name = st.selectbox("Table", [t.name for t in schema.TABLES], key="q_table")
    table = schema.TABLE_BY_NAME[name]
    st.caption(table.description)
    rows = [
        {
            "field": f.name,
            "type": f.type,
            "required": f.required,
            "allowed values": f.allowed,
            "unit": f.unit,
            "unique": f.unique,
            "FK": f.fk,
            "rule": f.rule,
        }
        for f in table.fields
    ]
    st.dataframe(rows, hide_index=True, width="stretch")


def _rule_catalogue() -> None:
    st.subheader("Rule catalogue")
    rows = [{"rule id": k, "description": v} for k, v in rules.RULES.items()]
    st.dataframe(rows, hide_index=True, width="stretch")


def _table_browser(tables: dict) -> None:
    st.subheader("Table browser")
    name = st.selectbox("Dataset table", list(tables), key="q_browse")
    rows = tables[name][:BROWSE_LIMIT]
    st.caption(f"First {len(rows)} of {len(tables[name])} rows.")
    st.dataframe(view_data.display(name, rows), hide_index=True, width="stretch")


def render(tables, ground_truth, checks, decisions=None):
    """Render the quality panel. `decisions` (view_data.decisions_table rows) is accepted for callers and not shown here."""
    _validation_checks(checks)
    _planted_vs_flagged(ground_truth, checks)
    _edge_cases(ground_truth)
    _answer_key(ground_truth)
    _data_dictionary()
    _rule_catalogue()
    _table_browser(tables)
