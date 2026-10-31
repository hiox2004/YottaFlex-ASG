"""Minimal view of the claims workflow: decisions, exceptions, per-claim timeline and metrics.

Rendering only; every number comes from claimsgen.view_data (tested). Run: streamlit run app.py   (pip install -e ".[ui]")
"""

import app_intake
import app_quality
import streamlit as st

from claimsgen import SEED, view_data

DATASETS = {
    "Starter (100 policies, 50 claims)": 0.05,
    "Medium (500 policies, 250 claims)": 0.25,
    "Full (2,000 policies, 1,000 claims)": 1.0,
}

st.set_page_config(page_title="Claims workflow", layout="wide")


@st.cache_data(show_spinner="Building dataset...")
def load(scale: float):
    return view_data.load(scale)


@st.cache_data(show_spinner="Computing metrics and threshold sweep...")
def metrics_panel(scale: float):
    tables, ground_truth, checks = load(scale)
    return view_data.metrics_panel(tables, ground_truth, checks)


@st.cache_data
def checksum(scale: float) -> str:
    return view_data.dataset_checksum(load(scale)[0])


st.title("Claims workflow: decisions, exceptions, traceability")
choice = st.sidebar.selectbox("Dataset scale", list(DATASETS), key="dataset")
scale = DATASETS[choice]
tables, ground_truth, checks = load(scale)
st.sidebar.text_input("Seed (fixed by the brief)", str(SEED), disabled=True, key="seed")
st.sidebar.caption("Fixed as-of date 2026-10-22. All data is synthetic.")
st.sidebar.caption(
    "Workflow: intake, coverage validation, document request, eligibility, settlement routing."
)

st.caption("Start with an example claim in 'Submit a claim', or open Decisions / Metrics.")

decisions = view_data.decisions_table(tables)
(
    tab_submit,
    tab_decisions,
    tab_exceptions,
    tab_claim,
    tab_metrics,
    tab_realism,
    tab_repro,
    tab_quality,
) = st.tabs(
    [
        "Submit a claim",
        "Decisions",
        "Exceptions",
        "Claim timeline",
        "Metrics",
        "Realism",
        "Reproducibility",
        "Quality and data",
    ]
)

with tab_submit:
    app_intake.render(tables, scale)

with tab_quality:
    app_quality.render(tables, ground_truth, checks)

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
    st.dataframe(shown, hide_index=True, width="stretch")

with tab_exceptions:
    st.caption("Derived from engine output and validator failures, never from ground truth.")
    found = view_data.exceptions(tables, checks)
    st.dataframe(
        [{"exception": k, "rows": len(v)} for k, v in found.items()],
        hide_index=True,
        width="stretch",
    )
    pick = st.selectbox("Show", list(found), key="exception")
    st.dataframe(found[pick], hide_index=True, width="stretch")

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
    st.dataframe(detail["timeline"], hide_index=True, width="stretch")
    st.subheader("Rule trace (decision path)")
    st.dataframe(view_data.rule_trace(tables, claim_id), hide_index=True, width="stretch")
    st.subheader("What would make it payable")
    st.markdown("\n".join(f"- {t}" for t in view_data.counterfactual(tables, claim_id)))
    for name in (
        "claim_item",
        "document",
        "claim_adjuster_assignment",
        "assessment",
        "reserve",
        "settlement",
    ):
        with st.expander(f"{name} ({len(detail[name])})"):
            st.dataframe(view_data.display(name, detail[name]), hide_index=True, width="stretch")

