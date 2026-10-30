"""One call builds the whole dataset: master data -> policies -> claims -> baseline -> injection -> final IDs -> ground truth."""

from claimsgen import claims, ground_truth, inject, masterdata, policies
from claimsgen.finalize import finalize


def build_dataset(scale: float = 1.0) -> tuple[dict, list]:
    """Return (input and event tables, ground_truth rows). ground_truth is never joined into the tables."""
    master = masterdata.generate(scale)
    pol = policies.generate(master, scale)
    claim_tables, planted = claims.generate(master, pol, scale)
    tables, injected = inject.inject(master, pol, claim_tables, planted, scale)
    tables, idmap = finalize(tables)
    return tables, ground_truth.build(planted, injected, idmap)
