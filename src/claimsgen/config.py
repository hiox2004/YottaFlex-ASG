"""Run-wide constants and the seeded RNG factory. AS_OF replaces the system clock everywhere."""

from dataclasses import dataclass
from datetime import date
from random import Random

from claimsgen import SEED

AS_OF = date(2026, 10, 22)
CURRENCY = "USD"
APPROVER_THRESHOLD_CENTS = 1_000_000  # payable above this needs the approver role


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
        adjusters=max(5, round(30 * scale)),
    )


def rng(stream: str) -> Random:
    """Independent, reproducible RNG per named stream, e.g. rng('policies')."""
    return Random(f"{SEED}:{stream}")