with tab_metrics:
    panel = metrics_panel(scale)
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
        width="stretch",
    )
    rv = op["reserve_vs_final"]
    st.write(
        f"Reserve: FNOL {rv['fnol_all'] / 100:,.0f} USD at submission, {rv['final_reserve_all'] / 100:,.0f} USD after revision ({rv['revised_claims']} claims revised). {rv['settled_claims']} settled claims, {rv['mismatched_claims']} where the settlement differs from the latest reserve."
    )
    st.subheader("By claim type")
    st.dataframe(
        [{"type": t, **v} for t, v in op["by_claim_type"].items()],
        hide_index=True,
        width="stretch",
    )
    st.subheader("Rule impact (final assessment per claim, USD)")
    st.caption("Blocked and held amounts are the claimed amount; reduced is claimed minus payable.")
    st.dataframe(
        [
            {
                "rule/effect": k,
                "claims": v["claims"],
                "usd": v["amount_cents"] / 100,
            }
            for k, v in op["by_rule"].items()
        ],
        hide_index=True,
        width="stretch",
    )
    tl = op["straight_through"]
    st.write(
        f"Straight-through (no exception) rate: {tl['straight_through']} of {tl['assessed']} assessed claims "
        f"({tl['straight_through_rate']:.1%}); {tl['reviewed']} others, of which {tl['human_step']} pended for "
        "documents or went to review. Every decision is automated here; actor roles show who would own the step in a real operation."
    )
    st.subheader("Approver workload")
    st.dataframe(
        [
            {"role": r, "settlements": v["settlements"], "usd": v["amount_cents"] / 100}
            for r, v in op["approver_workload"].items()
        ],
        hide_index=True,
        width="stretch",
    )
    ag = op["docs_pending_aging"]
    st.write(
        f"Docs pending aging: {ag['count']} claims, mean {ag['mean_days']} days, median {ag['median_days']}, "
        f"p90 {ag['p90_days']}, max {ag['max_days']}; {ag['older_than_14_days']} older than 14 days, "
        f"{ag['older_than_30_days']} older than 30, {ag['older_than_90_days']} older than 90. "
        "There is no document-chase SLA or closure."
    )
    st.subheader("Cycle time by claim type (submission to paid, days)")
    st.dataframe(
        [{"type": t, **v} for t, v in op["cycle_by_claim_type"].items()],
        hide_index=True,
        width="stretch",
    )
    sens = panel["sensitivity"]
    st.subheader("Threshold sensitivity")
    st.caption(
        "The engine is re-run with one threshold changed at a time; the current row is marked."
    )
    st.dataframe(
        [
            {
                "approver threshold (USD)": r["value"] / 100,
                "current": r["current"],
                "settlements to approver": r["approver_settlements"],
                "amount to approver (USD)": r["approver_amount_cents"] / 100,
            }
            for r in sens["approver"]
        ],
        hide_index=True,
        width="stretch",
    )
    st.dataframe(
        [
            {
                "fraud cutoff": r["value"],
                "current": r["current"],
                "fraud referred": r["fraud_referred"],
                "flagged amount (USD)": r["flagged_amount_cents"] / 100,
                "precision": r["precision"],
                "recall": r["recall"],
            }
            for r in sens["fraud"]
        ],
        hide_index=True,
        width="stretch",
    )
    st.subheader("Precision and recall vs ground truth")
    st.caption(
        "Predictions come from engine output, input data and validator failures only. Unassessed recent claims count as misses."
    )
    st.dataframe(panel["scoring"], hide_index=True, width="stretch")

with tab_realism:
    real = view_data.realism(tables)
    st.caption("Distributions of the generated claims, to judge whether the data looks plausible.")
    stats = real["claimed_stats_usd"]
    st.write(
        f"Claimed amount (USD): median {stats['median']:,.2f}, mean {stats['mean']:,.2f}, "
        f"p90 {stats['p90']:,.2f}"
    )
    st.subheader("Claimed amount (USD bins)")
    st.bar_chart(real["claimed_histogram"], x="bin_usd", y="count")
    left, right = st.columns(2)
    with left:
        st.subheader("Claim type mix")
        st.dataframe(
            [{"type": k, "claims": v} for k, v in real["claim_type_mix"].items()],
            hide_index=True,
            width="stretch",
        )
    with right:
        st.subheader("Policy status at the as-of date")
        st.dataframe(
            [{"status": k, "policies": v} for k, v in real["policy_status"].items()],
            hide_index=True,
            width="stretch",
        )
    st.subheader("Days from incident to submission")
    st.bar_chart(real["lag_days"], x="bin_days", y="count")

with tab_repro:
    st.caption("The seed is fixed by the brief; the same seed and scale must give the same bytes.")
    st.write(f"Seed: {SEED} (read-only). Scale: {scale}.")
    st.code(checksum(scale), language="text")
    st.caption("SHA-256 over the canonical CSV text of the input tables in schema order.")
    if st.button("Rebuild and compare", key="rebuild"):
        with st.spinner("Building the dataset again..."):
            same, one, two = view_data.rebuild_and_compare(scale)
        if same and one == checksum(scale):
            st.success(f"Identical rebuild: {one}")
        else:
            st.error(f"Rebuild differs: {one} vs {two}")
