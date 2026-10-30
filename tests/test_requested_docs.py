"""T3: a pend_docs assessment records which document types were requested; the validator recomputes them."""

from claimsgen import config, metrics, validate, view_data, whatif
from claimsgen.draft import Draft
from claimsgen.generate import build_dataset
from test_whatif import _clean

ARITH = "totals, payable, reserve and settlement reconcile"


def _expected(data, claim, docs, required):
    """Written from the spec: mandatory types for the claim type with no received document inside the window."""
    have = {
        d["doc_type"]
        for d in docs
        if d["status"] == "received"
        and (d["received_date"] - claim["submission_date"]).days <= config.DOC_WINDOW_DAYS
    }
    return "|".join(sorted(required[claim["claim_type"]] - have))


def _by_claim(data):
    required: dict = {}
    for r in data["document_requirement"]:
        if r["mandatory"] == "Y":
            required.setdefault(r["claim_type"], set()).add(r["doc_type"])
    docs: dict = {}
    for d in data["document"]:
        docs.setdefault(d["claim_id"], []).append(d)
    return required, docs, {c["claim_id"]: c for c in data["claim"]}


def test_every_pend_docs_assessment_lists_exactly_the_missing_types(data):
    required, docs, claims = _by_claim(data)
    pending = [a for a in data["assessment"] if a["decision"] == "pend_docs"]
    assert pending
    for a in pending:
        want = _expected(data, claims[a["claim_id"]], docs.get(a["claim_id"], []), required)
        assert want and a["missing_doc_types"] == want
    assert all(a["missing_doc_types"] == "" for a in data["assessment"] if a not in pending)


def test_blanking_the_field_makes_the_validator_fail(data):
    pending = next(a for a in data["assessment"] if a["decision"] == "pend_docs")
    broken = dict(data)
    broken["assessment"] = [
        dict(a, missing_doc_types="") if a is pending else a for a in data["assessment"]
    ]
    failing = {c.name: c.ids for c in validate.run_all(broken) if c.failures}
    assert pending["assessment_id"] in failing[ARITH]


def test_requested_types_appear_in_the_timeline(data):
    pending = next(a for a in data["assessment"] if a["decision"] == "pend_docs")
    detail = view_data.claim_detail(data, pending["claim_id"])
    step = next(t for t in detail["timeline"] if t["to"] == "docs_pending")
    assert step["detail"] == "Requested: " + pending["missing_doc_types"].replace("|", ", ")
    assert all(t["detail"] == "" for t in detail["timeline"] if t["to"] != "docs_pending")


def test_whatif_result_matches_the_recorded_request():
    tables = build_dataset(0.05)[0]
    clean = _clean(tables)
    pending = Draft(
        clean.policy_id,
        clean.incident_date,
        clean.incident_type,
        clean.submission_date,
        clean.items,
        clean.documents[1:],
    )
    r = whatif.evaluate(tables, pending)
    assert r["missing_documents"]
    assert r["assessments"][0]["missing_doc_types"] == "|".join(r["missing_documents"])
    assert any(t["detail"].startswith("Requested: ") for t in r["timeline"])


def test_aging_buckets_are_nested():
    tables = build_dataset(1.0)[0]
    g = metrics.operational(tables)["docs_pending_aging"]
    assert (
        g["count"] >= g["older_than_14_days"] >= g["older_than_30_days"] >= g["older_than_90_days"]
    )
