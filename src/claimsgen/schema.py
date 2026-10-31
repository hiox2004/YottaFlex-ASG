"""Single source of truth for all tables: fields, enums, ID patterns.

The data dictionary (docs/DATA_DICTIONARY.md) and the SQL schema (docs/schema.sql) are rendered from
TABLES, so the code and the docs cannot drift. Regenerate docs with: python -m claimsgen.schema_docs
Tables are listed in generation order (parents first).
"""

from dataclasses import dataclass

from claimsgen.vocab import (
    CLAIM_STATUSES,
    DECISIONS,
    DOC_TYPES,
    INCIDENT_TYPES,
    ITEM_TYPES,
    LABELS,
    PRODUCT_ALT,
    PRODUCTS,
    REASON_CODES,
    ROLES,
    RULE_RE,
)


@dataclass(frozen=True)
class Field:
    name: str
    type: str  # id | text | date | int | money | ratio | enum
    required: bool = True
    allowed: str = ""  # enum values or regex
    unit: str = ""
    unique: bool = False
    rule: str = ""
    fk: str = ""  # referenced table


@dataclass(frozen=True)
class Table:
    name: str
    pk: str
    pk_pattern: str
    description: str
    fields: tuple[Field, ...]


def _pk(name: str, pattern: str) -> Field:
    return Field(name, "id", True, pattern, "", True, "primary key, immutable, zero-padded")


def _fk(name: str, table: str, required: bool = True) -> Field:
    return Field(name, "id", required, "", "", False, f"must exist in {table}", table)


def _enum(name: str, values: tuple[str, ...], rule: str = "", required: bool = True) -> Field:
    return Field(name, "enum", required, "|".join(values), "", False, rule)


def _date(name: str, rule: str = "", required: bool = True) -> Field:
    return Field(name, "date", required, "YYYY-MM-DD", "", False, rule or "<= AS_OF")


def _money(name: str, rule: str, required: bool = True) -> Field:
    return Field(name, "money", required, ">= 0", "USD", False, rule)


def _text(name: str, rule: str = "non-empty", required: bool = True) -> Field:
    return Field(name, "text", required, "", "", False, rule)


def _int(name: str, rule: str, unit: str = "") -> Field:
    return Field(name, "int", True, ">= 0", unit, False, rule)


