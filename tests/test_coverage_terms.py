"""R-ELG-01: an item must be of a type its coverage pays for, for an incident type the coverage covers."""

from datetime import timedelta

import pytest

from claimsgen import config, view_trace, vocab, whatif
from claimsgen.draft import Doc, Draft, Item
from claimsgen.generate import build_dataset
from test_whatif import _clean


@pytest.fixture(scope="module")
def tables():
    return build_dataset(0.05)[0]


def _terms(t):
    return {
        c["coverage_id"]: (
            set(c["covered_incident_types"].split("|")),
            set(c["covered_item_types"].split("|")),
        )
        for c in t["coverage"]
    }


def _theft_draft(t, item_type):
    """A draft on an AUTO policy's Theft coverage with a quiet customer, every mandatory document, one item."""
    theft = next(c["coverage_id"] for c in t["coverage"] if c["name"] == "Theft")
    owner = {p["policy_id"]: p["customer_id"] for p in t["policy"]}
    busy = {owner[c["policy_id"]] for c in t["claim"]}
    ends = {e["policy_id"] for e in t["policy_event"] if e["event_type"] in ("lapsed", "cancelled")}
    for r in sorted(t["policy_coverage"], key=lambda r: r["policy_id"]):
        p = next(p for p in t["policy"] if p["policy_id"] == r["policy_id"])
        if r["coverage_id"] != theft or owner[p["policy_id"]] in busy or p["policy_id"] in ends:
            continue
        day = max(p["start_date"], r["effective_start"]) + timedelta(days=1)
        if day > min(p["end_date"], r["effective_end"], config.AS_OF - timedelta(days=5)):
            continue
        sub = day + timedelta(days=1)
        docs = tuple(
            Doc(d["doc_type"], sub)
            for d in t["document_requirement"]
            if d["claim_type"] == "AUTO" and d["mandatory"] == "Y"
        )
        return Draft(p["policy_id"], day, "theft", sub, (Item(theft, item_type, 600_000),), docs)
    raise AssertionError("no quiet policy with a Theft coverage")


def test_hospital_stay_under_auto_theft_is_denied_not_covered():
    t = build_dataset(1.0)[0]
    ok = whatif.evaluate(t, _theft_draft(t, "replacement"))
    assert ok["decision"]["decision"] == "approve"  # the same draft with a covered item is paid
    r = whatif.evaluate(t, _theft_draft(t, "hospital_stay"))
    d = r["decision"]
    assert (d["decision"], d["rule_id"], d["reason_code"]) == ("deny", "R-ELG-01", "not_covered")
    assert d["payable_usd"] == 0 and not r["settlement"]
    stopped = [s["rule_id"] for s in r["rule_trace"] if s["outcome"] == view_trace.STOPPED]
    assert stopped == ["R-ELG-01"]
    assert "R-ELG-01" in r["counterfactual"][0] and "hospital_stay" in r["counterfactual"][0]


def test_mixed_claim_pays_only_the_covered_item(tables):
    clean = _clean(tables)
    base = whatif.evaluate(tables, clean)
    cov = clean.items[0].coverage_id
    bad = next(t for t in vocab.ITEM_TYPES if t not in _terms(tables)[cov][1])
    mixed = Draft(
        clean.policy_id,
        clean.incident_date,
        clean.incident_type,
        clean.submission_date,
        (*clean.items, Item(cov, bad, 900_000)),
        clean.documents,
    )
    r = whatif.evaluate(tables, mixed)
    assert r["decision"]["decision"] == "approve"
    assert r["decision"]["payable_usd"] == base["decision"]["payable_usd"]


def test_uncovered_incident_type_is_denied(tables):
    clean = _clean(tables)
    covered = set().union(*(_terms(tables)[i.coverage_id][0] for i in clean.items))
    other = next(t for t in vocab.INCIDENT_TYPES if t not in covered)
    d = Draft(
        clean.policy_id,
        clean.incident_date,
        other,
        clean.submission_date,
        clean.items,
        clean.documents,
    )
    r = whatif.evaluate(tables, d)["decision"]
    assert (r["decision"], r["rule_id"], r["reason_code"]) == ("deny", "R-ELG-01", "not_covered")


def test_generator_never_builds_an_item_its_coverage_does_not_cover():
    data = build_dataset(1.0)[0]
    terms = _terms(data)
    inc = {i["incident_id"]: i["incident_type"] for i in data["incident"]}
    claim_inc = {c["claim_id"]: inc[c["incident_id"]] for c in data["claim"]}
    bad = [
        i["item_id"]
        for i in data["claim_item"]
        if claim_inc[i["claim_id"]] not in terms[i["coverage_id"]][0]
        or i["item_type"] not in terms[i["coverage_id"]][1]
    ]
    assert bad == []
    assert not any(a["rule_id"] == "R-ELG-01" for a in data["assessment"])
