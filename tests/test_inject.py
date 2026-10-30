from collections import Counter, defaultdict

import pytest

from claimsgen import config, engine, generate, ground_truth, validate
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


@pytest.fixture(scope="module", params=[0.05, 1.0], ids=["starter", "full"])
def built(request):
    tables, gt = generate.build_dataset(request.param)
    return tables, gt, request.param


def _gt(built, label, origin="injected"):
    return [r for r in built[1] if r["label"] == label and r["origin"] == origin]


def _last_assessment(tables):
    out = {}
    for a in tables["assessment"]:
        out[a["claim_id"]] = a
    return out


def test_counts_and_label_shape(built):
    tables, gt, scale = built
    assert len(tables["claim"]) == config.counts(scale).claims
    injected = Counter(r["label"] for r in gt if r["origin"] == "injected")
    assert injected == dict.fromkeys(CASES, config.inject_rows(scale))
    if scale == 1.0:
        assert 10 <= config.inject_rows(scale) <= 30
    assert len({(r["entity_id"], r["label"]) for r in gt}) == len(gt)
    assert {r["kind"] for r in gt if r["label"] in DEFECTS} == {"integrity_defect"}
    business = {r["kind"] for r in gt if r["origin"] == "injected" and r["label"] not in DEFECTS}
    assert business == {"business_outcome"}
    assert all(set(r) == {f.name for f in TABLE_BY_NAME["ground_truth"].fields} for r in gt)
    assert all(r["expected_decision"].split(":")[0] in ground_truth.EXPECTED_WORDS for r in gt)


def test_ground_truth_entities_exist_and_inputs_do_not_leak(built):
    tables, gt, _ = built
    ids_by_type = {
        "claim": {c["claim_id"] for c in tables["claim"]},
        "settlement": {s["settlement_id"] for s in tables["settlement"]},
    }
    assert all(r["entity_id"] in ids_by_type[r["entity_type"]] for r in gt)
    assert "ground_truth" not in tables
    for name, rows in tables.items():
        assert set(rows[0]) == {f.name for f in TABLE_BY_NAME[name].fields}, name


def test_validator_flags_exactly_the_integrity_defects(built):
    tables, gt, scale = built
    checks = validate.run_all(tables)
    defects = {r["entity_id"] for r in gt if r["kind"] == "integrity_defect"}
    assert len(defects) == 2 * config.inject_rows(scale)
    assert validate.failing_ids(checks) == defects
    structural = {"keys", "joins", "domain", "leakage"}
    assert all(c.ok for c in checks if c.category in structural)


def test_business_outcome_cases_are_decided_by_the_rules(built):
    tables, *_ = built
    last = _last_assessment(tables)
    status = {}
    for e in tables["claim_status_history"]:
        status[e["claim_id"]] = e["to_status"]
    settled = {s["claim_id"] for s in tables["settlement"]}
    expected = {
        "claim_before_policy_start": ("R-COV-01", "denied"),
        "cancelled_before_incident": ("R-COV-02", "denied"),
        "duplicate_incident": ("R-ELG-03", "under_review"),
    }
    for label, outcome in expected.items():
        rows = _gt(built, label)
        assert rows, label
        for r in rows:
            assert r["entity_id"] in last, f"{label} {r['entity_id']} was never assessed"
            assert (last[r["entity_id"]]["rule_id"], status[r["entity_id"]]) == outcome
    for r in _gt(built, "missing_mandatory_doc"):
        assert status[r["entity_id"]] == "docs_pending" and r["entity_id"] not in settled


def test_engine_reproduces_outputs_except_the_two_patched_defects(built):
    tables, gt, _ = built
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
    tables, gt, scale = built
    n = len(tables["claim"])
    assert [c["claim_id"] for c in tables["claim"]] == [
        f"CLM-2026-{i:06d}" for i in range(1, n + 1)
    ]
    incident = {i["incident_id"]: i["incident_date"] for i in tables["incident"]}
    keys = [
        (c["submission_date"], incident[c["incident_id"]], c["policy_id"]) for c in tables["claim"]
    ]
    assert keys == sorted(keys)
    docs = defaultdict(list)
    for d in tables["document"]:
        docs[d["claim_id"]].append(d["document_id"])
    assert all(v == [f"DOC-{k}-{i:03d}" for i in range(1, len(v) + 1)] for k, v in docs.items())
    if scale == 1.0:
        ranks = sorted(
            int(r["entity_id"][-6:])
            for r in gt
            if r["origin"] == "injected" and r["entity_type"] == "claim"
        )
        assert ranks[0] < 0.9 * n and ranks[-1] > 0.1 * n  # spread, not a head or tail block


def test_injected_policy_events_are_not_a_tail_block(built):
    tables, _, scale = built
    claim = {c["claim_id"]: c for c in tables["claim"]}
    cancelled = {
        claim[r["entity_id"]]["policy_id"] for r in _gt(built, "cancelled_before_incident")
    }
    rows = [
        i
        for i, e in enumerate(tables["policy_event"])
        if e["policy_id"] in cancelled and e["event_type"] == "cancelled"
    ]
    assert len(rows) == len(cancelled)
    if scale == 1.0:
        assert min(rows) < 0.9 * len(tables["policy_event"])
    policy_order = {p["policy_id"]: i for i, p in enumerate(tables["policy"])}
    keys = [policy_order[e["policy_id"]] for e in tables["policy_event"]]
    assert keys == sorted(keys)


def test_injected_targets_are_disjoint_and_isolated(built):
    tables, gt, _ = built
    policy = {p["policy_id"]: p for p in tables["policy"]}
    claim = {c["claim_id"]: c for c in tables["claim"]}
    settle = {s["settlement_id"]: s["claim_id"] for s in tables["settlement"]}
    keyed = [settle.get(r["entity_id"], r["entity_id"]) for r in gt if r["origin"] == "injected"]
    assert len(keyed) == len(set(keyed)), "a claim carries more than one injected label"
    per_customer = Counter(policy[c["policy_id"]]["customer_id"] for c in claim.values())
    sources = {
        r["entity_id"]
        for r in gt
        if r["origin"] == "injected" and r["label"] != "duplicate_incident"
    }
    for cid in (settle.get(e, e) for e in sources):
        assert per_customer[policy[claim[cid]["policy_id"]]["customer_id"]] == 1


def test_deterministic():
    assert generate.build_dataset(0.1) == generate.build_dataset(0.1)
