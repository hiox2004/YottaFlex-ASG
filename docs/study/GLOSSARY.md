# Glossary

## Insurance
| Term | Meaning here |
|---|---|
| Policy | Contract between customer and insurer for one product, with start and end dates |
| Coverage | A type of protection (e.g. collision) with a limit, deductible and exclusions |
| Limit | Maximum the insurer pays under a coverage |
| Deductible | Amount the customer bears first; payable = eligible - deductible, never below 0 |
| Exclusion | Item type the coverage does not pay for |
| Incident | The event (accident, fire) with its own date; separate from when the claim is filed |
| Claim | Request for payment tied to a policy and an incident; has items and documents |
| Claim item | One line of the claim, tied to a coverage |
| Adjuster | Person who assesses the claim |
| Assessment | Adjuster/rules decision: approve, deny, pend docs, refer for review |
| Reserve | Money the insurer sets aside for a claim; preliminary first, revised on change |
| Settlement | Recommended, approved, then paid amount |
| Lapsed / cancelled / expired | Policy ended by non-payment / by event / by reaching end date |
| FNOL | First notice of loss: the moment a claim is first reported (our submission_date) |

## Project
| Term | Meaning |
|---|---|
| Ground truth | Separate answer key of planted anomalies and expected decisions; never joined into input tables |
| Baseline | The clean dataset before injection |
| Injection | Deliberately planting one of six labelled edge cases |
| Business outcome | Edge case the rules handle correctly (e.g. denial) |
| Integrity defect | Edge case validation must catch (e.g. paid twice) |
| Rule ID | Code like R-COV-02 stored on every decision with a reason code |
| AS_OF | Fixed "today" in config, replacing the system clock for reproducibility |
| Scale | Parameter: 1.0 = 2,000 policies / 1,000 claims; starter = 0.05 |
| Origin | ground_truth column: baseline or injected |
