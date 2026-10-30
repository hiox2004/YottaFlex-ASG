"""Serialise the dataset to CSV, JSON and SQL with byte-stable formatting.

Rules that keep two same-seed runs byte-identical: rows keep dataset order (never re-sorted by key), columns follow the schema,
money is exact 2-decimal text from integer cents, ratios are fixed 2-decimal text, dates are ISO, LF line endings, UTF-8.
ground_truth is written to its own top-level files and never mixed into the input tables.
"""

import csv
import hashlib
import json
from datetime import date
from pathlib import Path

from claimsgen import schema, schema_docs

INPUT_TABLES = [t for t in schema.TABLES if t.name != "ground_truth"]


def text(field: schema.Field, value):
    """Canonical text for a value (None stays None)."""
    if value is None:
        return None
    if field.type == "money":
        return f"{value // 100}.{value % 100:02d}"
    if field.type == "ratio":
        return f"{value:.2f}"
    if isinstance(value, date):
        return value.isoformat()
    return str(value)


def _json_value(field: schema.Field, value):
    if field.type == "int" and value is not None:
        return int(value)
    return text(field, value)


def _sql_value(field: schema.Field, value) -> str:
    t = text(field, value)
    if t is None:
        return "NULL"
    if field.type in ("money", "ratio", "int"):
        return t
    return "'" + t.replace("'", "''") + "'"


def _write(path: Path, content: str) -> str:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(content.encode("utf-8"))
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _csv(table: schema.Table, rows: list) -> str:
    import io

    buf = io.StringIO()
    writer = csv.writer(buf, lineterminator="\n")
    writer.writerow(f.name for f in table.fields)
    for r in rows:
        writer.writerow("" if (v := text(f, r[f.name])) is None else v for f in table.fields)
    return buf.getvalue()


def _json(table: schema.Table, rows: list) -> str:
    objects = [{f.name: _json_value(f, r[f.name]) for f in table.fields} for r in rows]
    body = ",\n".join(json.dumps(o, separators=(",", ":"), ensure_ascii=False) for o in objects)
    return "[\n" + body + "\n]\n" if objects else "[]\n"


def _inserts(table: schema.Table, rows: list) -> str:
    cols = ", ".join(f.name for f in table.fields)
    return "".join(
        f"INSERT INTO {table.name} ({cols}) VALUES ({', '.join(_sql_value(f, r[f.name]) for f in table.fields)});\n"
        for r in rows
    )


def write_tables(out: Path, tables: dict, ground_truth: list) -> dict:
    """Write csv/, json/, seed.sql and the ground_truth files. Returns {relative path: (rows, sha256)}."""
    digests = {}
    names = {t.name for t in INPUT_TABLES}
    for t in INPUT_TABLES:
        rows = tables[t.name]
        digests[f"csv/{t.name}.csv"] = (
            len(rows),
            _write(out / "csv" / f"{t.name}.csv", _csv(t, rows)),
        )
        digests[f"json/{t.name}.json"] = (
            len(rows),
            _write(out / "json" / f"{t.name}.json", _json(t, rows)),
        )
    seed = [
        "-- Seed data (SQLite). Tables are in parent-first order; load with PRAGMA foreign_keys=ON.\n"
    ]
    seed.append(schema_docs.render_ddl(names))
    seed.append(
        "BEGIN;\n" + "".join(_inserts(t, tables[t.name]) for t in INPUT_TABLES) + "COMMIT;\n"
    )
    total = sum(len(tables[t.name]) for t in INPUT_TABLES)
    digests["seed.sql"] = (total, _write(out / "seed.sql", "".join(seed)))
    gt = schema.TABLE_BY_NAME["ground_truth"]
    digests["ground_truth.csv"] = (
        len(ground_truth),
        _write(out / "ground_truth.csv", _csv(gt, ground_truth)),
    )
    digests["ground_truth.json"] = (
        len(ground_truth),
        _write(out / "ground_truth.json", _json(gt, ground_truth)),
    )
    sql = (
        "-- Answer key. Separate from the input tables; never join it into model or rule inputs.\n"
    )
    sql += (
        schema_docs.render_ddl({"ground_truth"})
        + "BEGIN;\n"
        + _inserts(gt, ground_truth)
        + "COMMIT;\n"
    )
    digests["ground_truth.sql"] = (len(ground_truth), _write(out / "ground_truth.sql", sql))
    return digests
