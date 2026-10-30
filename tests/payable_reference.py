"""Independent reimplementation of the payable rule, written from the spec text (does not import claimsgen.rules).

Per coverage: payable = min(max(0, eligible - deductible), remaining limit).
remaining = limit minus the amounts already committed on earlier claims for that policy_coverage.
Eligible = claimed amount of items whose type is not in the coverage's exclusion_codes.
Claims are processed in (submission_date, incident_date, policy_id, claim_id) order. All money is integer cents.
"""


def claim_payable(items, terms, committed):
    """items: [(coverage_id, item_type, cents)]; terms: coverage_id -> (limit, deductible, excluded item types);
    committed: coverage_id -> cents already committed on earlier claims. Returns {coverage_id: payable cents}."""
    eligible = {}
    for coverage, item_type, cents in items:
        if item_type not in terms[coverage][2]:
            eligible[coverage] = eligible.get(coverage, 0) + cents
    result = {}
    for coverage, total in eligible.items():
        limit, deductible, _ = terms[coverage]
        remaining = limit - committed.get(coverage, 0)
        after_deductible = total - deductible
        after_deductible = max(after_deductible, 0)
        result[coverage] = after_deductible if after_deductible < remaining else max(remaining, 0)
    return result


def processing_order(tables):
    incident_date = {i["incident_id"]: i["incident_date"] for i in tables["incident"]}
    return sorted(
        tables["claim"],
        key=lambda c: (
            c["submission_date"],
            incident_date[c["incident_id"]],
            c["policy_id"],
            c["claim_id"],
        ),
    )


def replay(tables, approved_claim_ids):
    """Recompute the payable amount of every claim in approved_claim_ids, in processing order, committing our own amounts."""
    excluded = {
        c["coverage_id"]: set(filter(None, c["exclusion_codes"].split("|")))
        for c in tables["coverage"]
    }
    terms = {}
    for r in tables["policy_coverage"]:
        terms[(r["policy_id"], r["coverage_id"])] = (
            r["limit_amount"],
            r["deductible"],
            excluded[r["coverage_id"]],
        )
    items = {}
    for i in tables["claim_item"]:
        items.setdefault(i["claim_id"], []).append(i)
    committed: dict = {}
    out = {}
    for c in processing_order(tables):
        if c["claim_id"] not in approved_claim_ids:
            continue
        pid = c["policy_id"]
        rows = [
            (i["coverage_id"], i["item_type"], i["claimed_amount"]) for i in items[c["claim_id"]]
        ]
        local_terms = {cov: terms[(pid, cov)] for cov, _, _ in rows}
        local_committed = {cov: committed.get((pid, cov), 0) for cov in local_terms}
        amounts = claim_payable(rows, local_terms, local_committed)
        for cov, cents in amounts.items():
            committed[(pid, cov)] = committed.get((pid, cov), 0) + cents
        out[c["claim_id"]] = sum(amounts.values())
    return out


def last_approved(tables):
    """claim_id of every claim whose last assessment decision is approve."""
    last = {}
    for a in tables["assessment"]:
        last[a["claim_id"]] = a["decision"]
    return {cid for cid, d in last.items() if d == "approve"}
