"""Submit-a-claim tab: enter a claim as JSON (or from a small form), run it through the real engine as a what-if and show
the decision path. Rendering only; every number comes from claimsgen.intake and claimsgen.whatif. No ground_truth, no clock.
"""

import json

import streamlit as st

from claimsgen import config, intake, intake_examples, view_data, vocab, whatif

MAX_SESSION = 50
MAX_JSON_CHARS = 50_000
SCALE_KEYS = ("intake_results", "intake_errors", "intake_last", "intake_json", "intake_example")


def _examples(tables, scale):
    """Examples are built once per scale and kept in the session (tables is not hashable for st.cache_data).
    Returns None (and shows an error) when the dataset has no suitable policy for an example."""
    key = f"intake_examples_{scale}"
    if key not in st.session_state:
        try:
            st.session_state[key] = intake_examples.build(tables)
        except (StopIteration, LookupError, ValueError) as e:
            st.error(f"Example claims cannot be built for this dataset ({type(e).__name__}: {e}).")
            return None
    return st.session_state[key]


def _summary(draft, result):
    d = result["decision"]
    return {
        "number": len(st.session_state["intake_results"]) + 1,
        "policy": draft.policy_id,
        "decision": d["decision"],
        "rule": d["rule_id"],
        "status": d["status"],
    }


def _store(tables, draft):
    """Evaluate and remember the draft as the last one; an identical consecutive submission is not added again."""
    scale = st.session_state.get("intake_scale")
    st.session_state["intake_last"] = draft
    results = st.session_state.setdefault("intake_results", [])
    if results and results[-1]["draft"] == draft.canonical() and results[-1]["scale"] == scale:
        return
    result = whatif.evaluate(tables, draft)
    results.append(
        {
            "draft": draft.canonical(),
            "scale": scale,
            "summary": _summary(draft, result),
            "result": result,
        }
    )
    del results[:-MAX_SESSION]


def _load_example(examples):
    by_title = {e.title: e for e in examples}
    st.session_state["intake_json"] = json.dumps(
        by_title[st.session_state["intake_example"]].draft.to_json(), indent=2
    )
    st.session_state["intake_errors"] = []


def _submit(tables):
    draft, errors = intake.parse_and_validate(st.session_state["intake_json"], tables)
    st.session_state["intake_errors"] = errors
    if draft is not None:
        _store(tables, draft)


def _request_docs(tables):
    """Request the missing documents for the LAST EVALUATED draft (not the possibly edited text box)."""
    draft = st.session_state.get("intake_last")
    if draft is None:
        return
    st.session_state["intake_errors"] = []
    nxt = whatif.request_docs(tables, draft)
    st.session_state["intake_json"] = json.dumps(nxt.to_json(), indent=2)
    _store(tables, nxt)


def _clear():
    st.session_state["intake_results"] = []
    st.session_state["intake_errors"] = []
    st.session_state["intake_last"] = None


def _reset_for_scale(scale):
    """Switching the dataset scale drops everything that belongs to the old one."""
    if st.session_state.get("intake_scale") != scale:
        for k in SCALE_KEYS:
            st.session_state.pop(k, None)
        st.session_state["intake_scale"] = scale


def _from_form():
    f = st.session_state
    claim = {
        "policy_id": f["intake_f_policy"],
        "incident_date": f["intake_f_incident"].isoformat(),
        "incident_type": f["intake_f_type"],
        "submission_date": f["intake_f_submitted"].isoformat(),
        "items": [
            {
                "coverage_id": f["intake_f_coverage"],
                "item_type": f["intake_f_item"],
                "amount": f"{f['intake_f_amount']:.2f}",
            }
        ],
        "documents": [
            {"doc_type": t, "received_date": f["intake_f_submitted"].isoformat()}
            for t in f["intake_f_docs"]
        ],
    }
    f["intake_json"] = json.dumps(claim, indent=2)
    f["intake_errors"] = []


