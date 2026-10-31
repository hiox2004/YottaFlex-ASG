"""Run-wide constants and the seeded RNG factory. AS_OF replaces the system clock everywhere."""

import math
from dataclasses import dataclass
from datetime import date, timedelta
from random import Random

from claimsgen import SEED

AS_OF = date(2026, 10, 22)
INTAKE_HORIZON_DAYS = (
    30  # a submitted claim is evaluated up to AS_OF + this, so its whole workflow is visible
)
CURRENCY = "USD"
APPROVER_THRESHOLD_CENTS = 3_000_000  # payable above this needs the approver role
# Days from submission to the assessment, per product (inclusive range). Hand-chosen to rank the lines the way public
# benchmarks do (health fastest, liability slowest); still much faster than real life: no investigation or negotiation.
ASSESS_DAYS = {"AUTO": (2, 10), "HOME": (5, 20), "HLTH": (1, 5), "TRVL": (2, 10), "LIAB": (7, 25)}
APPROVAL_DAYS = {
    "process_owner": (1, 3),
    "approver": (3, 7),
}  # assessment -> approval; the approver is slower
DOC_WINDOW_DAYS = 5  # R-DOC-01: a document counts only if received_date <= submission_date + this
FRAUD_F1_DAYS = 30  # F1: submission within this many days after policy start (inclusive)
FRAUD_F2_DAYS = 90  # F2: window for earlier claims by the same customer (inclusive)
FRAUD_F2_MIN = 3  # F2 fires with at least this many EARLIER claims in the window
FRAUD_F4_DAYS = 60  # F4: reported more than this many days after the incident
FRAUD_THRESHOLD = 0.5  # fraud_score = flags / 4; at or above this the claim goes to review


# Supported scales. Below MIN_SCALE the pools of single-claim policies that injection needs are too thin: measured at
# T9, 0.051, 0.055 and 0.07 fail with "not enough injection targets" and everything below 0.05 does too, while every
# tested value from 0.071 up to 3.0 builds with all scenarios present. The starter (0.05) builds and is allowed by name.
STARTER_SCALE = 0.05
MIN_SCALE = 0.075
MAX_SCALE = 5.0


def scale_message() -> str:
    return f"scale must be {STARTER_SCALE} (the starter) or between {MIN_SCALE} and {MAX_SCALE}"


def check_scale(scale: float) -> float:
    """Return scale if it can be built, else raise ValueError with the supported range."""
    ok = math.isfinite(scale) and (scale == STARTER_SCALE or MIN_SCALE <= scale <= MAX_SCALE)
    if not ok:
        raise ValueError(f"{scale_message()} (got {scale})")
    return scale


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
    "not_covered": 0.01,
}


def scenario_counts(n_claims: int) -> dict[str, int]:
    return {k: max(1, round(r * n_claims)) for k, r in SCENARIO_RATES.items()}


def inject_rows(scale: float) -> int:
    """Rows per injected edge case (10-30 at full scale); injected duplicates are carved out of the claim total."""
    return max(2, round(15 * scale))


def intake_horizon() -> date:
    """Last date a what-if evaluation may reach (the dataset itself still ends at AS_OF)."""
    return AS_OF + timedelta(days=INTAKE_HORIZON_DAYS)
