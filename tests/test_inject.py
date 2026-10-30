from collections import Counter, defaultdict

import pytest

from claimsgen import config, engine, generate, validate
from claimsgen.schema import TABLE_BY_NAME

CASES = (
    "claim_before_policy_start",
    "cancelled_before_incident",
    "duplicate_incident",
    "settlement_exceeds_limit",
    "missing_mandatory_doc",
    "paid_twice",
)
DEFECTS = {"settlement_exceeds_limit", "paid_twice"}


@pytest.fixture(scope="module")
def built():
    return generate.build_dataset(1.0)


def _gt(built, label, origin="injected"):
    return [r for r in built[1] if r["label"] == label and r["origin"] == origin]


def _last_assessment(tables):
    out = {}
    for a in tables["assessment"]:
        out[a["claim_id"]] = a
    return out


def test_counts_and_label_shape(built):
    tables, gt = built
    assert len(tables["claim"]) == 1000
    injected = Counter(r["label"] for r in gt if r["origin"] == "injected")
    assert injected == dict.fromkeys(CASES, config.inject_rows(1.0))
    assert 10 <= config.inject_rows(1.0) <= 30
    assert len({(r["entity_id"], r["label"]) for r in gt}) == len(gt)
    assert {r["kind"] for r in gt if r["label"] in DEFECTS} == {"integrity_defect"}
    assert {r["kind"] for r in gt if r["origin"] == "injected" and r["label"] not in DEFECTS} == {
        "business_outcome"
    }
    assert all(set(r) == {f.name for f in TABLE_BY_NAME["ground_truth"].fields} for r in gt)


def test_ground_truth_entities_exist_and_inputs_do_not_leak(built):
    tables, gt = built
    ids_by_type = {
        "claim": {c["claim_id"] for c in tables["claim"]},
        "settlement": {s["settlement_id"] for s in tables["settlement"]},
    }
    assert all(r["entity_id"] in ids_by_type[r["entity_type"]] for r in gt)
    assert "ground_truth" not in tables
    for name, rows in tables.items():
        assert set(rows[0]) == {f.name for f in TABLE_BY_NAME[name].fields}, name


def test_validator_flags_exactly_the_integrity_defects(built):
    tables, gt = built
    checks = validate.run_all(tables)
    defects = {r["entity_id"] for r in gt if r["kind"] == "integrity_defect"}
    assert len(defects) == 2 * config.inject_rows(1.0)
    assert validate.failing_ids(checks) == defects
    structural = {"keys", "joins", "domain", "leakage"}
    assert all(c.ok for c in checks if c.category in structural)


def test_business_outcome_cases_are_decided_by_the_rules(built):
    tables, _ = built
    last = _last_assessment(tables)
    status = {}
    for e in tables["claim_status_history"]:
        status[e["claim_id"]] = e["to_status"]
    settled = {s["claim_id"] for s in tables["settlement"]}
    for r in _gt(built, "claim_before_policy_start"):
        assert (last[r["entity_id"]]["rule_id"], status[r["entity_id"]]) == ("R-COV-01", "denied")
    for r in _gt(built, "cancelled_before_incident"):
        assert (last[r["entity_id"]]["rule_id"], status[r["entity_id"]]) == ("R-COV-02", "denied")
    for r in _gt(built, "duplicate_incident"):
        assert (last[r["entity_id"]]["rule_id"], status[r["entity_id"]]) == (
            "R-ELG-03",
            "under_review",
        )
    for r in _gt(built, "missing_mandatory_doc"):
        assert status[r["entity_id"]] == "docs_pending" and r["entity_id"] not in settled


def test_engine_reproduces_outputs_except_the_two_patched_defects(built):
    tables, gt = built
    inputs = {k: v for k, v in tables.items() if k not in engine.World(tables).out}
    again = engine.run(inputs)
    patched = {r["entity_id"] for r in gt if r["kind"] == "integrity_defect"}
    for name, rows in again.items():
        original = tables[name]
        if name == "settlement":
            original = [s for s in original if s["settlement_id"] not in patched]
            rows = [s for s in rows if s["settlement_id"] not in patched]
            assert len(rows) == len(original)
        assert rows == original, name


def test_ids_are_final_contiguous_and_do_not_reveal_injected_rows(built):
    tables, gt = built
    ids = [c["claim_id"] for c in tables["claim"]]
    assert ids == [f"CLM-2026-{n:06d}" for n in range(1, 1001)]
    incident = {i["incident_id"]: i["incident_date"] for i in tables["incident"]}
    keys = [
        (c["submission_date"], incident[c["incident_id"]], c["policy_id"]) for c in tables["claim"]
    ]
    assert keys == sorted(keys)
    injected_claims = sorted(
        r["entity_id"] for r in gt if r["origin"] == "injected" and r["entity_type"] == "claim"
    )
    assert min(injected_claims) < "CLM-2026-000900"
    docs = defaultdict(list)
    for d in tables["document"]:
        docs[d["claim_id"]].append(d["document_id"])
    assert all(v == [f"DOC-{k}-{n:03d}" for n in range(1, len(v) + 1)] for k, v in docs.items())


def test_injected_targets_are_disjoint_and_isolated(built):
    tables, gt = built
    policy = {p["policy_id"]: p for p in tables["policy"]}
    claim = {c["claim_id"]: c for c in tables["claim"]}
    settle = {s["settlement_id"]: s["claim_id"] for s in tables["settlement"]}
    keyed = [
        claim_of
        for r in gt
        if r["origin"] == "injected"
        for claim_of in [settle.get(r["entity_id"], r["entity_id"])]
    ]
    assert len(keyed) == len(set(keyed)), "a claim carries more than one injected label"
    per_customer = Counter(policy[c["policy_id"]]["customer_id"] for c in claim.values())
    sources = {
        r["entity_id"]
        for r in gt
        if r["origin"] == "injected" and r["label"] != "duplicate_incident"
    }
    for cid in (settle.get(e, e) for e in sources):
        assert per_customer[policy[claim[cid]["policy_id"]]["customer_id"]] == 1


def test_deterministic_and_starter_scale_validates():
    assert generate.build_dataset(0.1) == generate.build_dataset(0.1)
    tables, gt = generate.build_dataset(0.05)
    defects = {r["entity_id"] for r in gt if r["kind"] == "integrity_defect"}
    assert validate.failing_ids(validate.run_all(tables)) == defects
    assert len(tables["claim"]) == 50
