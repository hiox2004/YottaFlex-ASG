"""Enum vocabularies shared by the schema, generator and rules engine."""

PRODUCTS = ("AUTO", "HOME", "HLTH", "TRVL", "LIAB")
PRODUCT_ALT = "|".join(PRODUCTS)
ROLES = ("requester", "process_owner", "approver", "operations_analyst", "administrator")
CLAIM_STATUSES = (
    "submitted",
    "denied",
    "docs_pending",
    "under_review",
    "assessed",
    "approved",
    "paid",
)
DECISIONS = ("approve", "deny", "pend_docs", "refer_review")
DOC_TYPES = (
    "photo",
    "police_report",
    "repair_estimate",
    "medical_report",
    "invoice",
    "proof_of_ownership",
    "itinerary",
    "incident_statement",
)
INCIDENT_TYPES = (
    "collision",
    "theft",
    "fire",
    "water_damage",
    "burglary",
    "illness",
    "injury",
    "trip_cancellation",
    "baggage_loss",
    "third_party_injury",
    "third_party_property",
)
ITEM_TYPES = (
    "repair",
    "replacement",
    "towing",
    "rental_car",
    "medical_treatment",
    "hospital_stay",
    "cancellation_fee",
    "baggage",
    "liability_payment",
    "cosmetic",
)
REASON_CODES = (
    "submitted",
    "before_policy_start",
    "policy_not_in_force",
    "outside_coverage_period",
    "duplicate_claim",
    "missing_document",
    "suspected_fraud",
    "item_not_covered",
    "item_excluded",
    "within_deductible",
    "limit_reached",
    "docs_received",
    "approved_by_authority",
    "payment_recorded",
    "reassigned",
)
LABELS = (
    "claim_before_policy_start",
    "cancelled_before_incident",
    "duplicate_incident",
    "settlement_exceeds_limit",
    "missing_mandatory_doc",
    "paid_twice",
    "lapsed_policy",
    "outside_coverage_period",
    "incomplete_evidence",
    "claim_over_limit",
    "suspected_fraud",
    "boundary_incident_on_start",
    "boundary_incident_on_end",
    "boundary_amount_at_limit",
    "boundary_amount_at_deductible",
)
RULE_RE = r"R-[A-Z]{3}-\d{2}"
