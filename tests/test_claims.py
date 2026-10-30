from collections import Counter, defaultdict
from datetime import timedelta
from statistics import mean, median

from claimsgen import claims, config, masterdata, policies
from claimsgen.masterdata import COVERAGE_PROFILE


def _by(data, name, key):
    return {r[key]: r for r in data[name]}


def _group(rows):
    out = defaultdict(list)
    for r in rows:
        out[r["claim_id"]].append(r)
    return out


def _mandatory(data):
    required = defaultdict(set)
    for r in data["document_requirement"]:
        if r["mandatory"] == "Y":
            required[r["claim_type"]].add(r["doc_type"])
    return required


def _lookups(data):
    ends = {
        e["policy_id"]: e["event_date"]
        for e in data["policy_event"]
        if e["event_type"] in ("lapsed", "cancelled")
    }
    pcv = {(r["policy_id"], r["coverage_id"]): r for r in data["policy_coverage"]}
    return ends, pcv


def test_total_and_determinism(data):
    assert len(data["claim"]) == 1000 - config.inject_rows(1.0)
    master = masterdata.generate(0.1)
    pol = policies.generate(master, 0.1)
    assert claims.generate(master, pol, 0.1) == claims.generate(master, pol, 0.1)


def test_ids_follow_sort_order(data):
    incident = _by(data, "incident", "incident_id")
    keys = [
        (c["submission_date"], incident[c["incident_id"]]["incident_date"], c["policy_id"])
        for c in data["claim"]
    ]
    assert keys == sorted(keys)
    assert [c["claim_id"] for c in data["claim"]] == sorted(c["claim_id"] for c in data["claim"])


def test_amounts_dates_and_types(data):
    incident = _by(data, "incident", "incident_id")
    policy = _by(data, "policy", "policy_id")
    items, docs = _group(data["claim_item"]), _group(data["document"])
    for c in data["claim"]:
        inc, p = incident[c["incident_id"]], policy[c["policy_id"]]
        assert c["claimed_amount"] == sum(i["claimed_amount"] for i in items[c["claim_id"]])
        assert c["claim_type"] == p["product"]
        assert p["start_date"] <= inc["incident_date"] <= c["submission_date"] <= config.AS_OF
        for d in docs[c["claim_id"]]:
            assert c["submission_date"] <= d["received_date"] <= config.AS_OF
    item_types = {t for _, types in COVERAGE_PROFILE.values() for t in types}
    assert all(i["claimed_amount"] > 0 and i["item_type"] in item_types for i in data["claim_item"])


def test_planted_counts(data, planted):
    n = len(data["claim"])
    assert Counter(p["scenario"] for p in planted) == config.scenario_counts(n)
    assert len({p["claim_id"] for p in planted}) == len(planted)


def test_planted_scenarios_hold(data, planted):
    claim = _by(data, "claim", "claim_id")
    incident = _by(data, "incident", "incident_id")
    policy = _by(data, "policy", "policy_id")
    items, docs = _group(data["claim_item"]), _group(data["document"])
    ends, pcv = _lookups(data)
    required = _mandatory(data)
    for pl in planted:
        c = claim[pl["claim_id"]]
        inc, p = incident[c["incident_id"]], policy[c["policy_id"]]
        its = items[c["claim_id"]]
        row = pcv[(p["policy_id"], its[0]["coverage_id"])]
        amount, sc = its[0]["claimed_amount"], pl["scenario"]
        if sc == "lapsed_policy":
            assert inc["incident_date"] > ends[p["policy_id"]]
        elif sc == "outside_coverage_period":
            assert inc["incident_date"] < row["effective_start"]
        elif sc == "claim_over_limit":
            assert amount > row["limit_amount"]
        elif sc == "suspected_fraud":
            assert c["submission_date"] <= p["start_date"] + timedelta(days=config.FRAUD_F1_DAYS)
            assert amount >= 0.95 * row["limit_amount"]
        elif sc == "boundary_incident_on_start":
            assert inc["incident_date"] == p["start_date"] == row["effective_start"]
        elif sc == "boundary_incident_on_end":
            assert inc["incident_date"] == p["end_date"]
        elif sc == "boundary_amount_at_limit":
            assert amount == row["limit_amount"]
        elif sc == "boundary_amount_at_deductible":
            assert amount == row["deductible"] > 0
        elif sc == "duplicate_incident":
            src = claim[pl["detail"]]
            same = (
                incident[src["incident_id"]]["incident_date"],
                src["policy_id"],
                src["claim_type"],
            )
            assert same == (inc["incident_date"], c["policy_id"], c["claim_type"])
            assert src["submission_date"] < c["submission_date"]
            assert src["claim_id"] < c["claim_id"]
        elif sc == "incomplete_evidence":
            have = {d["doc_type"]: d for d in docs[c["claim_id"]]}
            gaps = [
                t
                for t in required[c["claim_type"]]
                if t not in have
                or (have[t]["received_date"] - c["submission_date"]).days > config.DOC_WINDOW_DAYS
            ]
            assert len(gaps) == 1, (pl, gaps)


def test_normal_claims_are_clean(data, planted):
    incident = _by(data, "incident", "incident_id")
    policy = _by(data, "policy", "policy_id")
    items, docs = _group(data["claim_item"]), _group(data["document"])
    ends, pcv = _lookups(data)
    required = _mandatory(data)
    special = {p["claim_id"] for p in planted}
    beyond = config.AS_OF + timedelta(days=1)
    for c in data["claim"]:
        if c["claim_id"] in special:
            continue
        inc, p = incident[c["incident_id"]], policy[c["policy_id"]]
        assert inc["incident_date"] <= p["end_date"]
        assert inc["incident_date"] < ends.get(p["policy_id"], beyond)
        for i in items[c["claim_id"]]:
            r = pcv[(p["policy_id"], i["coverage_id"])]
            assert r["effective_start"] <= inc["incident_date"] <= r["effective_end"]
        assert required[c["claim_type"]] <= {d["doc_type"] for d in docs[c["claim_id"]]}


def test_distribution_is_right_skewed_with_uneven_mix(data):
    amounts = [c["claimed_amount"] for c in data["claim"]]
    assert mean(amounts) > 1.2 * median(amounts)
    mix = Counter(c["claim_type"] for c in data["claim"])
    assert set(mix) == {"AUTO", "HOME", "HLTH", "TRVL", "LIAB"}
    assert max(mix.values()) > 2 * min(mix.values())


def test_only_labelled_duplicates_share_policy_and_incident_date(data, planted):
    incident = _by(data, "incident", "incident_id")
    groups = defaultdict(list)
    for c in data["claim"]:
        groups[(c["policy_id"], incident[c["incident_id"]]["incident_date"])].append(c["claim_id"])
    pairs = {tuple(sorted(g)) for g in groups.values() if len(g) > 1}
    expected = {
        tuple(sorted((p["claim_id"], p["detail"])))
        for p in planted
        if p["scenario"] == "duplicate_incident"
    }
    assert pairs == expected


def test_limit_cases_do_not_trip_other_fraud_flags_or_exclusions(data, planted):
    claim = _by(data, "claim", "claim_id")
    policy = _by(data, "policy", "policy_id")
    items = _group(data["claim_item"])
    for pl in planted:
        if pl["scenario"] in ("claim_over_limit", "boundary_amount_at_limit"):
            c = claim[pl["claim_id"]]
            start = policy[c["policy_id"]]["start_date"]
            assert c["submission_date"] > start + timedelta(days=config.FRAUD_F1_DAYS)
            assert all(i["item_type"] != "cosmetic" for i in items[pl["claim_id"]])