def _form(tables):
    with st.expander("Fill in from a form"):
        policies = sorted(p["policy_id"] for p in tables["policy"])
        policy = st.selectbox("Policy", policies, key="intake_f_policy")
        product = next(p["product"] for p in tables["policy"] if p["policy_id"] == policy)
        coverages = intake.policy_coverages(tables, policy)
        lo, hi = config.AS_OF, config.intake_horizon()
        c1, c2 = st.columns(2)
        c1.date_input("Incident date", value=lo, max_value=hi, key="intake_f_incident")
        c2.date_input("Submission date", value=lo, max_value=hi, key="intake_f_submitted")
        st.selectbox("Incident type", intake.incident_types(tables, product), key="intake_f_type")
        coverage = st.selectbox("Coverage", coverages, key="intake_f_coverage")
        st.selectbox(
            "Item type (types this coverage pays for)",
            intake.coverage_item_types(tables, coverage) or vocab.ITEM_TYPES,
            key="intake_f_item",
        )
        st.number_input("Amount (USD)", 0.01, 10_000_000.0, 500.0, 0.01, key="intake_f_amount")
        st.multiselect(
            "Documents received on the submission date", vocab.DOC_TYPES, key="intake_f_docs"
        )
        st.button("Write this claim into the text box", key="intake_from_form", on_click=_from_form)


def _show(result):
    d = result["decision"]
    st.subheader("Decision")
    cols = st.columns(4)
    cols[0].metric("Status", d["status"])
    cols[1].metric("Decision", d["decision"])
    cols[2].metric("Rule", d["rule_id"] or "-")
    cols[3].metric("Payable (USD)", f"{d['payable_usd']:,.2f}")
    role = result["settlement"][-1]["approver_role"] if result["settlement"] else None
    st.write(f"Approval route: {role}" if role else "Approval route: not reached (no settlement).")
    if result["missing_documents"]:
        pend = next((a for a in result["assessments"] if a["decision"] == "pend_docs"), None)
        when = f" on {pend['assessment_date']}" if pend else ""
        st.write("Requested: " + ", ".join(result["missing_documents"]) + when)
    st.subheader("Rule trace (decision path)")
    st.dataframe(result["rule_trace"], hide_index=True, width="stretch")
    st.subheader("What would make it payable")
    st.markdown("\n".join(f"- {t}" for t in result["counterfactual"]))
    st.subheader("Status timeline")
    st.dataframe(result["timeline"], hide_index=True, width="stretch")
    for name, key in (
        ("assessment", "assessments"),
        ("reserve", "reserve"),
        ("settlement", "settlement"),
        ("claim_adjuster_assignment", "assignments"),
    ):
        with st.expander(f"{name} ({len(result[key])})"):
            st.dataframe(view_data.display(name, result[key]), hide_index=True, width="stretch")
    st.caption(f"Evaluated up to the horizon {result['horizon']}.")


def render(tables, scale):
    st.caption(
        "No AI is involved: the decision path is deterministic rules. The claim is evaluated as a what-if "
        "on a copy of the dataset (the dataset is never changed) up to the evaluation horizon. "
        + whatif.NOTE
    )
    _reset_for_scale(scale)
    examples = _examples(tables, scale)
    if examples is None:
        return
    titles = [e.title for e in examples]
    if "intake_json" not in st.session_state:
        st.session_state["intake_json"] = json.dumps(examples[0].draft.to_json(), indent=2)
    pick = st.selectbox("Example claim", titles, key="intake_example")
    st.caption(examples[titles.index(pick)].expect)
    st.button("Load example", key="intake_load", on_click=_load_example, args=(examples,))
    _form(tables)
    st.text_area("Claim (JSON)", key="intake_json", height=320, max_chars=MAX_JSON_CHARS)
    st.button("Submit and evaluate", key="intake_submit", on_click=_submit, args=(tables,))
    if st.session_state.get("intake_errors"):
        st.error("The claim is not valid.")
        st.dataframe(st.session_state["intake_errors"], hide_index=True, width="stretch")
        return
    results = st.session_state.setdefault("intake_results", [])
    if not results:
        return
    latest = results[-1]["result"]
    _show(latest)
    if latest["decision"]["decision"] == "pend_docs":
        st.button(
            "Request the missing documents",
            key="intake_request_docs",
            on_click=_request_docs,
            args=(tables,),
        )
        st.caption(
            "Documents received after the 5-day window are what make a claim pend and then resume: "
            "the claim waits for them and is assessed again once they arrive."
        )
    st.subheader("Submitted this session")
    st.dataframe([r["summary"] for r in results], hide_index=True, width="stretch")
    st.button("Clear", key="intake_clear", on_click=_clear)
