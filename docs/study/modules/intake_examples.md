# intake_examples

Source: `src/claimsgen/intake_examples.py`. Tests: `tests/test_intake_examples.py`.

## Purpose
Seven ready-made claims a reviewer can load in the Streamlit intake tab. Each deliberately reaches one rule, so the what-if
evaluation shows every kind of outcome without the reviewer inventing inputs. Policy ids differ by scale, so `build(tables)` builds
the examples per dataset. `EXPECTED` maps each key to the (decision, rule_id, reason_code) of the last assessment.

## Examples
| key | intended outcome | rule |
|---|---|---|
| clean_approve | approve, eligible | R-PAY-01 |
| missing_document | pend_docs, missing_document | R-DOC-01 |
| duplicate | refer_review, duplicate_claim | R-ELG-03 |
| lapsed_policy | deny, policy_not_in_force | R-COV-02 |
| over_limit | approve, limit_reached (payable capped) | R-PAY-01 |
| claim_before_start | deny, before_policy_start | R-COV-01 |
| within_deductible | deny, within_deductible | R-PAY-01 |

## Selection principle
- Deterministic: policy ids are scanned in sorted order and the first candidate passing explicit filters wins. Only the input tables
  are used (never ground_truth), no randomness, no clock; all dates are explicit and not after `config.intake_horizon()`.
- Filters avoid pre-empting rules: ordinary examples use policies with no lapse/cancel event, no existing claim (so no duplicate or
  shared limit), and a customer with fewer than F2 earlier claims. The incident is `FRAUD_F1_DAYS + 1` days after the policy start
  (F1 cannot fire) and inside the policy and coverage effective dates (R-COV-03). Items use a non-excluded item type from
  `masterdata.COVERAGE_PROFILE`; documents are received on the submission date.
- duplicate copies an assessed, non-R-COV claim a few days later; lapsed_policy picks a day after the lapse inside the policy term.
- The tests run every example through `whatif.evaluate` at the starter and full scale and compare with `EXPECTED`.

Robustness (IMP-015): when no policy fits an example, every drafter raises `LookupError` (`_normal` and `_before_start` used to raise `StopIteration` / `IndexError`).
