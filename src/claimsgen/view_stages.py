"""Five-stage strip and headline numbers for the view. Pure functions, no Streamlit.

Stages are derived only from a what-if result's rule_trace and decision; the headline reuses metrics and view_data.
"""

from claimsgen import SEED, metrics, view_data
from claimsgen.view_trace import PASSED, STOPPED

PASS, STOP, NOT_REACHED = "passed", "stopped", "not reached"
STAGE_RULES = (
    ("Intake", ()),
    ("Coverage", ("R-COV-",)),
    ("Documents", ("R-DOC-01",)),
    ("Eligibility", ("R-ELG-", "R-FRD-")),
    ("Routing", ("R-PAY-01", "R-RSV-", "R-APR-01")),
)


def stages(result: dict) -> list[dict]:
    """One dict per stage: stage, status (passed / stopped / not reached), rule_id and note of the stopping step."""
    out = [{"stage": "Intake", "status": PASS, "rule_id": "", "note": ""}]
    for name, prefixes in STAGE_RULES[1:]:
        steps = [s for s in result["rule_trace"] if s["rule_id"].startswith(prefixes)]
        stop = next((s for s in steps if s["outcome"] == STOPPED), None)
        if stop:
            row = (STOP, stop["rule_id"], stop["reason_code"])
        elif steps and all(s["outcome"] == PASSED for s in steps):
            row = (PASS, "", "")
        else:
            row = (NOT_REACHED, "", "")
        out.append({"stage": name, "status": row[0], "rule_id": row[1], "note": row[2]})
    return out


def headline(tables: dict, checks: list, checksum: str) -> dict:
    """Four first-screen numbers, from the same functions the Metrics and Exceptions tabs use."""
    through = metrics.operational(tables)["straight_through"]
    return {
        "claims": len(tables["claim"]),
        "straight_through_rate": through["straight_through_rate"],
        "straight_through": through["straight_through"],
        "assessed": through["assessed"],
        "open_exceptions": sum(len(v) for v in view_data.exceptions(tables, checks).values()),
        "seed": SEED,
        "checksum_present": bool(checksum),
    }
