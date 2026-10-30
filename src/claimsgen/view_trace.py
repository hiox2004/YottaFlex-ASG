"""Per-claim rule trace and counterfactual for the view (IMP-006).

Both functions take only the dataset tables. The trace is derived solely from the claim's assessments and status history; the
counterfactual re-reads input rows and rules.py functions to say what would make a stopped claim payable. No ground_truth.
"""

import math

from claimsgen import config, rules

PRE = ["R-COV-01", "R-COV-02", "R-COV-03", "R-ELG-03", "R-DOC-01"]
POST = ["R-FRD-05", "R-ELG-02", "R-PAY-01"]
ORDER = PRE + POST + ["R-RSV-01", "R-APR-01"]
PASSED, STOPPED, SKIPPED = "passed", "failed-and-stopped", "not evaluated"


def _usd(cents: int) -> str:
    return f"{cents / 100:,.2f}"


def _step(rule: str, outcome: str, a=None, event=None, run: str = "") -> dict:
    return {
        "rule_id": rule,
        "description": rules.RULES[rule],
        "outcome": outcome,
        "date": (a["assessment_date"] if a else "") if event is None else event["event_date"],
        "actor_role": event["actor_role"] if event else ("operations_analyst" if a else ""),
        "reason_code": (a["reason_code"] if outcome == STOPPED else "") if a else "",
        "run": run if outcome != SKIPPED else "",
    }


def _stamp(row: dict) -> dict:
    row["date"] = row["date"].isoformat() if row["date"] else ""
    return row


def rule_trace(tables: dict, claim_id: str) -> list[dict]:
    """Ordered decision path with the outcome of each rule step, from assessments and status history only."""
    asm = [a for a in tables["assessment"] if a["claim_id"] == claim_id]
    hist = [e for e in tables["claim_status_history"] if e["claim_id"] == claim_id]

    def event_of(a):
        return next(
            (
                e
                for e in hist
                if e["rule_id"] == a["rule_id"]
                and e["event_date"] == a["assessment_date"]
                and e["from_status"] in ("submitted", "docs_pending")
            ),
            None,
        )

    if not asm:
        return [_stamp(_step(r, SKIPPED)) for r in ORDER]
    first, last, resumed = asm[0], asm[-1], len(asm) > 1
    run = "re-run after documents" if resumed else "initial"
    stop = PRE.index(first["rule_id"]) if first["rule_id"] in PRE else len(PRE)
    rows = []
    for i, rule in enumerate(PRE):
        if i < stop:
            rows.append(_step(rule, PASSED, first, event_of(first), "initial"))
        elif i == stop and resumed:
            rows.append(_step(rule, PASSED, last, event_of(last), run))
        elif i == stop:
            rows.append(_step(rule, STOPPED, first, event_of(first), "initial"))
        else:
            rows.append(_step(rule, SKIPPED))
    reached = last["rule_id"] in POST
    end = POST.index(last["rule_id"]) if reached else -1
    for j, rule in enumerate(POST):
        if not reached or j > end:
            rows.append(_step(rule, SKIPPED))
        elif j < end or last["decision"] == "approve":
            rows.append(_step(rule, PASSED, last, event_of(last), run))
        else:
            rows.append(_step(rule, STOPPED, last, event_of(last), run))
    approved = next((e for e in hist if e["to_status"] == "approved"), None)
    if last["decision"] != "approve":
        rows += [_step("R-RSV-01", SKIPPED), _step("R-APR-01", SKIPPED)]
    else:
        rows.append(_step("R-RSV-01", PASSED, last, event_of(last), run))
        rows.append(
            _step("R-APR-01", PASSED, last, approved, run)
            if approved
            else _step("R-APR-01", SKIPPED)
        )
    if approved:
        rows[-1]["reason_code"] = approved["reason_code"]
    return [_stamp(r) for r in rows]


class _Ctx:
    """Lookups over the input tables for one claim."""

    def __init__(self, t: dict, claim_id: str):
        self.t = t
        self.claim = next(c for c in t["claim"] if c["claim_id"] == claim_id)
        self.policy = next(p for p in t["policy"] if p["policy_id"] == self.claim["policy_id"])
        inc = {i["incident_id"]: i["incident_date"] for i in t["incident"]}
        self.day = inc[self.claim["incident_id"]]
        self.items = [i for i in t["claim_item"] if i["claim_id"] == claim_id]
        self.pcv = {
            r["coverage_id"]: r
            for r in t["policy_coverage"]
            if r["policy_id"] == self.policy["policy_id"]
        }

        def key(c):
            return (c["submission_date"], inc[c["incident_id"]], c["policy_id"], c["claim_id"])

        mine = key(self.claim)
        self.earlier = [c for c in sorted(t["claim"], key=key) if key(c) < mine]
        self.inc = inc


