# Research note: realism benchmarks for insurance claims data (Haiku worker, 2026-10-31)

Snippet-level web research from search excerpts only; many figures come from vendor blogs or aggregators. Verify before citing. Items marked UNVERIFIED were not found.

## Benchmarks found
| Metric | Typical range | Source |
|---|---|---|
| Auto collision frequency | ~5-6 claims per 100 vehicle-years (4.16% of collision policyholders claimed in 2024) | https://www.iii.org/fact-statistic/facts-statistics-auto-insurance |
| Auto collision severity | ~$3.8k (2019) to ~$10.3k (2022-24) | https://content.naic.org/sites/default/files/publication-aut-pb-auto-insurance-database.pdf |
| Homeowners frequency | fire ~0.23 per 100 policies, water ~1.5 per 100 | https://www.iii.org/fact-statistic/facts-statistics-homeowners-and-renters-insurance |
| Homeowners severity | fire ~$84-88k, water ~$14-15k | same |
| Travel | trip cancellation 26% of claims at ~$1,456 avg; baggage 4% at ~$174-210; ~17% of trips claim (low authority) | https://www.squaremouth.com/press-room/rising-travel-costs-led-to-a-big-shift-in-travel-insurance-payouts-in-2024 |
| General liability severity | ~$78k (5-year avg), ~$97k recent | https://core.verisk.com/-/media/Executive-Insights/GL/2024_GL_Exec_Insights_1st_Ed_20240923.pdf |
| Initial denial rate | health in-network ~19-20% (ACA 2023-24); P&C UNVERIFIED | https://www.kff.org/patient-consumer-protections/claims-denials-and-appeals-in-aca-marketplace-plans-in-2024/ |
| SIU referral rate | common band 3-10% of claims | https://insurancefraud.org/wp-content/uploads/Coalition-Keys-Study.pdf |
| Touchless / straight-through | ~10-20% of total volume typical; 70-90% on basic personal auto at leading carriers (vendor claims) | https://actuary.info/insights/ai-claims-cycle-time-75-percent-stp-rate-threshold |
| Cycle time FNOL to payment | homeowners ~40.7 days (J.D. Power 2026 via search); repairable auto ~19.3 days; PD-only auto 4-7 days (vendor) | https://www.assured.com/blog/claims-cycle-time-benchmarks |
| Annual personal auto retention | ~78-82% | https://risk.lexisnexis.com/about-us/press-room/press-release/20250612-us-auto-insurance-trends-report |
| Workflow stages | 5-6 (FNOL, coverage, assignment, reserve, settlement); authority tiers such as $10k/$50k/$250k are vendor illustrations | https://www.decerto.com/us/post/claims-lifecycle-management-best-practices-for-insurers |
| Health outpatient, GL frequency, duplicate-claim rate | UNVERIFIED | - |

## Verdicts on our full-scale numbers (from the worker)
- Claims per policy 0.5: too high for auto/home; defensible only for a blended book (travel/health). Define the basis.
- Mean $10,075 / median $6,700: plausible; a single lognormal understates fire and liability tails.
- Approved/paid 62.1%, denied 23.0%: plausible for a health-heavy book; P&C denial rate UNVERIFIED.
- Under review 6.5% (fraud 3% + duplicate 3.5%): plausible, low end of the 3-10% band.
- Touchless 61.5%: too high for a blended book (benchmark 10-20%); fits only simple personal auto.
- Submission to paid median 8 days, p90 12: too low and too narrow (home ~40 days, repairable auto ~19; liability 60-90).
- 17% of settlements needing the senior approver above $10k is inconsistent with the amount distribution (the lognormal puts about a third of claims above $10k): check whether settlements are net of deductible and limit, or whether 17% is wrong.
- Policy status 75/13/8/4: plausible as a snapshot; lapse plus cancel (12%) is low against 18-22% annual attrition.
- Fraud referral 3%, duplicate 3.5%: plausible.
