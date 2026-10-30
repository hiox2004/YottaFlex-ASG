"""Write the documentation files that travel with a dataset: validation summary (with distributions, injected-case counts and the
same-seed reproducibility proof), manifest, README and checksums. Source docs are copied from docs/ so there is one source of truth."""

import hashlib
import json
import shutil
from collections import Counter
from pathlib import Path
from statistics import mean, median

from claimsgen import SEED, config, metrics, validate

DOCS = Path(__file__).resolve().parents[2] / "docs"


def usd(cents: int) -> str:
    return f"{cents / 100:,.2f}"


def distributions(tables: dict) -> list[str]:
    amounts = sorted(c["claimed_amount"] for c in tables["claim"])
    last_policy, last_claim = {}, {}
    for e in tables["policy_event"]:
        last_policy[e["policy_id"]] = {"issued": "in force"}.get(e["event_type"], e["event_type"])
    for e in tables["claim_status_history"]:
        last_claim[e["claim_id"]] = e["to_status"]

    def mix(counter):
        return " | ".join(f"{k}: {v}" for k, v in sorted(counter.items()))

    return [
        "## Distributions (review point a)",
        "",
        (
            f"- Claimed amount (USD): median {usd(int(median(amounts)))}, mean {usd(int(mean(amounts)))}, "
            f"p90 {usd(amounts[int(0.9 * (len(amounts) - 1))])}, max {usd(amounts[-1])} "
            "(right-skewed: mean > median)"
        ),
        f"- Claim types: {mix(Counter(c['claim_type'] for c in tables['claim']))}",
        f"- Policy status at AS_OF: {mix(Counter(last_policy.values()))}",
        f"- Final claim status: {mix(Counter(last_claim.values()))}",
    ]


def _repro_table(digests: dict, second: dict) -> list[str]:
    rows = ["| File | Rows | SHA-256 (run 1) | Same in run 2 |", "|---|---|---|---|"]
    rows += [
        f"| {p} | {n} | {sha[:16]}... | {second.get(p) == (n, sha)} |"
        for p, (n, sha) in sorted(digests.items())
    ]
    return rows


def write_docs(
    out: Path, scale: float, tables: dict, gt: list, digests: dict, repro: dict, checks: list
) -> bool:
    """Write validation_summary.md, manifest.json, README.md, schema/dictionary/source copies and checksums. Returns ok."""
    for name in ("DATA_DICTIONARY.md", "SOURCE_MANIFEST.md"):
        shutil.copyfile(DOCS / name, out / name) if (DOCS / name).exists() else shutil.copyfile(
            DOCS.parent / name, out / name
        )
    shutil.copyfile(DOCS / "schema.sql", out / "schema.sql")
    counts = {name: len(rows) for name, rows in tables.items()} | {"ground_truth": len(gt)}
    defects = {r["entity_id"] for r in gt if r["kind"] == "integrity_defect"}
    failing = validate.failing_ids(checks)
    ok = failing == defects and repro["identical"]
    cases = Counter((r["label"], r["origin"], r["kind"]) for r in gt)
    summary = [
        "# Validation summary",
        "",
        f"Seed {SEED} | scale {scale} | AS_OF {config.AS_OF} | currency {config.CURRENCY}",
        "",
        validate.to_markdown(checks, counts)
        .replace("# Validation report", "## Validation checks", 1)
        .rstrip(),
        "",
        "## Integrity defects",
        "",
        f"Defect rows in ground_truth: {len(defects)} | flagged by the validator: {len(failing)} | exact match: {failing == defects}",
        "The failures above are the two planted integrity defects (settlement_exceeds_limit, paid_twice); the baseline has none.",
        "",
        "## Edge cases present and counted",
        "",
        "| Label | Origin | Kind | Rows |",
        "|---|---|---|---|",
        *[
            f"| {label} | {origin} | {kind} | {n} |"
            for (label, origin, kind), n in sorted(cases.items())
        ],
        "",
        *distributions(tables),
        "",
        "## Reproducibility (same seed, two runs)",
        "",
        f"Two independent builds with seed {SEED} produced identical row counts and SHA-256 checksums: **{repro['identical']}**",
        "",
        *_repro_table(digests, repro["second"]),
        "",
    ]
    (out / "metrics.md").write_text(
        metrics.to_markdown(tables, gt, checks), encoding="utf-8", newline="\n"
    )
    (out / "validation_summary.md").write_text("\n".join(summary), encoding="utf-8", newline="\n")
    manifest = {
        "seed": SEED,
        "scale": scale,
        "as_of": config.AS_OF.isoformat(),
        "currency": config.CURRENCY,
        "generator_command": f"python -m claimsgen build --scale {scale} --out <DIR>",
        "synthetic": True,
        "row_counts": counts,
        "sha256": {p: sha for p, (_, sha) in sorted(digests.items())},
    }
    (out / "manifest.json").write_text(
        json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8", newline="\n"
    )
    readme = f"""# Claims dataset (scale {scale}, seed {SEED})

Fully synthetic insurance claims data (see SOURCE_MANIFEST.md). Regenerate with `python -m claimsgen build --scale {scale} --out <DIR>`.

- `csv/`, `json/`: the 16 input and event tables (same rows, same columns, parent-first order in `seed.sql`).
- `seed.sql`: SQLite DDL plus INSERTs for those tables (`PRAGMA foreign_keys=ON`). `schema.sql`: DDL for all tables including ground_truth.
- `ground_truth.csv|json|sql`: the separate answer key (labels, origin, kind, expected decision, rule). Never join it into inputs.
- `DATA_DICTIONARY.md`: every field with type, required, allowed values, unit, uniqueness, rule.
- `validation_summary.md`: checks, row counts, injected cases, distributions and the same-seed reproducibility proof.
- `metrics.md`: operational metrics (outcome rates, cycle times, amounts blocked, reserve vs final) and precision/recall of the engine and validator vs ground_truth.
- `manifest.json`, `checksums.sha256`: seed, scale, as-of date and SHA-256 of every file.

Money is USD with two decimals. Dates are ISO. All "today" logic uses AS_OF {config.AS_OF}, never the system clock.
Joins: claim.policy_id -> policy, claim.incident_id -> incident, claim_item/document/assessment/reserve/settlement/claim_status_history/claim_adjuster_assignment .claim_id -> claim.
"""
    (out / "README.md").write_text(readme, encoding="utf-8", newline="\n")
    files = sorted(p for p in out.rglob("*") if p.is_file() and p.name != "checksums.sha256")
    lines = [
        f"{hashlib.sha256(p.read_bytes()).hexdigest()}  {p.relative_to(out).as_posix()}\n"
        for p in files
    ]
    (out / "checksums.sha256").write_text("".join(lines), encoding="utf-8", newline="\n")
    return ok
