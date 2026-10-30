# Research note: what hiring reviewers look for (Haiku worker, 2026-10-31)

Snippet-level web research (6 searches, no full pages fetched). Weights are illustrative blog figures, not an industry standard. No public FDE-specific weighted rubric was found.

## Distilled rubric
| Criterion | A strong submission shows | Red flags | Typical weight |
|---|---|---|---|
| Runs as submitted | One-command setup, pinned versions, core path works first try | Manual steps, broken core path (often a gate) | Gate; "functionality" 30% in one AI-eng rubric |
| Code quality and structure | Clear modules, error handling, edge cases | Shallow error handling, overbuilt scope the brief did not ask for | 15-35% |
| Testing and verification | A few meaningful tests on core behaviour and edge cases, mapped to README claims | No tests, happy-path only, coverage as a proxy | ~10% (+15-20% verification in AI-coding guides) |
| Evaluation / correctness vs ground truth | Metrics defined, computed, explained; limits stated | Metrics asserted without a script | Part of correctness (~30%) |
| Written reasoning | Decisions with alternatives, honest limits, next steps | Polished prose with no trade-offs, claims the code does not back | 10-20% |
| AI-use disclosure | Tools named, what they did, what the human checked, prompt log | Undisclosed use, "the AI wrote that" when asked to explain | Mostly judged in the walkthrough |
| Reproducibility and hygiene | Fixed seed, deterministic output, meaningful history, no secrets | Single "init" commit, committed secrets, no .gitignore | Folded into code quality |
| Walkthrough defensibility | Can change code live and explain a trade-off | Cannot explain own code | Gate-like in several guides |

## Sources (snippet-level)
- Ethyca FDE take-home: https://github.com/ethyca/fde-takehome
- FDE interview guide: https://www.sundeepteki.org/advice/the-definitive-guide-to-forward-deployed-engineer-interviews-in-2026
- AI-engineering field guide, home assignments: https://github.com/alexeygrigorev/ai-engineering-field-guide/blob/main/interview/questions/06-home-assignments.md
- EasyApply take-home guide: https://easyapply.com/blog/take-home-assessment-guide
- TechScreen 2026 guide: https://www.techscreen.app/articles/take-home-coding-assignment-guide-2026
- Harvard Bok Center on prompt logs (prompts, responses, what was kept or changed and why): https://bokcenter.harvard.edu/courses-and-assignments-in-age-of-ai
- Interviewer Signal, verifying authorship: https://interviewersignal.com/blog/how-to-verify-take-home-assignment-authorship
- Maywise, how many tests are enough (3-8 meaningful): https://maywise.in/blog/take-home-assignments-in-interviews
- Osmani, code review in the age of AI: https://addyo.substack.com/p/code-review-in-the-age-of-ai

## UNVERIFIED
First-pass time figures ("10-15 minutes"), the "47 take-homes" rubric, any exact scoring method for prompt logs in hiring, AI-README overclaiming as a hiring-team norm, vendor claims that platforms track AI use.
