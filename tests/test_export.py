import csv
import hashlib
import json
import re
import sqlite3
from pathlib import Path

import pytest

from claimsgen import generate
from claimsgen.__main__ import main
from claimsgen.schema import TABLE_BY_NAME, TABLES

INPUTS = [t for t in TABLES if t.name != "ground_truth"]
TOP_FILES = {
    "DATA_DICTIONARY.md",
    "README.md",
    "SOURCE_MANIFEST.md",
    "checksums.sha256",
    "ground_truth.csv",
    "ground_truth.json",
    "ground_truth.sql",
    "manifest.json",
    "metrics.md",
    "schema.sql",
    "seed.sql",
    "validation_summary.md",
}


@pytest.fixture(scope="module")
def starter(tmp_path_factory):
    out = tmp_path_factory.mktemp("starter")
    result = generate.build(out, scale=0.05)
    tables, gt = generate.build_dataset(0.05)
    return out, result, tables, gt


def _rows(path):
    with path.open(newline="", encoding="utf-8") as fh:
        return list(csv.reader(fh))


def test_package_layout_and_result(starter):
    out, result, *_ = starter
    assert result["ok"] and result["identical"]
    found = {p.name for p in out.iterdir() if p.is_file()}
    assert TOP_FILES <= found
    assert {p.stem for p in (out / "csv").iterdir()} == {t.name for t in INPUTS}
    assert {p.stem for p in (out / "json").iterdir()} == {t.name for t in INPUTS}
    assert not (out / "csv" / "ground_truth.csv").exists()


def test_csv_and_json_match_the_dataset_in_order(starter):
    out, _, tables, _ = starter
    for t in INPUTS:
        rows = _rows(out / "csv" / f"{t.name}.csv")
        assert rows[0] == [f.name for f in t.fields]
        assert len(rows) - 1 == len(tables[t.name])
        assert [r[0] for r in rows[1:]] == [str(r[t.fields[0].name]) for r in tables[t.name]]
        objects = json.loads((out / "json" / f"{t.name}.json").read_text(encoding="utf-8"))
        assert [o[t.fields[0].name] for o in objects] == [r[0] for r in rows[1:]]


def test_money_and_ratio_are_exact_decimal_text(starter):
    out, *_ = starter
    for t in INPUTS:
        money = [i for i, f in enumerate(t.fields) if f.type == "money"]
        ratio = [i for i, f in enumerate(t.fields) if f.type == "ratio"]
        for row in _rows(out / "csv" / f"{t.name}.csv")[1:]:
            assert all(re.fullmatch(r"\d+\.\d{2}", row[i]) for i in money if row[i] != "")
            assert all(re.fullmatch(r"\d\.\d{2}", row[i]) for i in ratio)


def test_sql_seed_loads_with_foreign_keys_and_matches_row_counts(starter):
    out, _, tables, gt = starter
    db = sqlite3.connect(":memory:")
    db.execute("PRAGMA foreign_keys=ON")
    db.executescript((out / "seed.sql").read_text(encoding="utf-8"))
    for t in INPUTS:
        assert db.execute(f"SELECT COUNT(*) FROM {t.name}").fetchone()[0] == len(tables[t.name])
    assert db.execute("PRAGMA foreign_key_check").fetchall() == []
    names = {r[0] for r in db.execute("SELECT name FROM sqlite_master WHERE type='table'")}
    assert "ground_truth" not in names
    truth = sqlite3.connect(":memory:")
    truth.executescript((out / "ground_truth.sql").read_text(encoding="utf-8"))
    assert truth.execute("SELECT COUNT(*) FROM ground_truth").fetchone()[0] == len(gt)


def test_inputs_never_contain_label_columns(starter):
    out, *_ = starter
    leak = {f.name for f in TABLE_BY_NAME["ground_truth"].fields} - {"entity_id", "rule_id"}
    for t in INPUTS:
        assert not leak & set(_rows(out / "csv" / f"{t.name}.csv")[0]), t.name
    assert (_rows(out / "ground_truth.csv"))[0] == [
        f.name for f in TABLE_BY_NAME["ground_truth"].fields
    ]


def test_checksums_manifest_and_summary(starter):
    out, _, tables, _ = starter
    for line in (out / "checksums.sha256").read_text(encoding="utf-8").splitlines():
        sha, rel = line.split("  ", 1)
        assert hashlib.sha256((out / rel).read_bytes()).hexdigest() == sha, rel
    manifest = json.loads((out / "manifest.json").read_text(encoding="utf-8"))
    assert (manifest["seed"], manifest["scale"], manifest["synthetic"]) == (20261022, 0.05, True)
    assert manifest["row_counts"]["claim"] == len(tables["claim"])
    summary = (out / "validation_summary.md").read_text(encoding="utf-8")
    assert (
        "exact match: True" in summary
        and "identical row counts and SHA-256 checksums: **True**" in summary
    )
    for heading in ("Distributions", "Edge cases present and counted", "Row counts"):
        assert heading in summary


def test_two_builds_are_byte_identical(tmp_path):
    a, b = tmp_path / "a", tmp_path / "b"
    generate.build(a, scale=0.05)
    generate.build(b, scale=0.05)
    files_a = sorted(p.relative_to(a).as_posix() for p in a.rglob("*") if p.is_file())
    assert files_a == sorted(p.relative_to(b).as_posix() for p in b.rglob("*") if p.is_file())
    assert all((a / f).read_bytes() == (b / f).read_bytes() for f in files_a)


def test_cli_and_fixed_seed(tmp_path):
    assert main(["build", "--scale", "0.05", "--out", str(tmp_path / "cli")]) == 0
    assert (tmp_path / "cli" / "seed.sql").exists()
    with pytest.raises(ValueError, match="fixed"):
        generate.build(tmp_path / "bad", seed=1, scale=0.05)


def test_full_scale_row_counts(tmp_path):
    assert generate.build(tmp_path, scale=1.0)["ok"]
    assert len(_rows(tmp_path / "csv" / "policy.csv")) - 1 == 2000
    assert len(_rows(tmp_path / "csv" / "claim.csv")) - 1 == 1000
    summary = (tmp_path / "validation_summary.md").read_text(encoding="utf-8")
    assert "| policy | 2000 |" in summary and "| claim | 1000 |" in summary
    assert Path(tmp_path / "ground_truth.csv").exists()
