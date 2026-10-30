"""Deterministic, zero-padded ID formatters. Child IDs embed their parent ID.

Generation assigns provisional sort-order IDs; the finalize step remaps every claim-derived ID once through a single
old->new dict after injection. After finalize, IDs are immutable."""


def cus(n: int) -> str:
    return f"CUS-{n:06d}"


def pol(product: str, n: int) -> str:
    return f"POL-{product}-2026-{n:06d}"


def cov(product: str, n: int) -> str:
    return f"COV-{product}-{n:03d}"


def adj(n: int) -> str:
    return f"ADJ-{n:03d}"


def drq(claim_type: str, doc_type: str) -> str:
    return f"DRQ-{claim_type}-{doc_type.upper()}"


def inc(n: int) -> str:
    return f"INC-2026-{n:06d}"


def clm(n: int) -> str:
    return f"CLM-2026-{n:06d}"


def _child(prefix: str, parent_id: str, n: int) -> str:
    return f"{prefix}-{parent_id}-{n:03d}"


def pev(policy_id: str, n: int) -> str:
    return _child("PEV", policy_id, n)


def pcv(policy_id: str, n: int) -> str:
    return _child("PCV", policy_id, n)


def itm(claim_id: str, n: int) -> str:
    return _child("ITM", claim_id, n)


def doc(claim_id: str, n: int) -> str:
    return _child("DOC", claim_id, n)


def asn(claim_id: str, n: int) -> str:
    return _child("ASN", claim_id, n)


def asm(claim_id: str, n: int) -> str:
    return _child("ASM", claim_id, n)


def rsv(claim_id: str, n: int) -> str:
    return _child("RSV", claim_id, n)


def settlement(claim_id: str, n: int) -> str:
    return _child("SET", claim_id, n)


def evt(claim_id: str, n: int) -> str:
    return _child("EVT", claim_id, n)
