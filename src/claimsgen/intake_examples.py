"""Example claims for the intake tab, each deliberately reaching one rule.

They are chosen deterministically from the dataset INPUT tables (policy ids differ by scale): policy ids are scanned in sorted order
and the first suitable candidate wins. Candidates are filtered so no earlier rule or fraud flag pre-empts the target rule. Nothing
here reads ground_truth, uses randomness or the clock; every date is explicit and not after config.intake_horizon().
"""

from dataclasses import dataclass
from datetime import date, timedelta

from claimsgen import config, masterdata
from claimsgen.draft import Doc, Draft, Item

EXPECTED = {
    "clean_approve": ("approve", "R-PAY-01", "eligible"),
    "missing_document": ("pend_docs", "R-DOC-01", "missing_document"),
    "duplicate": ("refer_review", "R-ELG-03", "duplicate_claim"),
    "lapsed_policy": ("deny", "R-COV-02", "policy_not_in_force"),
    "over_limit": ("approve", "R-PAY-01", "limit_reached"),
    "claim_before_start": ("deny", "R-COV-01", "before_policy_start"),
    "within_deductible": ("deny", "R-PAY-01", "within_deductible"),
}
TITLES = {
    "clean_approve": ("Clean claim", "Approved: all documents present and the amount is well under the limit (R-PAY-01)."),
    "missing_document": ("Missing document", "Pends for documents: one mandatory document is not received (R-DOC-01)."),
    "duplicate": ("Duplicate claim", "Referred for review: same policy, incident date and type as an earlier claim (R-ELG-03)."),
    "lapsed_policy": ("Lapsed policy", "Denied: the incident is after the policy lapsed (R-COV-02)."),
    "over_limit": ("Over the limit", "Approved but capped: the amount exceeds the coverage limit (R-PAY-01)."),
    "claim_before_start": ("Before policy start", "Denied: the claim is submitted before the policy starts (R-COV-01)."),
    "within_deductible": ("Within deductible", "Denied: the amount only equals the deductible, so nothing is payable (R-PAY-01)."),
}  # fmt: skip
DAYS_AFTER_START = config.FRAUD_F1_DAYS + 1  # incident this long after start, so F1 cannot fire
REPORT_LAG = 2  # days from incident to submission (well under the F4 limit)


@dataclass(frozen=True)
class Example:
    key: str
    title: str
    expect: str
    draft: Draft


@dataclass(frozen=True)
class _Cand:
    """A policy with one usable coverage, its valid incident/item types and the dates it can be claimed on."""

    policy: dict
    pcv: dict
    incident_type: str
    item_type: str
    lo: date  # first claimable day (policy and coverage effective)
    hi: date  # last claimable day


def _ctx(t: dict) -> dict:
    name = {c["coverage_id"]: c["name"] for c in t["coverage"]}
    excl = {
        c["coverage_id"]: set(filter(None, c["exclusion_codes"].split("|"))) for c in t["coverage"]
    }
    required: dict = {}
    for r in t["document_requirement"]:
        if r["mandatory"] == "Y":
            required.setdefault(r["claim_type"], set()).add(r["doc_type"])
    ends: dict = {}
    for e in t["policy_event"]:
        if e["event_type"] in ("lapsed", "cancelled"):
            ends[e["policy_id"]] = min(e["event_date"], ends.get(e["policy_id"], e["event_date"]))
    pcv: dict = {}
    for r in sorted(t["policy_coverage"], key=lambda r: r["policy_coverage_id"]):
        pcv.setdefault(r["policy_id"], []).append(r)
    inc = {i["incident_id"]: i for i in t["incident"]}
    claims_of: dict = {}
    for c in t["claim"]:
        claims_of.setdefault(c["policy_id"], []).append(c)
    owner = {p["policy_id"]: p["customer_id"] for p in t["policy"]}
    by_customer: dict = {}
    for c in t["claim"]:
        by_customer[owner[c["policy_id"]]] = by_customer.get(owner[c["policy_id"]], 0) + 1
    return {
        "name": name,
        "excl": excl,
        "required": required,
        "ends": ends,
        "pcv": pcv,
        "inc": inc,
        "claims_of": claims_of,
        "by_customer": by_customer,
        "t": t,
    }


