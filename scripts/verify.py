"""Reproducibility proof: build twice with the fixed seed, compare row counts + SHA-256, then validate.

Stub until the generator exists (src/claimsgen/generate.py with build(out_dir, seed, scale)).
"""

import hashlib
import importlib
import sys
import tempfile
from pathlib import Path

SEED = 20261022


def digest(out: Path) -> dict[str, tuple[int, str]]:
    result = {}
    for f in sorted(out.rglob("*")):
        if f.is_file():
            data = f.read_bytes()
            result[f.relative_to(out).as_posix()] = (
                data.count(b"\n"),
                hashlib.sha256(data).hexdigest(),
            )
    return result


def main() -> int:
    try:
        gen = importlib.import_module("claimsgen.generate")
    except ModuleNotFoundError:
        print("verify: generator not built yet (claimsgen.generate missing); nothing to check")
        return 0
    with tempfile.TemporaryDirectory() as a, tempfile.TemporaryDirectory() as b:
        gen.build(Path(a), seed=SEED, scale=1.0)
        gen.build(Path(b), seed=SEED, scale=1.0)
        first, second = digest(Path(a)), digest(Path(b))
    same = first == second
    print(f"files: {len(first)} | run1==run2 (row counts + SHA-256): {same}")
    for name, (rows, sha) in first.items():
        print(f"  {name}: rows={rows} sha256={sha[:12]}")
    return 0 if same else 1


if __name__ == "__main__":
    sys.exit(main())
