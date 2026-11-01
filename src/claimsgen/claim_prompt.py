"""A copy-and-paste prompt that asks any AI chat to write one test claim for the intake tab.

Built from the dataset INPUT tables only (real policy ids, coverages, limits and document rules), so what the chat returns
validates. No ground_truth, no randomness, no clock. The pasted JSON still goes through intake.parse_and_validate and the rules.
"""

from claimsgen import config, intake, vocab

SAMPLE_PER_PRODUCT = 1

HEAD = """You write test claims for an insurance claims workflow. Reply with ONE JSON object only (no markdown, no comments).

Shape:
{"policy_id": "...", "incident_date": "YYYY-MM-DD", "incident_type": "...", "submission_date": "YYYY-MM-DD",
 "items": [{"coverage_id": "...", "item_type": "...", "amount": 1234.50}],
 "documents": [{"doc_type": "...", "received_date": "YYYY-MM-DD", "status": "received"}]}

Rules for the form (structure only; the workflow decides the outcome):
- incident_date <= submission_date, and every date is between 1900-01-01 and @HORIZON@.
- documents[].received_date is on or after submission_date; status is "received" or "rejected".
- amount is USD, greater than 0, at most 2 decimals. 1 to 20 items.
- Use only the ids below.
- Mandatory documents must be received within @WINDOW@ days of submission or the claim pends.
- The same policy, incident date and claim type as an earlier claim is a duplicate.
- incident_type must be one of the policy's incident types, and each item's coverage must belong to that policy.
- An incident outside the policy start-end dates is denied; an item type the coverage does not list is denied; an amount at or below the deductible pays nothing; above the limit is paid at the limit.

Policies you may use (a sample; start, end, then each coverage with limit and deductible in USD, item types paid):
"""

TAIL = """
Document types: {docs}
Today in the dataset is {as_of}.

The scenario I want to test: {scenario}
"""


def _policy_lines(tables: dict) -> list[str]:
    cov = {c["coverage_id"]: c for c in tables["coverage"]}
    required: dict[str, list[str]] = {}
    for r in tables["document_requirement"]:
        if r["mandatory"] == "Y":
            required.setdefault(r["claim_type"], []).append(r["doc_type"])
    seen: dict[str, int] = {}
    lines = []
    for p in sorted(tables["policy"], key=lambda r: r["policy_id"]):
        product = p["product"]
        if seen.get(product, 0) >= SAMPLE_PER_PRODUCT or not intake.policy_coverages(
            tables, p["policy_id"]
        ):
            continue
        seen[product] = seen.get(product, 0) + 1
        lines.append(
            f"- {p['policy_id']} ({product}) {p['start_date']} to {p['end_date']}; "
            f"incident types: {', '.join(intake.incident_types(tables, product))}; "
            f"mandatory documents: {', '.join(required.get(product, []))}"
        )
        for pc in tables["policy_coverage"]:
            if pc["policy_id"] == p["policy_id"]:
                lines.append(
                    f"    {pc['coverage_id']} ({cov[pc['coverage_id']]['name']}) limit {pc['limit_amount'] / 100:,.0f}, "
                    f"deductible {pc['deductible'] / 100:,.0f}; item types: "
                    f"{', '.join(intake.coverage_item_types(tables, pc['coverage_id']))}"
                )
    return lines


def build(
    tables: dict, scenario: str = "<describe it, e.g. a theft claim that is over the limit>"
) -> str:
    head = HEAD.replace("@HORIZON@", config.intake_horizon().isoformat()).replace(
        "@WINDOW@", str(config.DOC_WINDOW_DAYS)
    )
    tail = TAIL.format(
        docs=", ".join(vocab.DOC_TYPES), as_of=config.AS_OF.isoformat(), scenario=scenario
    )
    return head + "\n".join(_policy_lines(tables)) + "\n" + tail