TABLES: tuple[Table, ...] = (
    Table(
        "customer",
        "customer_id",
        r"CUS-\d{6}",
        "A person who holds policies",
        (
            _pk("customer_id", r"^CUS-\d{6}$"),
            _text("full_name"),
            _date("dob", "age 18-85 at AS_OF"),
            _text("region"),
            _date("created_date"),
        ),
    ),
    Table(
        "coverage",
        "coverage_id",
        rf"COV-({PRODUCT_ALT})-\d{{3}}",
        "Catalogue of protections",
        (
            _pk("coverage_id", rf"^COV-({PRODUCT_ALT})-\d{{3}}$"),
            _enum("product", PRODUCTS),
            _text("name"),
            _money("default_limit", "> 0"),
            _money("default_deductible", "< default_limit"),
            _text("exclusion_codes", "pipe-separated ITEM_TYPES, may be empty", False),
            _text("covered_incident_types", "pipe-separated INCIDENT_TYPES the coverage pays for"),
            _text("covered_item_types", "pipe-separated ITEM_TYPES the coverage pays for"),
        ),
    ),
    Table(
        "adjuster",
        "adjuster_id",
        r"ADJ-\d{3}",
        "Claims handler",
        (
            _pk("adjuster_id", r"^ADJ-\d{3}$"),
            _text("full_name"),
            _text("region"),
            _enum("specialty", PRODUCTS),
            _int("max_open_claims", ">= 1", "claims"),
        ),
    ),
    Table(
        "document_requirement",
        "requirement_id",
        rf"DRQ-({PRODUCT_ALT})-[A-Z_]+",
        "Document types each claim type must have",
        (
            _pk("requirement_id", rf"^DRQ-({PRODUCT_ALT})-[A-Z_]+$"),
            _enum("claim_type", PRODUCTS),
            _enum("doc_type", DOC_TYPES),
            Field("mandatory", "enum", True, "Y|N"),
        ),
    ),
    Table(
        "policy",
        "policy_id",
        rf"POL-({PRODUCT_ALT})-2026-\d{{6}}",
        "Contract for one product",
        (
            _pk("policy_id", rf"^POL-({PRODUCT_ALT})-2026-\d{{6}}$"),
            _fk("customer_id", "customer"),
            _enum("product", PRODUCTS, "must equal the product segment of policy_id"),
            _date("start_date", "start_date < end_date", True),
            Field("end_date", "date", True, "YYYY-MM-DD", "", False, "> start_date"),
            _money("premium", "> 0"),
        ),
    ),
    Table(
        "policy_event",
        "event_id",
        rf"PEV-POL-({PRODUCT_ALT})-2026-\d{{6}}-\d{{3}}",
        "Append-only policy lifecycle events",
        (
            _pk("event_id", rf"^PEV-POL-({PRODUCT_ALT})-2026-\d{{6}}-\d{{3}}$"),
            _fk("policy_id", "policy"),
            _enum(
                "event_type", ("issued", "lapsed", "cancelled", "expired"), "first event is issued"
            ),
            _date("event_date", "within policy start..end window, <= AS_OF"),
        ),
    ),
    Table(
        "policy_coverage",
        "policy_coverage_id",
        rf"PCV-POL-({PRODUCT_ALT})-2026-\d{{6}}-\d{{3}}",
        "Bridge: coverage terms that apply to a policy",
        (
            _pk("policy_coverage_id", rf"^PCV-POL-({PRODUCT_ALT})-2026-\d{{6}}-\d{{3}}$"),
            _fk("policy_id", "policy"),
            _fk("coverage_id", "coverage"),
            _money("limit_amount", "> 0"),
            _money("deductible", "< limit_amount"),
            _date("effective_start", "<= effective_end"),
            Field("effective_end", "date", True, "YYYY-MM-DD", "", False, ">= effective_start"),
        ),
    ),
    Table(
        "incident",
        "incident_id",
        r"INC-2026-\d{6}",
        "The event that triggers a claim",
        (
            _pk("incident_id", r"^INC-2026-\d{6}$"),
            _fk("policy_id", "policy"),
            _date(
                "incident_date", "<= claim submission_date except claim_before_policy_start path"
            ),
            _enum("incident_type", INCIDENT_TYPES, "valid for the policy product"),
        ),
    ),
    Table(
        "claim",
        "claim_id",
        r"CLM-2026-\d{6}",
        "Request for payment",
        (
            _pk("claim_id", r"^CLM-2026-\d{6}$"),
            _fk("policy_id", "policy"),
            _fk("incident_id", "incident"),
            _enum("claim_type", PRODUCTS, "must equal policy product"),
            _date("submission_date", "claim date; incident_date is separate"),
            _money("claimed_amount", "equals sum of claim_item.claimed_amount"),
        ),
    ),
    Table(
        "claim_item",
        "item_id",
        r"ITM-CLM-2026-\d{6}-\d{3}",
        "One line of a claim",
        (
            _pk("item_id", r"^ITM-CLM-2026-\d{6}-\d{3}$"),
            _fk("claim_id", "claim"),
            _fk("coverage_id", "coverage"),
            _enum("item_type", ITEM_TYPES),
            _money("claimed_amount", "> 0"),
        ),
    ),
    Table(
        "document",
        "document_id",
        r"DOC-CLM-2026-\d{6}-\d{3}",
        "Document metadata only",
        (
            _pk("document_id", r"^DOC-CLM-2026-\d{6}-\d{3}$"),
            _fk("claim_id", "claim"),
            _enum("doc_type", DOC_TYPES),
            _date("received_date", ">= claim submission_date"),
            _enum("status", ("received", "rejected")),
        ),
    ),
    Table(
        "claim_adjuster_assignment",
        "assignment_id",
        r"ASN-CLM-2026-\d{6}-\d{3}",
        "Adjuster assignment record; reassignment is a new row",
        (
            _pk("assignment_id", r"^ASN-CLM-2026-\d{6}-\d{3}$"),
            _fk("claim_id", "claim"),
            _fk("adjuster_id", "adjuster"),
            _date("assigned_date", ">= claim submission_date"),
            _enum("reason", ("initial", "reassigned", "workload")),
        ),
    ),
    Table(
        "assessment",
        "assessment_id",
        r"ASM-CLM-2026-\d{6}-\d{3}",
        "Decision with reason; new row when re-run",
        (
            _pk("assessment_id", r"^ASM-CLM-2026-\d{6}-\d{3}$"),
            _fk("claim_id", "claim"),
            _fk("adjuster_id", "adjuster"),
            _date("assessment_date", ">= assignment date"),
            _enum("decision", DECISIONS),
            Field("rule_id", "text", True, RULE_RE, "", False, "rule catalogue id"),
            _enum("reason_code", REASON_CODES),
            _money("eligible_amount", "<= claimed_amount"),
            _money("deductible_applied", "per R-PAY-01"),
            _money("payable_amount", "per R-PAY-01"),
            Field("fraud_score", "ratio", True, "0..1", "", False, "flags / 4"),
            _text(
                "missing_doc_types",
                "pipe-separated DOC_TYPES requested; empty unless pend_docs",
                False,
            ),
        ),
    ),
    Table(
        "reserve",
        "reserve_id",
        r"RSV-CLM-2026-\d{6}-\d{3}",
        "Append-only reserve history: FNOL row at submission, then revised",
        (
            _pk("reserve_id", r"^RSV-CLM-2026-\d{6}-\d{3}$"),
            _fk("claim_id", "claim"),
            _date("reserve_date", ">= submission_date"),
            _money("amount", "first = FNOL; latest = final payable (0 on denial)"),
            _enum("basis", ("preliminary", "revised")),
            Field("rule_id", "text", True, RULE_RE, "", False, "R-RSV-01 | R-RSV-02"),
        ),
    ),
    Table(
        "settlement",
        "settlement_id",
        r"SET-CLM-2026-\d{6}-\d{3}",
        "Write-once; stage = which dates are filled",
        (
            _pk("settlement_id", r"^SET-CLM-2026-\d{6}-\d{3}$"),
            _fk("claim_id", "claim"),
            _money("recommended_amount", "<= remaining policy_coverage limit"),
            _date("recommended_date"),
            _money("approved_amount", "= recommended_amount", False),
            _date("approved_date", ">= recommended_date", False),
            _enum(
                "approver_role",
                ("process_owner", "approver"),
                "approver if amount > threshold",
                False,
            ),
            _money("paid_amount", "<= approved_amount", False),
            _date("paid_date", ">= approved_date", False),
        ),
    ),
    Table(
        "claim_status_history",
        "event_id",
        r"EVT-CLM-2026-\d{6}-\d{3}",
        "Append-only claim event log; claim status = last event",
        (
            _pk("event_id", r"^EVT-CLM-2026-\d{6}-\d{3}$"),
            _fk("claim_id", "claim"),
            _enum("from_status", CLAIM_STATUSES, "empty only for the first event", False),
            _enum("to_status", CLAIM_STATUSES, "legal transition from from_status"),
            _date("event_date", "non-decreasing per claim"),
            _enum("actor_role", ROLES),
            Field("rule_id", "text", False, RULE_RE, "", False, "rule catalogue id"),
            _enum("reason_code", REASON_CODES),
        ),
    ),
    Table(
        "ground_truth",
        "entity_id",
        r"any entity id",
        "Separate answer key; never joined into inputs",
        (
            Field(
                "entity_id", "id", True, "", "", False, "id of the labelled row (unique with label)"
            ),
            _text("entity_type", "table name"),
            _enum("label", LABELS),
            _enum("origin", ("baseline", "injected")),
            _enum("kind", ("business_outcome", "integrity_defect", "boundary")),
            _text("expected_decision"),
            Field("rule_id", "text", False, RULE_RE, "", False, "rule that applies"),
        ),
    ),
)

TABLE_BY_NAME = {t.name: t for t in TABLES}
_SQL_TYPE = {
    "id": "TEXT",
    "text": "TEXT",
    "date": "TEXT",
    "enum": "TEXT",
    "int": "INTEGER",
    "money": "NUMERIC",
    "ratio": "REAL",
}
