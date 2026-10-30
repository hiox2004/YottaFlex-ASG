"""Validation runner and report. Baseline must show zero failures; after injection the set of failing ids must equal
the integrity-defect ids in ground_truth."""

from claimsgen.checks_business import business_checks
from claimsgen.checks_structure import Check, structure_checks

BLOCKING = {
    "primary key uniqueness",
    "foreign key integrity",
    "required fields present",
    "enum values",
}


def run_all(tables: dict) -> list[Check]:
    """Business checks assume well-formed rows, so they are skipped (and reported) if keys, joins or required fields fail."""
    checks = structure_checks(tables)
    if all(c.ok for c in checks if c.name in BLOCKING):
        return checks + business_checks(tables)
    skipped = Check("lifecycle", "business checks (skipped: structural errors)")
    skipped.fail("business-checks-skipped", "fix keys, joins and required fields first")
    return [*checks, skipped]


def failing_ids(checks: list[Check]) -> set:
    return set().union(*(c.ids for c in checks))


def summary(checks: list[Check]) -> dict:
    return {
        "checks": len(checks),
        "passed": sum(c.ok for c in checks),
        "failed": sum(not c.ok for c in checks),
        "rows_checked": sum(c.checked for c in checks),
        "failing_ids": len(failing_ids(checks)),
    }


def to_markdown(checks: list[Check], row_counts: dict) -> str:
    s = summary(checks)
    out = [
        "# Validation report",
        "",
        f"Checks: {s['checks']} | passed: {s['passed']} | failed: {s['failed']} | failing ids: {s['failing_ids']}",
        "",
        "| Category | Check | Rows checked | Failures | Result |",
        "|---|---|---|---|---|",
    ]
    for c in checks:
        out.append(
            f"| {c.category} | {c.name} | {c.checked} | {len(c.failures)} | {'PASS' if c.ok else 'FAIL'} |"
        )
    out += ["", "## Row counts", "", "| Table | Rows |", "|---|---|"]
    out += [f"| {name} | {n} |" for name, n in row_counts.items()]
    for c in checks:
        if c.failures:
            out += ["", f"### Failures: {c.name}", ""]
            out += [f"- `{i}` {why}" for i, why in c.failures[:25]]
    return "\n".join(out) + "\n"
