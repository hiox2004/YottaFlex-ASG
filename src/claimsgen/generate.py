"""One call builds the whole dataset: master data -> policies -> claims -> baseline -> injection -> final IDs -> ground truth,
and `build` exports it with the validation summary and a same-seed reproducibility proof."""

import tempfile
from pathlib import Path

from claimsgen import (
    SEED,
    claims,
    config,
    dataset_docs,
    export,
    ground_truth,
    inject,
    masterdata,
    policies,
    validate,
)
from claimsgen.finalize import finalize


def build_dataset(scale: float = 1.0) -> tuple[dict, list]:
    """Return (input and event tables, ground_truth rows). ground_truth is never joined into the tables."""
    config.check_scale(scale)
    master = masterdata.generate(scale)
    pol = policies.generate(master, scale)
    claim_tables, planted = claims.generate(master, pol, scale)
    tables, injected = inject.inject(master, pol, claim_tables, planted, scale)
    tables, idmap = finalize(tables)
    return tables, ground_truth.build(planted, injected, idmap)


def build(out_dir, seed: int = SEED, scale: float = 1.0) -> dict:
    """Write the full dataset package to out_dir. Builds a second time in a temp dir and compares row counts and SHA-256.

    Returns {"ok": bool, ...}; ok is False if validation does not flag exactly the integrity defects or the two runs differ.
    """
    if seed != SEED:
        raise ValueError(f"the seed is fixed at {SEED} by the brief (got {seed})")
    out = Path(out_dir)
    tables, gt = build_dataset(scale)
    digests = export.write_tables(out, tables, gt)
    with tempfile.TemporaryDirectory() as tmp:
        tables2, gt2 = build_dataset(scale)
        second = export.write_tables(Path(tmp), tables2, gt2)
    checks = validate.run_all(tables)
    repro = {"identical": digests == second, "second": second}
    ok = dataset_docs.write_docs(out, scale, tables, gt, digests, repro, checks)
    return {
        "ok": ok,
        "identical": repro["identical"],
        "files": len(digests),
        "summary": validate.summary(checks),
    }