def _cands(x: dict, plain: bool = True) -> list[_Cand]:
    """Candidates in sorted policy order. plain=True keeps only policies that cannot trip other rules: no lapse/cancel
    event, no existing claim on the policy (limits, duplicates) and fewer than F2_MIN claims by the customer."""
    out = []
    for p in sorted(x["t"]["policy"], key=lambda p: p["policy_id"]):
        pid = p["policy_id"]
        if plain and (
            pid in x["ends"]
            or pid in x["claims_of"]
            or x["by_customer"].get(p["customer_id"], 0) >= config.FRAUD_F2_MIN
        ):
            continue
        for r in x["pcv"].get(pid, []):
            incidents, items = masterdata.COVERAGE_PROFILE[x["name"][r["coverage_id"]]]
            ok = [i for i in items if i not in x["excl"][r["coverage_id"]]]
            lo = max(p["start_date"], r["effective_start"])
            hi = min(p["end_date"], r["effective_end"])
            if ok and r["limit_amount"] > 0 and lo <= hi:
                out.append(_Cand(p, r, incidents[0], ok[0], lo, hi))
                break
    return out


def _docs(x: dict, product: str, day: date, skip: str | None = None) -> tuple[Doc, ...]:
    return tuple(Doc(d, day) for d in sorted(x["required"][product]) if d != skip)


def _draft(x: dict, c: _Cand, incident: date, cents: int, skip: str | None = None) -> Draft:
    sub = incident + timedelta(days=REPORT_LAG)
    item = Item(c.pcv["coverage_id"], c.item_type, cents)
    return Draft(
        c.policy["policy_id"], incident, c.incident_type, sub, (item,),
        _docs(x, c.policy["product"], sub, skip),
    )  # fmt: skip


def _claimable(c: _Cand) -> bool:
    """Incident DAYS_AFTER_START after the start sits inside the windows and the submission is within the horizon."""
    day = c.policy["start_date"] + timedelta(days=DAYS_AFTER_START)
    return c.lo <= day <= c.hi and day + timedelta(days=REPORT_LAG) <= config.intake_horizon()


def _normal(x: dict, cents, skip_doc: bool = False, need=lambda c: True) -> Draft:
    c = next((c for c in _cands(x) if _claimable(c) and need(c)), None)
    if c is None:
        raise LookupError("no claimable policy for this example")
    day = c.policy["start_date"] + timedelta(days=DAYS_AFTER_START)
    skip = min(x["required"][c.policy["product"]]) if skip_doc else None
    return _draft(x, c, day, cents(c.pcv), skip)


def _duplicate(x: dict) -> Draft:
    t = x["t"]
    assessed = {a["claim_id"] for a in t["assessment"] if not a["rule_id"].startswith("R-COV")}
    horizon = config.intake_horizon()
    for c in sorted(t["claim"], key=lambda c: c["claim_id"]):
        if c["claim_id"] not in assessed or c["submission_date"] + timedelta(days=3) > horizon:
            continue
        i = x["inc"][c["incident_id"]]
        items = tuple(
            Item(m["coverage_id"], m["item_type"], m["claimed_amount"])
            for m in t["claim_item"]
            if m["claim_id"] == c["claim_id"]
        )
        sub = c["submission_date"] + timedelta(days=3)
        return Draft(
            c["policy_id"], i["incident_date"], i["incident_type"], sub, items,
            _docs(x, c["claim_type"], sub),
        )  # fmt: skip
    raise LookupError("no assessed claim to duplicate")


def _lapsed(x: dict) -> Draft:
    for c in _cands(x, plain=False):
        stop = x["ends"].get(c.policy["policy_id"])
        if stop is None:
            continue
        day = max(stop, c.lo) + timedelta(days=1)
        sub = day + timedelta(days=REPORT_LAG)
        if stop >= c.lo and day <= c.hi and sub <= config.intake_horizon():
            return _draft(x, c, day, c.pcv["limit_amount"] // 10)
    raise LookupError("no lapsed policy")


def _before_start(x: dict) -> Draft:
    cands = _cands(x)
    if not cands:
        raise LookupError("no policy for the before-start example")
    c = cands[0]
    start = c.policy["start_date"]
    sub = start - timedelta(days=5)
    item = Item(c.pcv["coverage_id"], c.item_type, c.pcv["limit_amount"] // 10)
    return Draft(
        c.policy["policy_id"], start - timedelta(days=10), c.incident_type, sub,
        (item,), _docs(x, c.policy["product"], sub),
    )  # fmt: skip


def build(tables: dict) -> list[Example]:
    x = _ctx(tables)
    drafts = {
        "clean_approve": _normal(x, lambda r: r["deductible"] + r["limit_amount"] // 10),
        "missing_document": _normal(x, lambda r: r["limit_amount"] // 10, skip_doc=True),
        "duplicate": _duplicate(x),
        "lapsed_policy": _lapsed(x),
        "over_limit": _normal(x, lambda r: r["limit_amount"] + r["deductible"] + 10_000),
        "claim_before_start": _before_start(x),
        "within_deductible": _normal(x, lambda r: r["deductible"], need=lambda c: c.pcv["deductible"] > 0),
    }  # fmt: skip
    return [Example(k, TITLES[k][0], TITLES[k][1], drafts[k]) for k in EXPECTED]