def _cov(x: _Ctx) -> str:
    stop = None
    for e in sorted(x.t["policy_event"], key=lambda e: e["event_date"]):
        if e["policy_id"] == x.policy["policy_id"] and e["event_type"] in ("lapsed", "cancelled"):
            stop, kind = e["event_date"], e["event_type"]
            break
    p = x.policy
    if stop and stop <= x.day:
        return f"coverage ended on {stop} ({kind}) before incident {x.day}; the incident must fall before that date"
    return f"incident {x.day} is outside the policy dates {p['start_date']}..{p['end_date']}"


def _dup(x: _Ctx) -> str:
    c = x.claim
    same = [
        e["claim_id"]
        for e in x.earlier
        if (e["policy_id"], e["claim_type"], x.inc[e["incident_id"]])
        == (c["policy_id"], c["claim_type"], x.day)
    ]
    return (
        f"earlier claim {same[0] if same else '?'} has the same policy, incident date {x.day} and type "
        f"{c['claim_type']}; it is payable only if it is a different incident"
    )


def _docs(x: _Ctx) -> str:
    need = {
        r["doc_type"]
        for r in x.t["document_requirement"]
        if r["claim_type"] == x.claim["claim_type"] and r["mandatory"] == "Y"
    }
    docs = [d for d in x.t["document"] if d["claim_id"] == x.claim["claim_id"]]
    missing = rules.missing_docs(need, docs, x.claim["submission_date"])
    return f"missing mandatory documents {', '.join(missing) or 'none'} must be received within {config.DOC_WINDOW_DAYS} days of submission"


def _fraud(x: _Ctx, a: dict) -> str:
    claimed: dict = {}
    for i in x.items:
        claimed[i["coverage_id"]] = claimed.get(i["coverage_id"], 0) + i["claimed_amount"]
    customer = x.policy["customer_id"]
    pols = {p["policy_id"]: p["customer_id"] for p in x.t["policy"]}
    subs = [c["submission_date"] for c in x.earlier if pols[c["policy_id"]] == customer]
    limits = {k: r["limit_amount"] for k, r in x.pcv.items()}
    flags = rules.fraud_flags(x.claim, x.day, x.policy, claimed, limits, subs)
    active = [f"{k} ({rules.RULES['R-FRD-0' + k[1]][4:]})" for k, v in flags.items() if v]
    cut = config.FRAUD_THRESHOLD
    drop = len(active) - (math.ceil(cut * 4) - 1)
    return (
        f"fraud score {a['fraud_score']:.2f} is at or above the cutoff {cut}; active flags: {'; '.join(active)}; "
        f"at least {max(drop, 1)} flag(s) would have to clear"
    )


def _excluded(x: _Ctx) -> str:
    types = sorted({i["item_type"] for i in x.items})
    return f"all items are excluded types ({', '.join(types)}); at least one non-excluded item is needed"


def _pay(x: _Ctx, a: dict) -> str:
    codes = {
        c["coverage_id"]: set(filter(None, c["exclusion_codes"].split("|")))
        for c in x.t["coverage"]
    }
    elig = rules.eligible_by_coverage(x.items, codes)
    if a["reason_code"] == "within_deductible":
        parts = [
            f"{cov}: claimed {_usd(e)} must exceed deductible {_usd(x.pcv[cov]['deductible'])}"
            for cov, e in sorted(elig.items())
        ]
        return "within deductible, " + "; ".join(parts)
    ids = {c["claim_id"] for c in x.earlier if c["policy_id"] == x.policy["policy_id"]}
    used = sum(s["recommended_amount"] for s in x.t["settlement"] if s["claim_id"] in ids)
    limits = ", ".join(f"{k} {_usd(x.pcv[k]['limit_amount'])}" for k in sorted(elig))
    return f"limit reached: earlier settlements on this policy total {_usd(used)} against limit {limits}; nothing remains to pay"


def counterfactual(tables: dict, claim_id: str) -> list[str]:
    """Plain-language list of what would make a stopped claim payable."""
    x = _Ctx(tables, claim_id)
    asm = [a for a in tables["assessment"] if a["claim_id"] == claim_id]
    if not asm:
        return ["Not assessed yet: nothing blocks the claim, the assessment is still due."]
    a = asm[-1]
    rule = a["rule_id"]
    if a["decision"] == "approve":
        note = " (capped at the remaining limit)" if a["reason_code"] == "limit_reached" else ""
        return [f"Already payable: {_usd(a['payable_amount'])} USD{note} ({rule})."]
    texts = {
        "R-COV-01": lambda: (
            f"submission {x.claim['submission_date']} must be on or after policy start {x.policy['start_date']}"
        ),
        "R-COV-02": lambda: _cov(x),
        "R-COV-03": lambda: "incident {} is outside the coverage dates {}".format(
            x.day,
            "; ".join(
                f"{k} {r['effective_start']}..{r['effective_end']}"
                for k, r in sorted(x.pcv.items())
                if k in {i["coverage_id"] for i in x.items}
            ),
        ),
        "R-ELG-03": lambda: _dup(x),
        "R-DOC-01": lambda: _docs(x),
        "R-FRD-05": lambda: _fraud(x, a),
        "R-ELG-02": lambda: _excluded(x),
        "R-PAY-01": lambda: _pay(x, a),
    }
    return [f"{rule}: {texts[rule]()}."]
