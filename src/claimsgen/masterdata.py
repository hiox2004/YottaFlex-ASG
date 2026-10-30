"""Step 1 of the pipeline: parent/master tables (customer, coverage, adjuster, document_requirement).

Rows are plain dicts keyed by schema field names. Money is integer cents, dates are datetime.date;
export formats them later. Every stream is seeded separately so changing one table never shifts another.
"""

from datetime import date, timedelta
from random import Random

from claimsgen import config, ids
from claimsgen.vocab import PRODUCTS

FIRST = (
    "Asha", "Ben", "Carla", "Dev", "Elena", "Farid", "Grace", "Hiro", "Ines", "Jamal",
    "Kavya", "Liam", "Mei", "Noor", "Omar", "Priya", "Quinn", "Rosa", "Sam", "Tara",
    "Uma", "Victor", "Wen", "Xavier", "Yara", "Zane", "Amara", "Bruno", "Chloe", "Dmitri",
)  # fmt: skip
LAST = (
    "Patel", "Nguyen", "Garcia", "Kim", "Okafor", "Silva", "Novak", "Rossi", "Haddad", "Larsen",
    "Singh", "Tanaka", "Moreau", "Evans", "Costa", "Ivanov", "Khan", "Baker", "Reyes", "Frank",
)  # fmt: skip
REGIONS = ("North", "South", "East", "West", "Central", "Northeast", "Northwest", "Southeast")

# product -> (name, default_limit USD, default_deductible USD, exclusion item types)
CATALOGUE = {
    "AUTO": (
        ("Collision", 25000, 500, "cosmetic"),
        ("Theft", 30000, 500, ""),
        ("Third-party liability", 50000, 0, ""),
        ("Towing and rental", 3000, 100, ""),
    ),
    "HOME": (
        ("Fire", 200000, 1000, "cosmetic"),
        ("Water damage", 50000, 1000, ""),
        ("Burglary", 30000, 500, ""),
        ("Contents", 40000, 500, "cosmetic"),
    ),
    "HLTH": (
        ("Outpatient", 10000, 250, "cosmetic"),
        ("Hospital stay", 100000, 1000, "cosmetic"),
        ("Emergency care", 50000, 500, ""),
    ),
    "TRVL": (
        ("Trip cancellation", 8000, 100, ""),
        ("Baggage loss", 3000, 50, ""),
        ("Medical abroad", 50000, 250, ""),
    ),
    "LIAB": (
        ("Third-party injury", 100000, 1000, ""),
        ("Third-party property", 75000, 1000, ""),
    ),
}

# claim_type -> ((doc_type, mandatory), ...)
REQUIREMENTS = {
    "AUTO": (("photo", "Y"), ("police_report", "Y"), ("repair_estimate", "N")),
    "HOME": (("photo", "Y"), ("repair_estimate", "Y"), ("proof_of_ownership", "N")),
    "HLTH": (("medical_report", "Y"), ("invoice", "Y")),
    "TRVL": (("itinerary", "Y"), ("invoice", "Y"), ("incident_statement", "N")),
    "LIAB": (("incident_statement", "Y"), ("police_report", "Y")),
}


def rand_date(rng: Random, lo: date, hi: date) -> date:
    return lo + timedelta(days=rng.randint(0, (hi - lo).days))


def customers(n: int) -> list[dict]:
    rng = config.rng("customers")
    oldest = config.AS_OF - timedelta(days=85 * 365)
    youngest = config.AS_OF - timedelta(days=19 * 365)
    rows = []
    for i in range(1, n + 1):
        rows.append(
            {
                "customer_id": ids.cus(i),
                "full_name": f"{rng.choice(FIRST)} {rng.choice(LAST)}",
                "dob": rand_date(rng, oldest, youngest),
                "region": rng.choice(REGIONS),
                # all before 2024 so every policy start (>= 2024-01-01) follows customer creation
                "created_date": rand_date(rng, date(2019, 1, 1), date(2023, 12, 31)),
            }
        )
    return rows


def coverage() -> list[dict]:
    rows = []
    for product in PRODUCTS:
        for n, (name, limit, deductible, exclusions) in enumerate(CATALOGUE[product], start=1):
            rows.append(
                {
                    "coverage_id": ids.cov(product, n),
                    "product": product,
                    "name": name,
                    "default_limit": limit * 100,
                    "default_deductible": deductible * 100,
                    "exclusion_codes": exclusions,
                }
            )
    return rows


def adjusters(n: int) -> list[dict]:
    rng = config.rng("adjusters")
    return [
        {
            "adjuster_id": ids.adj(i),
            "full_name": f"{rng.choice(FIRST)} {rng.choice(LAST)}",
            "region": rng.choice(REGIONS),
            "specialty": PRODUCTS[(i - 1) % len(PRODUCTS)],  # guarantees every product is covered
            "max_open_claims": rng.randint(20, 40),
        }
        for i in range(1, n + 1)
    ]


def document_requirements() -> list[dict]:
    return [
        {
            "requirement_id": ids.drq(claim_type, doc_type),
            "claim_type": claim_type,
            "doc_type": doc_type,
            "mandatory": mandatory,
        }
        for claim_type in PRODUCTS
        for doc_type, mandatory in REQUIREMENTS[claim_type]
    ]


def generate(scale: float) -> dict[str, list[dict]]:
    c = config.counts(scale)
    return {
        "customer": customers(c.customers),
        "coverage": coverage(),
        "adjuster": adjusters(c.adjusters),
        "document_requirement": document_requirements(),
    }
