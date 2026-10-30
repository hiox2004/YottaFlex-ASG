"""PostToolUse hook: format + lint the edited .py file, then run tests. Quiet unless something fails."""

import json
import subprocess
import sys


def run(cmd: list[str]) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, check=False, capture_output=True, text=True)


def main() -> int:
    try:
        path = json.load(sys.stdin).get("tool_input", {}).get("file_path", "")
    except (ValueError, AttributeError):
        return 0
    if not path.endswith(".py"):
        return 0
    run([sys.executable, "-m", "ruff", "format", path])
    lint = run([sys.executable, "-m", "ruff", "check", "--fix", path])
    tests = run([sys.executable, "-m", "pytest", "-q", "-x", "--tb=line"])
    problems = [r.stdout[-600:] for r in (lint, tests) if r.returncode not in (0, 5)]
    if problems:
        print("\n".join(problems), file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
