"""Read-first panel: units and basic terms a reviewer needs before using the tabs. Rendering only; numbers come from config."""

import streamlit as st

from claimsgen import config


def text() -> str:
    approver = config.APPROVER_THRESHOLD_CENTS // 100
    return f"""
| Term | Meaning here |
|---|---|
| Currency | {config.CURRENCY}. Tables show exact amounts with two decimals (1250.00); the engine counts in whole cents, so there is no rounding drift. |
| Dates | ISO `YYYY-MM-DD`. "Today" is fixed at **{config.AS_OF}** (never the real clock), so every run gives the same answer. The what-if tab evaluates up to {config.intake_horizon()} or later. |
| Claim types | AUTO, HOME, HLTH (health), TRVL (travel), LIAB (liability). Policy ids look like `POL-AUTO-2026-000001`, claims `CLM-2026-000001`. |
| Limit | The most a coverage pays in total on a policy. Earlier claims use it up, so a later claim can be paid only the remaining limit. |
| Deductible | The part of each claim the customer bears first. Payable = min(max(0, eligible amount - deductible), remaining limit) (R-PAY-01). |
| Reserve | Money set aside: an estimate at first notice (R-RSV-01), revised to the payable when the claim is decided (R-RSV-02). |
| Documents | Each claim type has mandatory documents. One must arrive within {config.DOC_WINDOW_DAYS} days of submission or the claim waits in `docs_pending` (R-DOC-01). |
| Decisions | `approve`, `deny`, `pend_docs` (waiting for documents), `refer_review` (a person must look: duplicate or suspected fraud). |
| Statuses | submitted, docs_pending, assessed, approved, paid, denied, under_review. Status changes are appended to a history, never overwritten. |
| Approval | Payable above {approver:,} {config.CURRENCY} goes to the approver role; otherwise the process owner (R-APR-01). |
| Fraud score | Flags divided by 4 (new policy, many recent claims, near-limit amount, late report); at or above {config.FRAUD_THRESHOLD} the claim is referred (R-FRD-05). |
| Rule ids | R-COV coverage, R-ELG eligibility, R-DOC documents, R-FRD fraud, R-PAY payment, R-RSV reserve, R-APR approval. Every decision names one. |
| Data | Fully synthetic, seed 20261022. The starter is 100 policies and 50 claims; the full set is 2,000 and 1,000. Answers (ground truth) are used only to score the engine, never to decide a claim. |
"""


def render() -> None:
    with st.expander("Read first: units and basic terms"):
        st.markdown(text())
