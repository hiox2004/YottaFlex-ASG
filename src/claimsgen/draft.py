"""The shape of a claim submitted through intake (the contract shared by intake validation, the what-if evaluation and the UI).

A Draft is a claim BEFORE any rule has seen it. claim_type is not part of the input: it is the product of the policy.
Money is integer cents; `to_json` writes amounts as exact `dollars.cents` text so a draft has one canonical form.
"""

import json
from dataclasses import dataclass
from datetime import date


@dataclass(frozen=True)
class Item:
    coverage_id: str
    item_type: str
    cents: int


@dataclass(frozen=True)
class Doc:
    doc_type: str
    received_date: date
    status: str = "received"


@dataclass(frozen=True)
class Draft:
    policy_id: str
    incident_date: date
    incident_type: str
    submission_date: date
    items: tuple[Item, ...]
    documents: tuple[Doc, ...] = ()

    def to_json(self) -> dict:
        return {
            "policy_id": self.policy_id,
            "incident_date": self.incident_date.isoformat(),
            "incident_type": self.incident_type,
            "submission_date": self.submission_date.isoformat(),
            "items": [
                {
                    "coverage_id": i.coverage_id,
                    "item_type": i.item_type,
                    "amount": f"{i.cents // 100}.{i.cents % 100:02d}",
                }
                for i in self.items
            ],
            "documents": [
                {
                    "doc_type": d.doc_type,
                    "received_date": d.received_date.isoformat(),
                    "status": d.status,
                }
                for d in self.documents
            ],
        }

    def canonical(self) -> str:
        """Stable text form, usable as a cache key."""
        return json.dumps(self.to_json(), sort_keys=True, separators=(",", ":"))
