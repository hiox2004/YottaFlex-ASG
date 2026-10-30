"""Run-wide constants and the seeded RNG factory. AS_OF replaces the system clock everywhere."""

from dataclasses import dataclass
from datetime import date
from random import Random

from claimsgen import SEED

AS_OF = date(2026, 10, 22)
CURRENCY = "USD"
APPROVER_THRESHOLD_CENTS = 1_000_000  # payable above this needs the approver role
DOC_WINDOW_DAYS = 5  # R-DOC-01: a document counts only if received_date <= submission_date + this
FRAUD_F1_DAYS = 30  # F1: submission within this many days after policy start (inclusive)
FRAUD_F2_DAYS = 90  # F2: window for earlier claims by the same customer (inclusive)
FRAUD_F2_MIN = 3  # F2 fires with at least this many EARLIER claims in the window
FRAUD_F4_DAYS = 60  # F4: reported more than this many days after the incident
FRAUD_THRESHOLD = 0.5  # fraud_score = flags / 4; at or above this the claim goes to review


@dataclass(frozen=True)
class Counts:
    policies: int
    claims: int
    customers: int
    adjusters: int


def counts(scale: float) -> Counts:
    """Row counts for a scale (1.0 = 2,000 policies / 1,000 claims; starter = 0.05)."""
    policies = max(10, round(2000 * scale))
    return Counts(
        policies=policies,
        claims=max(5, round(1000 * scale)),
        customers=max(5, round(policies * 0.625)),
        adjusters=max(10, round(30 * scale)),
    )


def rng(stream: str) -> Random:
    """Independent, reproducible RNG per named stream, e.g. rng('policies')."""
    return Random(f"{SEED}:{stream}")


# Share of baseline claims planted for each documented condition (brief step 4 + boundary cases).
SCENARIO_RATES = {
    "lapsed_policy": 0.04,
    "outside_coverage_period": 0.03,
    "incomplete_evidence": 0.07,
    "claim_over_limit": 0.03,
    "suspected_fraud": 0.03,
    "duplicate_incident": 0.02,
    "boundary_incident_on_start": 0.01,
    "boundary_incident_on_end": 0.01,
    "boundary_amount_at_limit": 0.01,
    "boundary_amount_at_deductible": 0.01,
}


def scenario_counts(n_claims: int) -> dict[str, int]:
    return {k: max(1, round(r * n_claims)) for k, r in SCENARIO_RATES.items()}


def inject_rows(scale: float) -> int:
    """Rows per injected edge case (10-30 at full scale); injected duplicates are carved out of the claim total."""
    return max(2, round(15 * scale))
