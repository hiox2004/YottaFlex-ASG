"""IMP-004: injection leaves every non-target claim (and all master data) untouched, compared before/after finalize."""

from collections import Counter

import pytest

from claimsgen import claims, engine, inject, masterdata, policies
from claimsgen.finalize import CHILDREN, finalize

CHILD_TABLES = tuple(CHILDREN)
UNCHANGED = (
    "policy",
    "customer",
    "coverage",
    "adjuster",
    "document_requirement",
    "policy_coverage",
)


@pytest.fixture(scope="module", params=[0.05, 1.0], ids=["starter", "full"])
def world(request):
    scale = request.param
    master = masterdata.generate(scale)
    pol = policies.generate(master, scale)
    claim_tables, planted = claims.generate(master, pol, scale)
    base = {**master, **pol, **claim_tables}
    baseline = {**base, **engine.run(base)}
    injected_data, injected = inject.inject(master, pol, claim_tables, planted, scale)
    final, idmap = finalize(injected_data)
    claim_of_settlement = {s["settlement_id"]: s["claim_id"] for s in injected_data["settlement"]}
    targets = set()
    for e in injected:
        if e["entity_type"] == "claim":
            targets.add(e["entity_id"])
        else:
            targets.add(claim_of_settlement[e["entity_id"]])
    return baseline, final, idmap, targets, injected


def _translate(row, idmap, id_fields):
    return {k: (idmap[v] if k in id_fields else v) for k, v in row.items()}


def _group(rows, key):
    out: dict = {}
    for r in rows:
        out.setdefault(r[key], []).append(r)
    return out


def test_targets_are_a_proper_subset(world):
    baseline, final, _idmap, targets, injected = world
    assert len(targets) >= 6
    assert len(final["claim"]) == len(baseline["claim"]) + sum(
        e["label"] == "duplicate_incident" for e in injected
    )
    sources = {e["detail"] for e in injected if e["label"] == "duplicate_incident"}
    assert sources and not sources & targets


def test_non_target_claim_rows_identical(world):
    baseline, final, idmap, targets, _ = world
    untouched = [c["claim_id"] for c in baseline["claim"] if c["claim_id"] not in targets]
    assert len(untouched) > len(targets)
    final_by = {}
    for table in ("claim", "incident", *CHILD_TABLES):
        key = "incident_id" if table == "incident" else "claim_id"
        final_by[table] = _group(final[table], key)
    incident_of = {c["claim_id"]: c["incident_id"] for c in baseline["claim"]}
    for table in ("claim", "incident", *CHILD_TABLES):
        pk = {
            "claim": "claim_id",
            "incident": "incident_id",
            **{t: CHILDREN[t][0] for t in CHILD_TABLES},
        }[table]
        id_fields = {pk, "claim_id", "incident_id"} & set(baseline[table][0])
        key = "incident_id" if table == "incident" else "claim_id"
        before = _group(baseline[table], key)
        for cid in untouched:
            k = incident_of[cid] if table == "incident" else cid
            want = [_translate(r, idmap, id_fields) for r in before.get(k, [])]
            assert final_by[table].get(idmap[k], []) == want, (table, cid)


def test_master_data_and_policies_unchanged(world):
    baseline, final, *_ = world
    for table in UNCHANGED:
        assert final[table] == baseline[table], table


def test_policy_event_only_gains_cancellations(world):
    baseline, final, _, _, injected = world
    before = {e["event_id"]: e for e in baseline["policy_event"]}
    after = {e["event_id"]: e for e in final["policy_event"]}
    assert len(after) == len(final["policy_event"])
    assert all(after[k] == v for k, v in before.items())
    added = [e for k, e in after.items() if k not in before]
    assert {e["event_type"] for e in added} == {"cancelled"}
    wanted = sum(e["label"] == "cancelled_before_incident" for e in injected)
    assert Counter(e["event_type"] for e in added)["cancelled"] == wanted
