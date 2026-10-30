"""Reproducibility proof: build the dataset twice with the fixed seed into separate folders and compare every file
(row counts and SHA-256), then report. Exit 1 on any mismatch or unexpected validation result.

Usage: python scripts/verify.py [scale]   (default 0.05, the starter; use 1.0 for the full dataset)
"""

import hashlib
import sys
import tempfile
from pathlib import Path

from claimsgen import SEED, generate


def digest(out: Path) -> dict:
    result = {}
    for f in sorted(
        (p for p in out.rglob("*") if p.is_file()), key=lambda p: p.relative_to(out).as_posix()
    ):
        data = f.read_bytes()
        result[f.relative_to(out).as_posix()] = (
            data.count(b"\n"),
            hashlib.sha256(data).hexdigest(),
        )
    return result


def main() -> int:
    scale = float(sys.argv[1]) if len(sys.argv) > 1 else 0.05
    with tempfile.TemporaryDirectory() as a, tempfile.TemporaryDirectory() as b:
        first = generate.build(Path(a), seed=SEED, scale=scale)
        second = generate.build(Path(b), seed=SEED, scale=scale)
        d1, d2 = digest(Path(a)), digest(Path(b))
    same = d1 == d2
    print(
        f"seed {SEED} scale {scale} | files: {len(d1)} | run1==run2 (every file, rows + SHA-256): {same}"
    )
    for name, (rows, sha) in d1.items():
        print(
            f"  {name}: lines={rows} sha256={sha[:12]} {'OK' if d2.get(name) == (rows, sha) else 'DIFFERENT'}"
        )
    print(f"validation flags exactly the planted defects: {first['ok'] and second['ok']}")
    return 0 if same and first["ok"] and second["ok"] else 1


if __name__ == "__main__":
    sys.exit(main())
