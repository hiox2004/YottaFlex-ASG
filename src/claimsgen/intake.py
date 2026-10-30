"""Intake: turn one raw claim submission (a dict or JSON text) into a Draft, or into a list of field errors.

Validation checks structure and format only. Business outcomes (coverage not effective, incident before the
policy start or after a lapse, excluded item, over the limit, within the deductible) are VALID inputs here:
the rules engine decides them. Every problem is collected, not just the first.
An error looks like {"field": "items[0].amount", "message": "must be greater than 0"}.
"""

import json
from datetime import date
from decimal import Decimal, InvalidOperation

from claimsgen import config, masterdata, vocab
from claimsgen.draft import Doc, Draft, Item

REQUIRED = ("policy_id", "incident_date", "incident_type", "submission_date", "items")
OPTIONAL = ("documents",)
ITEM_FIELDS = ("coverage_id", "item_type", "amount")
DOC_REQUIRED = ("doc_type", "received_date")
DOC_OPTIONAL = ("status",)
DOC_STATUSES = ("received", "rejected")
MAX_ITEMS = 20
MAX_DOCS = 20
MAX_AMOUNT = Decimal(10000000)  # USD, per item
CENT = Decimal("0.01")


def parse_and_validate(raw, tables: dict) -> tuple[Draft | None, list[dict]]:
    """Return (draft, []) for a structurally valid submission, else (None, every error found)."""
    data, errors = _load(raw)
    if data is None:
        return None, errors
    _check_keys(data, REQUIRED, OPTIONAL, "", errors)
    submission = _date_field(
        data, "submission_date", "submission_date", errors, hi=config.intake_horizon()
    )
    incident = _date_field(data, "incident_date", "incident_date", errors, hi=submission)
    policy = _check_policy(tables, data, errors)
    if policy is not None and "incident_type" in data:
        _check_incident_type(data["incident_type"], policy["product"], tables, errors)
    coverages = policy_coverages(tables, policy["policy_id"]) if policy is not None else None
    items = _check_items(data["items"], coverages, errors) if "items" in data else ()
    docs = _check_docs(data["documents"], submission, errors) if "documents" in data else ()
    if errors:
        return None, errors
    draft = Draft(data["policy_id"], incident, data["incident_type"], submission, items, docs)
    return draft, []


def _err(errors: list[dict], field: str, message: str) -> None:
    errors.append({"field": field, "message": message})


def _load(raw) -> tuple[dict | None, list[dict]]:
    errors: list[dict] = []
    if isinstance(raw, str):
        try:
            raw = json.loads(raw)
        except json.JSONDecodeError as exc:
            _err(errors, "$", f"invalid JSON: {exc.msg} at position {exc.pos}")
            return None, errors
    if not isinstance(raw, dict):
        _err(errors, "$", "must be a JSON object")
        return None, errors
    return raw, errors


def _check_keys(obj: dict, required, optional, prefix: str, errors: list[dict]) -> None:
    for key in required:
        if key not in obj:
            _err(errors, prefix + key, "is required")
    for key in obj:
        if key in required or key in optional:
            continue
        if key == "claim_type":
            _err(errors, prefix + key, "claim_type is derived from the policy and must be removed")
        else:
            _err(errors, prefix + key, "is not a known field")


def _parse_date(value) -> date | None:
    if isinstance(value, date):
        return value
    if isinstance(value, str):
        try:
            return date.fromisoformat(value)
        except ValueError:
            return None
    return None


def _date_field(
    obj: dict,
    key: str,
    field: str,
    errors: list[dict],
    lo: date | None = None,
    hi: date | None = None,
) -> date | None:
    """Parse obj[key] as an ISO date and check its bounds. Absent keys are reported by _check_keys."""
    if key not in obj:
        return None
    value = _parse_date(obj[key])
    if value is None:
        _err(errors, field, "must be an ISO date (YYYY-MM-DD)")
        return None
    if lo is not None and value < lo:
        _err(errors, field, f"must be on or after {lo.isoformat()}")
    if hi is not None and value > hi:
        _err(errors, field, f"must be on or before {hi.isoformat()}")
    return value


def _check_policy(tables: dict, data: dict, errors: list[dict]) -> dict | None:
    if "policy_id" not in data:
        return None
    for row in tables["policy"]:
        if row["policy_id"] == data["policy_id"]:
            return row
    _err(errors, "policy_id", "is not a known policy")
    return None


