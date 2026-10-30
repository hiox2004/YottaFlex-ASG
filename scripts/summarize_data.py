"""Compact summary of generated CSVs (row count, header, 3 sample rows) so raw files never need reading.

Usage: python scripts/summarize_data.py [output_dir]
"""

import csv
import sys
from pathlib import Path


def main() -> int:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("output/starter")
    files = sorted(root.rglob("*.csv"))
    if not files:
        print(f"no CSV files under {root}")
        return 0
    for f in files:
        with f.open(newline="", encoding="utf-8") as fh:
            rows = list(csv.reader(fh))
        header, body = (rows[0], rows[1:]) if rows else ([], [])
        print(f"{f.name}: {len(body)} rows | columns: {', '.join(header)}")
        for r in body[:3]:
            print("   ", r)
    return 0


if __name__ == "__main__":
    sys.exit(main())
