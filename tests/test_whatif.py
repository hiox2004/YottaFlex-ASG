from datetime import timedelta

import pytest

from claimsgen import config, engine, generate, view_data, whatif
from claimsgen.draft import Doc, Draft, Item
from claimsgen.sensitivity import OUTPUT_TABLES


@pytest.fixture(scope="module")
def tables():
    return generate.build_dataset(0.05)[0]


def _first_clean(t):
    """A real, cleanly approved claim (one assessment, eligible) and a draft built from its policy, items and documents."""
    inc = {i["incident_id"]: i for i in t["incident"]}
    asm: dict = {}
    for a in t["assessment"]:
        asm.setdefault(a["claim_id"], []).append(a)
    for c in t["claim"]:
        a = asm.get(c["claim_id"], [])
        if len(a) == 1 and (a[0]["rule_id"], a[0]["reason_code"]) == ("R-PAY-01", "eligible"):
            i = inc[c["incident_id"]]
            items = tuple(
                Item(x["coverage_id"], x["item_type"], x["claimed_amount"])
                for x in t["claim_item"]
                if x["claim_id"] == c["claim_id"]
            )
            docs = tuple(
                Doc(d["doc_type"], d["received_date"], d["status"])
                for d in t["document"]
                if d["claim_id"] == c["claim_id"]
            )
            return c, i, items, docs
    raise AssertionError("no clean claim")


def _clean(t):
    """Same policy and items as a real clean claim, but a different incident day (not a duplicate), submitted a day later."""
    c, i, items, docs = _first_clean(t)
    sub = c["submission_date"] + timedelta(days=1)
    docs = tuple(Doc(d.doc_type, sub) for d in docs)
    pcv = [r for r in t["policy_coverage"] if r["policy_id"] == c["policy_id"]]
    lo = max(r["effective_start"] for r in pcv)
    hi = min(r["effective_end"] for r in pcv)
    day = i["incident_date"] + timedelta(days=1 if i["incident_date"] < hi else -1)
    assert lo <= day <= min(hi, sub)
    return Draft(c["policy_id"], day, i["incident_type"], sub, items, docs)


def test_base_tables_unchanged(tables):
    before = view_data.dataset_checksum(tables)
    sizes = {k: len(v) for k, v in tables.items()}
    whatif.evaluate(tables, _clean(tables))
    assert view_data.dataset_checksum(tables) == before
    assert {k: len(v) for k, v in tables.items()} == sizes


def test_evaluate_is_deterministic(tables):
    d = _clean(tables)
    assert whatif.evaluate(tables, d) == whatif.evaluate(tables, d)


def test_base_outputs_reproduce(tables):
    inputs = {k: v for k, v in tables.items() if k not in OUTPUT_TABLES}
    out = engine.run(inputs)
    assert all(out[k] == tables[k] for k in OUTPUT_TABLES if k != "settlement")
    base_ids = {s["settlement_id"] for s in tables["settlement"]}
    assert {
        s["settlement_id"] for s in out["settlement"]
    } <= base_ids  # injection only adds or alters rows


def test_clean_draft_is_approved_with_settlement(tables):
    clean = _clean(tables)
    r = whatif.evaluate(tables, clean)
    assert r["decision"]["decision"] == "approve"
    assert r["claim"]["claim_id"] == whatif.PROVISIONAL_CLAIM
    assert r["claim"]["claimed_amount"] == sum(i.cents for i in clean.items)
    (s,) = r["settlement"]
    role = (
        "approver" if s["recommended_amount"] > config.APPROVER_THRESHOLD_CENTS else "process_owner"
    )
    assert s["approver_role"] == role
    assert r["horizon"] == config.intake_horizon()
    assert r["missing_documents"] == []
    assert {"rule_trace", "counterfactual", "timeline", "assignments", "reserve"} <= set(r)
    assert all(h["claim_id"] == whatif.PROVISIONAL_CLAIM for h in r["history"])


def test_missing_document_pends_then_request_docs_resumes(tables):
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
    assert r["missing_documents"] == [clean.documents[0].doc_type]
    assert r["decision"]["status"] == "docs_pending"
    assert r["decision"]["rule_id"] == "R-DOC-01"
    fixed = whatif.request_docs(tables, pending)
    assert whatif.missing_documents(tables, fixed) == [
        clean.documents[0].doc_type
    ]  # outside window
    r2 = whatif.evaluate(tables, fixed)
    assert [a["assessment_id"][-3:] for a in r2["assessments"]] == ["001", "002"]
    assert r2["assessments"][-1]["decision"] == "approve"
    assert r2["decision"]["decision"] == "approve"


def test_before_policy_start_is_denied(tables):
    clean = _clean(tables)
    start = next(p for p in tables["policy"] if p["policy_id"] == clean.policy_id)["start_date"]
    d = Draft(
        clean.policy_id,
        start - timedelta(days=3),
        clean.incident_type,
        start - timedelta(days=1),
        clean.items,
        tuple(Doc(x.doc_type, start - timedelta(days=1)) for x in clean.documents),
    )
    r = whatif.evaluate(tables, d)
    assert (r["decision"]["decision"], r["decision"]["rule_id"]) == ("deny", "R-COV-01")


def test_duplicate_is_referred(tables):
    c, i, items, docs = _first_clean(tables)
    sub = c["submission_date"] + timedelta(days=1)
    d = Draft(
        c["policy_id"],
        i["incident_date"],
        i["incident_type"],
        sub,
        items,
        tuple(Doc(x.doc_type, sub) for x in docs),
    )
    r = whatif.evaluate(tables, d)
    assert (r["decision"]["decision"], r["decision"]["rule_id"]) == ("refer_review", "R-ELG-03")
    assert r["settlement"] == []


def test_submitted_on_as_of_is_processed_beyond_submitted(tables):
    clean = _clean(tables)
    d = Draft(
        clean.policy_id,
        clean.incident_date,
        clean.incident_type,
        config.AS_OF,
        clean.items,
        tuple(Doc(x.doc_type, config.AS_OF) for x in clean.documents),
    )
    r = whatif.evaluate(tables, d)
    assert r["decision"]["status"] != "submitted"
    assert len(r["history"]) > 1


def test_full_dataset_clean_draft(data):
    r = whatif.evaluate(data, _clean(data))
    assert r["decision"]["decision"] == "approve"