def policy_coverages(tables: dict, policy_id: str) -> tuple[str, ...]:
    return tuple(
        pc["coverage_id"] for pc in tables["policy_coverage"] if pc["policy_id"] == policy_id
    )


def incident_types(tables: dict, product: str) -> tuple[str, ...]:
    """Union of the incident types of every coverage sold under this product, sorted."""
    types: set[str] = set()
    for cov in tables["coverage"]:
        if cov["product"] == product:
            types.update(masterdata.COVERAGE_PROFILE.get(cov["name"], ((), ()))[0])
    return tuple(sorted(types))


def _check_incident_type(value, product: str, tables: dict, errors: list[dict]) -> None:
    valid = incident_types(tables, product)
    if value not in valid:
        _err(
            errors,
            "incident_type",
            f"must be one of the {product} incident types: {', '.join(valid)}",
        )


def _parse_amount(value) -> tuple[int | None, str]:
    """Exact decimal parse (never float math). Returns (cents, "") or (None, problem)."""
    if isinstance(value, bool) or not isinstance(value, (str, int, float)):
        return None, "must be a number"
    try:
        amount = Decimal(str(value))
    except InvalidOperation:
        return None, "must be a number"
    if not amount.is_finite():
        return None, "must be a number"
    if amount <= 0:
        return None, "must be greater than 0"
    if amount > MAX_AMOUNT:
        return None, "must be at most 10000000 USD"
    if amount != amount.quantize(CENT):
        return None, "must have at most 2 decimal places"
    return int(amount.scaleb(2)), ""


def _check_items(value, coverages: tuple[str, ...] | None, errors: list[dict]) -> tuple[Item, ...]:
    """coverages is None when the policy is unknown; the coverage-on-policy check is then skipped."""
    if not isinstance(value, list):
        _err(errors, "items", "must be a list of items")
        return ()
    if not 1 <= len(value) <= MAX_ITEMS:
        _err(errors, "items", f"must have between 1 and {MAX_ITEMS} items")
    items = []
    for i, row in enumerate(value):
        path = f"items[{i}]"
        if not isinstance(row, dict):
            _err(errors, path, "must be an object")
            continue
        before = len(errors)
        _check_keys(row, ITEM_FIELDS, (), path + ".", errors)
        if "coverage_id" in row and coverages is not None and row["coverage_id"] not in coverages:
            _err(errors, f"{path}.coverage_id", "is not a coverage on this policy")
        if "item_type" in row and row["item_type"] not in vocab.ITEM_TYPES:
            _err(errors, f"{path}.item_type", f"must be one of: {', '.join(vocab.ITEM_TYPES)}")
        cents = None
        if "amount" in row:
            cents, problem = _parse_amount(row["amount"])
            if problem:
                _err(errors, f"{path}.amount", problem)
        if len(errors) == before:
            items.append(Item(row["coverage_id"], row["item_type"], cents))
    return tuple(items)


def _check_docs(value, submission: date | None, errors: list[dict]) -> tuple[Doc, ...]:
    if not isinstance(value, list):
        _err(errors, "documents", "must be a list of documents")
        return ()
    if len(value) > MAX_DOCS:
        _err(errors, "documents", f"must have at most {MAX_DOCS} documents")
    docs = []
    for i, row in enumerate(value):
        path = f"documents[{i}]"
        if not isinstance(row, dict):
            _err(errors, path, "must be an object")
            continue
        before = len(errors)
        _check_keys(row, DOC_REQUIRED, DOC_OPTIONAL, path + ".", errors)
        if "doc_type" in row and row["doc_type"] not in vocab.DOC_TYPES:
            _err(errors, f"{path}.doc_type", f"must be one of: {', '.join(vocab.DOC_TYPES)}")
        received = _date_field(
            row,
            "received_date",
            f"{path}.received_date",
            errors,
            lo=submission,
            hi=config.intake_horizon(),
        )
        status = row.get("status", "received")
        if "status" in row and status not in DOC_STATUSES:
            _err(errors, f"{path}.status", f"must be one of: {', '.join(DOC_STATUSES)}")
        if len(errors) == before:
            docs.append(Doc(row["doc_type"], received, status))
    return tuple(docs)
