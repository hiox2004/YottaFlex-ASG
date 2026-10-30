"""Assign final claim-derived IDs once, after injection, through a single old->new map.

Claims are sorted by (submission_date, incident_date, policy_id, old claim_id) and numbered 1..N; incidents follow their claim;
child rows are renumbered per claim in their existing order (so deleted documents leave no gaps and injected rows cannot be
spotted by ID position). The map is returned so ground_truth ids can be translated by one lookup, never sequentially.
"""

from claimsgen import ids

CHILDREN = {
    "claim_item": ("item_id", ids.itm),
    "document": ("document_id", ids.doc),
    "claim_adjuster_assignment": ("assignment_id", ids.asn),
    "assessment": ("assessment_id", ids.asm),
    "reserve": ("reserve_id", ids.rsv),
    "settlement": ("settlement_id", ids.settlement),
    "claim_status_history": ("event_id", ids.evt),
}


def finalize(tables: dict) -> tuple[dict, dict]:
    incident = {i["incident_id"]: i for i in tables["incident"]}
    order = sorted(
        tables["claim"],
        key=lambda c: (
            c["submission_date"],
            incident[c["incident_id"]]["incident_date"],
            c["policy_id"],
            c["claim_id"],
        ),
    )
    idmap: dict = {}
    out = dict(tables)
    out["claim"], out["incident"] = [], []
    for n, c in enumerate(order, start=1):
        idmap[c["claim_id"]], idmap[c["incident_id"]] = ids.clm(n), ids.inc(n)
        out["claim"].append(dict(c, claim_id=ids.clm(n), incident_id=ids.inc(n)))
        out["incident"].append(dict(incident[c["incident_id"]], incident_id=ids.inc(n)))
    known = {c["claim_id"] for c in order}
    row_of_policy = {p["policy_id"]: i for i, p in enumerate(tables["policy"])}
    # injected events were appended last; re-sort so row position never reveals them
    out["policy_event"] = sorted(
        tables["policy_event"],
        key=lambda e: (row_of_policy[e["policy_id"]], e["event_date"], e["event_id"]),
    )
    for table, (pk, fmt) in CHILDREN.items():
        groups: dict = {}
        for r in tables[table]:
            groups.setdefault(r["claim_id"], []).append(r)
        assert set(groups) <= known, f"{table}: rows reference an unknown claim"
        out[table] = []
        for c in order:
            new_claim = idmap[c["claim_id"]]
            for k, r in enumerate(groups.get(c["claim_id"], []), start=1):
                idmap[r[pk]] = fmt(new_claim, k)
                out[table].append(dict(r, claim_id=new_claim, **{pk: fmt(new_claim, k)}))
    for table in CHILDREN:
        assert len(out[table]) == len(tables[table]), f"{table}: rows lost during renumbering"
    return out, idmap
