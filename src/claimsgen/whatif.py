"""What-if evaluation of a claim submitted through intake: the REAL engine runs on the input tables plus the draft, without
changing the dataset (the engine does not mutate input rows, so the lists are only shallow-copied).

The draft becomes one provisional claim (PROVISIONAL_CLAIM sorts after every real id, so same-day ties go to real claims) and the
engine runs to the intake horizon (config.intake_horizon()), so its whole workflow is visible. Only that claim's rows are read back.

Ordering semantics: existing claims submitted LATER than the draft are processed after it. If the draft would change their
outcome (a shared limit, a duplicate key), that effect is NOT shown; only the draft's own outcome is. ground_truth is never used.
"""

from datetime import timedelta

from claimsgen import config, engine, ids, rules, sensitivity, view_data
from claimsgen.draft import Doc, Draft

PROVISIONAL_CLAIM = "CLM-2026-999999"
PROVISIONAL_INCIDENT = "INC-2026-999999"
NOTE = (
    "What-if only: the dataset is unchanged. Existing claims submitted after this draft are not re-evaluated, "
    "so any effect the draft would have on them is not shown."
)


def _policy(tables: dict, draft: Draft) -> dict:
    return next(p for p in tables["policy"] if p["policy_id"] == draft.policy_id)


def _docs(draft: Draft) -> list[dict]:
    return [
        {
            "document_id": ids.doc(PROVISIONAL_CLAIM, n),
            "claim_id": PROVISIONAL_CLAIM,
            "doc_type": d.doc_type,
            "received_date": d.received_date,
            "status": d.status,
        }
        for n, d in enumerate(draft.documents, 1)
    ]


def missing_documents(tables: dict, draft: Draft) -> list[str]:
    """Mandatory document types for the policy's product not received within the document window of submission."""
    product = _policy(tables, draft)["product"]
    required = {
        r["doc_type"]
        for r in tables["document_requirement"]
        if r["claim_type"] == product and r["mandatory"] == "Y"
    }
    return rules.missing_docs(required, _docs(draft), draft.submission_date)


def _inputs(tables: dict, draft: Draft) -> dict:
    """Input tables only (outputs dropped), lists copied, with the provisional rows appended."""
    t = {k: list(v) for k, v in tables.items() if k not in sensitivity.OUTPUT_TABLES}
    product = _policy(tables, draft)["product"]
    t["incident"].append(
        {
            "incident_id": PROVISIONAL_INCIDENT,
            "policy_id": draft.policy_id,
            "incident_date": draft.incident_date,
            "incident_type": draft.incident_type,
        }
    )
    t["claim"].append(
        {
            "claim_id": PROVISIONAL_CLAIM,
            "policy_id": draft.policy_id,
            "incident_id": PROVISIONAL_INCIDENT,
            "claim_type": product,
            "submission_date": draft.submission_date,
            "claimed_amount": sum(i.cents for i in draft.items),
        }
    )
    t["claim_item"] += [
        {
            "item_id": ids.itm(PROVISIONAL_CLAIM, n),
            "claim_id": PROVISIONAL_CLAIM,
            "coverage_id": i.coverage_id,
            "item_type": i.item_type,
            "claimed_amount": i.cents,
        }
        for n, i in enumerate(draft.items, 1)
    ]
    t["document"] += _docs(draft)
    return t


def evaluate(tables: dict, draft: Draft) -> dict:
    """Run the engine on the draft as a what-if. Keys: claim, incident, decision, timeline, rule_trace, counterfactual,
    assessments, reserve, settlement, assignments, history, horizon, missing_documents, note."""
    inputs = _inputs(tables, draft)
    horizon = config.intake_horizon()
    out = engine.run(inputs, as_of=horizon)

    def mine(rows):
        return [r for r in rows if r["claim_id"] == PROVISIONAL_CLAIM]

    claim = next(c for c in inputs["claim"] if c["claim_id"] == PROVISIONAL_CLAIM)
    asm, hist = mine(out["assessment"]), mine(out["claim_status_history"])
    combined = {**inputs, **out}
    one = {"claim": [claim], "assessment": asm, "claim_status_history": hist}
    return {
        "claim": claim,
        "incident": next(i for i in inputs["incident"] if i["incident_id"] == PROVISIONAL_INCIDENT),
        "decision": view_data.decisions_table(one)[0],
        "timeline": view_data.claim_detail(combined, PROVISIONAL_CLAIM)["timeline"],
        "rule_trace": view_data.rule_trace(combined, PROVISIONAL_CLAIM),
        "counterfactual": view_data.counterfactual(combined, PROVISIONAL_CLAIM),
        "assessments": asm,
        "reserve": mine(out["reserve"]),
        "settlement": mine(out["settlement"]),
        "assignments": mine(out["claim_adjuster_assignment"]),
        "history": hist,
        "horizon": horizon,
        "missing_documents": missing_documents(tables, draft),
        "note": NOTE,
    }


def request_docs(tables: dict, draft: Draft, day=None) -> Draft:
    """New draft with one received document per missing mandatory type, arriving on `day`.

    Default day is submission + document window + 1 (outside the window, so the claim pends first and then resumes), capped at
    the intake horizon.
    """
    missing = missing_documents(tables, draft)
    day = day or min(
        draft.submission_date + timedelta(days=config.DOC_WINDOW_DAYS + 1), config.intake_horizon()
    )
    extra = tuple(Doc(t, day) for t in missing)
    return Draft(
        draft.policy_id,
        draft.incident_date,
        draft.incident_type,
        draft.submission_date,
        draft.items,
        draft.documents + extra,
    )
