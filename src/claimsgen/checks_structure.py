"""Structural validation: key uniqueness, ID formats, FK integrity, enums, required fields, date horizon, label leakage.

Every failure is recorded against the id of the offending row (ground_truth rows use entity_id:label), so after
injection the set of failing ids can be compared with the integrity-defect labels.
"""

import re
from collections import Counter
from dataclasses import dataclass, field

from claimsgen import config, schema

# Event and transaction dates only. Term dates (end_date, effective_start/end) may legitimately be after AS_OF.
DATE_FIELDS = {
    "customer": ("dob", "created_date"),
    "policy": ("start_date",),
    "policy_event": ("event_date",),
    "incident": ("incident_date",),
    "claim": ("submission_date",),
    "document": ("received_date",),
    "claim_adjuster_assignment": ("assigned_date",),
    "assessment": ("assessment_date",),
    "reserve": ("reserve_date",),
    "settlement": ("recommended_date", "approved_date", "paid_date"),
    "claim_status_history": ("event_date",),
}
LEAK_NAMES = {
    "label",
    "origin",
    "kind",
    "expected_decision",
    "is_fraud",
    "anomaly_type",
    "issue_type",
}


@dataclass
class Check:
    category: str
    name: str
    checked: int = 0
    failures: list = field(default_factory=list)  # (id, why)

    def fail(self, ident: str, why: str = "") -> None:
        self.failures.append((ident, why))

    @property
    def ok(self) -> bool:
        return not self.failures

    @property
    def ids(self) -> set:
        return {i for i, _ in self.failures}


def row_id(table: schema.Table, row: dict) -> str:
    return f"{row['entity_id']}:{row['label']}" if table.name == "ground_truth" else row[table.pk]


def structure_checks(t: dict) -> list[Check]:
    pk = Check("keys", "primary key uniqueness")
    fmt = Check("keys", "ID format")
    fk = Check("joins", "foreign key integrity")
    enum = Check("domain", "enum values")
    req = Check("domain", "required fields present")
    money = Check("domain", "money is a non-negative integer (cents)")
    horizon = Check("dates", "event dates not after AS_OF")
    leak = Check("leakage", "no label or unexpected columns in input tables")
    keys = {tb.name: {row_id(tb, r) for r in t[tb.name]} for tb in schema.TABLES if tb.name in t}
    for tb in schema.TABLES:
        rows = t.get(tb.name)
        if rows is None:
            continue
        counts = Counter(row_id(tb, r) for r in rows)
        pk.checked += len(rows)
        for ident, n in counts.items():
            if n > 1:
                pk.fail(ident, f"{tb.name}: duplicated {n}x")
        by_name = {f.name: f for f in tb.fields}
        pattern = by_name[tb.pk].allowed
        columns = set().union(*rows) if rows else set()
        if tb.name != "ground_truth" and (LEAK_NAMES & columns or columns - set(by_name)):
            leak.fail(
                tb.name, f"unexpected or label-like columns: {sorted(columns - set(by_name))}"
            )
        leak.checked += tb.name != "ground_truth"
        for r in rows:
            ident = row_id(tb, r)
            if tb.name != "ground_truth":
                fmt.checked += 1
                if not re.match(pattern, str(r[tb.pk])):
                    fmt.fail(ident, f"{tb.name}: bad id format")
            for f in tb.fields:
                v = r.get(f.name)
                empty = v is None or v == ""
                req.checked += f.required
                if f.required and empty:
                    req.fail(ident, f"{tb.name}.{f.name} missing")
                    continue
                if empty:
                    continue
                if f.fk and f.fk in keys:
                    fk.checked += 1
                    if v not in keys[f.fk]:
                        fk.fail(ident, f"{tb.name}.{f.name} -> {f.fk} {v} not found")
                if f.type == "enum":
                    enum.checked += 1
                    if v not in f.allowed.split("|"):
                        enum.fail(ident, f"{tb.name}.{f.name}={v}")
                if f.type == "money":
                    money.checked += 1
                    if not isinstance(v, int) or v < 0:
                        money.fail(ident, f"{tb.name}.{f.name}={v}")
            for name in DATE_FIELDS.get(tb.name, ()):
                if r.get(name) is not None:
                    horizon.checked += 1
                    if r[name] > config.AS_OF:
                        horizon.fail(ident, f"{tb.name}.{name} {r[name]} after AS_OF")
    return [pk, fmt, fk, enum, req, money, horizon, leak]
