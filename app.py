"""Minimal view of the claims workflow: decisions, exceptions, per-claim timeline and metrics.

Rendering only; every number comes from claimsgen.view_data (tested). Run: streamlit run app.py   (pip install -e ".[ui]")
"""

import streamlit as st

from claimsgen import view_data

DATASETS = {"Starter (100 policies, 50 claims)": 0.05, "Full (2,000 policies, 1,000 claims)": 1.0}

st.set_page_config(page_title="Claims workflow", layout="wide")


@st.cache_data(show_spinner="Building dataset...")
def load(scale: float):
    return view_data.load(scale)


st.title("Claims workflow: decisions, exceptions, traceability")
choice = st.sidebar.selectbox("Dataset", list(DATASETS), key="dataset")
tables, ground_truth, checks = load(DATASETS[choice])
st.sidebar.caption("Seed 20261022, fixed as-of date 2026-10-22. All data is synthetic.")
st.sidebar.caption(
    "Workflow: intake, coverage validation, document request, eligibility, settlement routing."
)

decisions = view_data.decisions_table(tables)
tab_decisions, tab_exceptions, tab_claim, tab_metrics = st.tabs(
    ["Decisions", "Exceptions", "Claim timeline", "Metrics"]
)

with tab_decisions:
    st.caption(
        "Latest decision per claim with the rule and reason that produced it and the role that acted last."
    )
    cols = st.columns(3)
    status = cols[0].multiselect("Status", sorted({d["status"] for d in decisions}), key="f_status")
    decision = cols[1].multiselect(
        "Decision", sorted({d["decision"] for d in decisions}), key="f_decision"
    )
    ctype = cols[2].multiselect(
        "Claim type", sorted({d["claim_type"] for d in decisions}), key="f_type"
    )
    shown = [
        d
        for d in decisions
        if (not status or d["status"] in status)
        and (not decision or d["decision"] in decision)
        and (not ctype or d["claim_type"] in ctype)
    ]
    st.write(f"{len(shown)} of {len(decisions)} claims")
    st.dataframe(shown, hide_index=True, use_container_width=True)

with tab_exceptions:
    st.caption("Derived from engine output and validator failures, never from ground truth.")
    found = view_data.exceptions(tables, checks)
    st.dataframe(
        [{"exception": k, "rows": len(v)} for k, v in found.items()],
        hide_index=True,
        use_container_width=True,
    )
    pick = st.selectbox("Show", list(found), key="exception")
    st.dataframe(found[pick], hide_index=True, use_container_width=True)

with tab_claim:
    claim_id = st.selectbox("Claim", [d["claim_id"] for d in decisions], key="claim")
    detail = view_data.claim_detail(tables, claim_id)
    row = next(d for d in decisions if d["claim_id"] == claim_id)
    a, b, c, d = st.columns(4)
    a.metric("Status", row["status"])
    b.metric("Decision", row["decision"])
    c.metric("Rule", row["rule_id"] or "-")
    d.metric("Payable (USD)", f"{row['payable_usd']:,.2f}")
    st.subheader("Status timeline (append-only history)")
    st.dataframe(detail["timeline"], hide_index=True, use_container_width=True)
    for name in (
        "claim_item",
        "document",
        "claim_adjuster_assignment",
        "assessment",
        "reserve",
        "settlement",
    ):
        with st.expander(f"{name} ({len(detail[name])})"):
            st.dataframe(
                view_data.display(name, detail[name]), hide_index=True, use_container_width=True
            )

with tab_metrics:
    panel = view_data.metrics_panel(tables, ground_truth, checks)
    op = panel["operational"]
    cols = st.columns(len(op["counts"]))
    for col, (name, n) in zip(cols, op["counts"].items(), strict=True):
        col.metric(name.replace("_", " "), n, f"{op['rates'][name]:.1%}", delta_color="off")
    st.write(
        f"Days to approval: median {op['days_to_approval']['median']}, p90 {op['days_to_approval']['p90']}. "
        f"Days to settlement: median {op['days_to_settlement']['median']}, p90 {op['days_to_settlement']['p90']}."
    )
    st.subheader("Amounts (USD)")
    st.dataframe(
        [{"measure": k, "usd": v / 100} for k, v in op["amounts_cents"].items()],
        hide_index=True,
        use_container_width=True,
    )
    rv = op["reserve_vs_final"]
    st.write(
        f"Reserve vs final: {rv['settled_claims']} settled claims, {rv['mismatched_claims']} where the settlement differs from the reserve."
    )
    st.subheader("By claim type")
    st.dataframe(
        [{"type": t, **v} for t, v in op["by_claim_type"].items()],
        hide_index=True,
        use_container_width=True,
    )
    st.subheader("Precision and recall vs ground truth")
    st.caption(
        "Predictions come from engine output, input data and validator failures only. Unassessed recent claims count as misses."
    )
    st.dataframe(panel["scoring"], hide_index=True, use_container_width=True)
