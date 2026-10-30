from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_every_module_has_a_study_note():
    missing = [
        p.name
        for p in sorted((ROOT / "src" / "claimsgen").glob("*.py"))
        if p.name != "__init__.py" and not (ROOT / "docs/study/modules" / f"{p.stem}.md").exists()
    ]
    assert not missing, (
        f"add docs/study/modules/<name>.md (copy docs/study/TEMPLATE.md) for: {missing}"
    )
