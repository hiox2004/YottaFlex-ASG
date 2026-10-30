"""Render the data dictionary and SQL schema from schema.TABLES. Run: python -m claimsgen.schema_docs"""

import sys
from pathlib import Path

from claimsgen.schema import _SQL_TYPE, TABLE_BY_NAME, TABLES


def render_dictionary_md() -> str:
    out = [
        "# Data dictionary",
        "",
        "Generated from `src/claimsgen/schema.py`; do not edit by hand.",
        "Dates are ISO `YYYY-MM-DD`; money is USD with 2 decimals.",
        "",
    ]
    for t in TABLES:
        out += [
            f"## {t.name}",
            f"{t.description}. PK `{t.pk}` pattern `{t.pk_pattern}`.",
            "",
            "| Field | Type | Required | Allowed values | Unit | Unique | FK | Validation rule |",
            "|---|---|---|---|---|---|---|---|",
        ]
        for f in t.fields:
            allowed = f.allowed.replace("|", "\\|")
            out.append(
                f"| {f.name} | {f.type} | {'Y' if f.required else 'N'} | {allowed} | {f.unit} "
                f"| {'Y' if f.unique else 'N'} | {f.fk} | {f.rule} |"
            )
        out.append("")
    return "\n".join(out)


def render_ddl(names: set | None = None) -> str:
    out = ["-- Generated from src/claimsgen/schema.py; do not edit by hand."]
    for t in (t for t in TABLES if names is None or t.name in names):
        cols = [
            f"  {f.name} {_SQL_TYPE[f.type]}{' NOT NULL' if f.required else ''}" for f in t.fields
        ]
        if t.name != "ground_truth":
            cols.append(f"  PRIMARY KEY ({t.pk})")
        cols += [
            f"  FOREIGN KEY ({f.name}) REFERENCES {f.fk}({TABLE_BY_NAME[f.fk].pk})"
            for f in t.fields
            if f.fk
        ]
        out.append(f"CREATE TABLE {t.name} (\n" + ",\n".join(cols) + "\n);")
    return "\n".join(out) + "\n"


def main() -> int:
    docs = Path(__file__).resolve().parents[2] / "docs"
    (docs / "DATA_DICTIONARY.md").write_text(render_dictionary_md(), encoding="utf-8", newline="\n")
    (docs / "schema.sql").write_text(render_ddl(), encoding="utf-8", newline="\n")
    print(f"wrote {len(TABLES)} tables to docs/DATA_DICTIONARY.md and docs/schema.sql")
    return 0


if __name__ == "__main__":
    sys.exit(main())
