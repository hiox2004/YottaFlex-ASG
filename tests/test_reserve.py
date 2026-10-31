"""T10: the reserve develops. FNOL row at submission, a `revised` row at the decisive assessment (0 on denial)."""

import copy
from collections import defaultdict

from claimsgen import rules, validate

ARITH = "totals, payable, reserve and settlement reconcile"


def _groups(rows):
    out = defaultdict(list)
    for r in rows:
        out[r["claim_id"]].append(r)
    return out


def test_fnol_reserve_hand_fixture():
    items = [
        {"coverage_id": "A", "claimed_amount": 500_000},
        {"coverage_id": "A", "claimed_amount": 700_000},
        {"coverage_id": "B", "claimed_amount": 90_000},
    ]
    pcv = {"A": {"limit_amount": 1_000_000}, "B": {"limit_amount": 5_000_000}}
    # A: 1,200,000 claimed, capped at 1,000,000; B under its limit
    assert rules.fnol_reserve(items, pcv) == 1_090_000


def test_every_claim_has_an_fnol_reserve_on_the_submission_date(data):
    res, claims = _groups(data["reserve"]), {c["claim_id"]: c for c in data["claim"]}
    items = _groups(data["claim_item"])
    pcv = {(r["policy_id"], r["coverage_id"]): r for r in data["policy_coverage"]}
    assert set(res) == set(claims)
    for cid, c in claims.items():
        first = res[cid][0]
        assert first["basis"] == "preliminary" and first["rule_id"] == "R-RSV-01"
        assert first["reserve_date"] == c["submission_date"]
        want = 0
        by_cov = defaultdict(int)
        for i in items[cid]:
            by_cov[i["coverage_id"]] += i["claimed_amount"]
        for cov, amount in by_cov.items():
            want += min(amount, pcv[(c["policy_id"], cov)]["limit_amount"])
        assert first["amount"] == want


def test_reserve_ends_at_final_payable_zero_on_denial_fnol_when_undecided(data):
    res, assess = _groups(data["reserve"]), _groups(data["assessment"])
    seen = defaultdict(int)
    for cid, rows in res.items():
        last = assess[cid][-1] if cid in assess else None
        decisive = last is not None and last["decision"] in ("approve", "deny")
        seen["decisive" if decisive else "undecided"] += 1
        assert rows[-1]["amount"] == (last["payable_amount"] if decisive else rows[0]["amount"])
        assert [r["basis"] for r in rows[1:]] == ["revised"] * (len(rows) - 1)
        assert all(r["rule_id"] == "R-RSV-02" for r in rows[1:])
        assert len(rows) <= 2
        dates = [r["reserve_date"] for r in rows]
        assert dates == sorted(dates)
        if len(rows) == 2:
            assert rows[1]["reserve_date"] == last["assessment_date"]
    assert seen["decisive"] and seen["undecided"]
    denied = [cid for cid, a in assess.items() if a[-1]["decision"] == "deny"]
    assert denied and all(res[cid][-1]["amount"] == 0 for cid in denied)
    revised = [r for r in data["reserve"] if r["basis"] == "revised"]
    assert revised  # the `revised` basis now occurs in the data


def test_validator_flags_a_wrong_fnol_and_a_wrong_final_reserve(data):
    t = copy.deepcopy(data)
    first = t["reserve"][0]
    first["amount"] += 100
    fails = {c.name: c.ids for c in validate.run_all(t) if c.failures}
    assert first["reserve_id"] in fails[ARITH]
    t = copy.deepcopy(data)
    revised = next(r for r in t["reserve"] if r["basis"] == "revised")
    revised["amount"] += 100
    fails = {c.name: c.ids for c in validate.run_all(t) if c.failures}
    assert revised["reserve_id"] in fails[ARITH]
