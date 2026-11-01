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

## AI design (proposed, not built)
| Term | Meaning |
|---|---|
| Hybrid system | Rules decide; a model only proposes fields, drafts text or raises flags; a person confirms anything uncertain |
| Extraction | Turning free text or scans into the intake template, with a confidence per field |
| Confidence threshold | Per-field cut-off below which a draft goes to a person; chosen from the confidence-versus-correctness curve |
| Grounding | Every id, rule, date and amount in a model reply must appear in the tool results it was built from |
| Read-only tool | A function the assistant can call to look something up; none can approve, deny, pay or edit |
| Shadow mode | The model runs and is logged but its output is not used, so it can be scored safely |
| Ship gate | A fixed accuracy bar the model must pass on generated test data before it is switched on |
| Prompt injection | Claim text that tries to instruct the model; handled by treating text as quoted data and validating output |
