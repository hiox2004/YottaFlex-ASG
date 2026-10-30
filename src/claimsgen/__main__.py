"""Command line: `python -m claimsgen build --scale 1.0 --out DIR` or `python -m claimsgen all --out output`."""

import argparse
import sys
from pathlib import Path

from claimsgen import SEED, generate

STARTER_SCALE = 0.05


def _run(out: Path, seed: int, scale: float) -> bool:
    result = generate.build(out, seed=seed, scale=scale)
    s = result["summary"]
    print(
        f"{out}: scale {scale} | {result['files']} data files | checks {s['passed']}/{s['checks']} passed "
        f"(failing ids {s['failing_ids']} = planted defects) | same-seed rerun identical: {result['identical']}"
    )
    return result["ok"]


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(
        prog="claimsgen", description="Deterministic synthetic claims dataset generator"
    )
    sub = parser.add_subparsers(dest="cmd", required=True)
    build = sub.add_parser("build", help="build one dataset")
    build.add_argument(
        "--scale", type=float, default=1.0, help="1.0 = 2,000 policies / 1,000 claims"
    )
    build.add_argument("--out", required=True)
    build.add_argument("--seed", type=int, default=SEED)
    every = sub.add_parser(
        "all", help="build the starter (scale 0.05) and full (scale 1.0) datasets"
    )
    every.add_argument("--out", default="output")
    args = parser.parse_args(argv)
    if args.cmd == "build":
        return 0 if _run(Path(args.out), args.seed, args.scale) else 1
    ok = _run(Path(args.out) / "starter", SEED, STARTER_SCALE)
    ok = _run(Path(args.out) / "full", SEED, 1.0) and ok
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
