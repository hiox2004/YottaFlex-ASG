import inspect

import pytest

from claimsgen import view_data

STOPS = {
    "R-COV-01": ("deny", None),
    "R-COV-02": ("deny", None),
    "R-COV-03": ("deny", None),
    "R-ELG-03": ("refer_review", None),
    "R-DOC-01": ("pend_docs", None),
    "R-FRD-05": ("refer_review", None),
    "R-PAY-01": ("deny", "within_deductible"),
}


@pytest.fixture(scope="module")
def full():
    return view_data.load(1.0)[0]


def last_assessments(t):
    out = {}
    for a in t["assessment"]:
        out[a["claim_id"]] = a
    return out


def pick(t, rule, decision, reason=None):
    for cid, a in last_assessments(t).items():
        if (
            a["rule_id"] == rule
            and a["decision"] == decision
            and (reason is None or a["reason_code"] == reason)
        ):
            return cid
    return None


def test_signatures_exclude_ground_truth():
    for fn in (view_data.rule_trace, view_data.counterfactual):
        assert list(inspect.signature(fn).parameters) == ["tables", "claim_id"]


def test_trace_stops_at_last_assessment_rule_for_every_stop_type(full):
    seen = 0
    for rule, (decision, reason) in STOPS.items():
        cid = pick(full, rule, decision, reason)
        if cid is None:
            continue
        seen += 1
        trace = view_data.rule_trace(full, cid)
        stopped = [r for r in trace if r["outcome"] == "failed-and-stopped"]
        assert [r["rule_id"] for r in stopped] == [rule], rule
        i = trace.index(stopped[0])
        assert all(r["outcome"] == "passed" for r in trace[:i]) or rule == "R-DOC-01"
        assert all(r["outcome"] == "not evaluated" for r in trace[i + 1 :])
        assert stopped[0]["reason_code"] and stopped[0]["actor_role"] and stopped[0]["date"]
    assert seen >= 6


def test_every_claim_trace_stop_matches_last_assessment(full):
    last = last_assessments(full)
    for c in full["claim"][:300]:
        trace = view_data.rule_trace(full, c["claim_id"])
        stopped = [r["rule_id"] for r in trace if r["outcome"] == "failed-and-stopped"]
        a = last.get(c["claim_id"])
        if a is None:
            assert stopped == [] and all(r["outcome"] == "not evaluated" for r in trace)
        elif a["decision"] == "approve":
            assert stopped == []
        else:
            assert stopped == [a["rule_id"]]


def test_approved_claim_reaches_reserve_and_approval(full):
    cid = next(a["claim_id"] for a in full["assessment"] if a["decision"] == "approve")
    paid = next(e["claim_id"] for e in full["claim_status_history"] if e["to_status"] == "paid")
    trace = {r["rule_id"]: r for r in view_data.rule_trace(full, paid)}
    assert trace["R-PAY-01"]["outcome"] == "passed" and trace["R-RSV-01"]["outcome"] == "passed"
    assert trace["R-APR-01"]["outcome"] == "passed"
    assert trace["R-APR-01"]["actor_role"] in ("approver", "process_owner")
    assert cid
    assert "Already payable" in view_data.counterfactual(full, paid)[0]


def test_resumed_docs_claim_shows_rerun(full):
    asm = {}
    for a in full["assessment"]:
        asm.setdefault(a["claim_id"], []).append(a)
    cid = next(c for c, rows in asm.items() if len(rows) > 1)
    trace = view_data.rule_trace(full, cid)
    doc = next(r for r in trace if r["rule_id"] == "R-DOC-01")
    assert doc["outcome"] == "passed" and doc["run"] == "re-run after documents"
    assert doc["date"] == asm[cid][-1]["assessment_date"].isoformat()
    assert trace[0]["date"] == asm[cid][0]["assessment_date"].isoformat()
    assert doc["date"] > trace[0]["date"]


def test_counterfactual_deductible_and_documents(full):
    cid = pick(full, "R-PAY-01", "deny", "within_deductible")
    if cid:
        a = last_assessments(full)[cid]
        text = view_data.counterfactual(full, cid)[0]
        assert "deductible" in text and f"{a['eligible_amount'] / 100:,.2f}" in text
    docs = pick(full, "R-DOC-01", "pend_docs")
    text = view_data.counterfactual(full, docs)[0]
    need = {d["doc_type"] for d in full["document_requirement"] if d["mandatory"] == "Y"}
    assert "missing mandatory documents" in text and any(t in text for t in need)


def test_counterfactual_mentions_dates_and_duplicate_id(full):
    cov1 = pick(full, "R-COV-01", "deny")
    claim = next(c for c in full["claim"] if c["claim_id"] == cov1)
    policy = next(p for p in full["policy"] if p["policy_id"] == claim["policy_id"])
    assert str(policy["start_date"]) in view_data.counterfactual(full, cov1)[0]
    cov2 = pick(full, "R-COV-02", "deny")
    assert "before incident" in view_data.counterfactual(full, cov2)[0]
    dup = pick(full, "R-ELG-03", "refer_review")
    assert "earlier claim CLM-" in view_data.counterfactual(full, dup)[0]
    fraud = pick(full, "R-FRD-05", "refer_review")
    assert "cutoff" in view_data.counterfactual(full, fraud)[0]


def test_unassessed_claim_trace_and_text(full):
    done = {a["claim_id"] for a in full["assessment"]}
    cid = next((c["claim_id"] for c in full["claim"] if c["claim_id"] not in done), None)
    if cid:
        assert "Not assessed" in view_data.counterfactual(full, cid)[0]
