# Study note: the AI approach

Read [../AI_APPROACH.md](../AI_APPROACH.md) first. This note is for explaining it out loud, for example in an interview.

## The one-minute answer
There is no model in the product. Every claim decision is a rule that cites a rule id, so the same seed gives the same bytes
and the scores against the answer key are exact. If it became hybrid, the principle is **AI proposes, rules decide, a person
confirms anything uncertain.** One model call goes in (free text to a structured claim) and one comes out (a decision to a
plain-language answer). Neither is built; both have a contract and a way to be scored.

## Why not just use an LLM for the decision?
- **Repeatability.** A model can give a different answer on the same input, so precision and recall against planted cases
  become approximate, and a "byte-identical rebuild" claim stops being true.
- **Audit.** "R-PAY-01: eligible minus deductible, capped at the remaining limit" can be checked by a person. "The model
  judged so" cannot.
- **Cost of a wrong answer.** A wrongly denied claim is the expensive error in insurance (complaints, bad-faith exposure).
  Rules fail toward a person (`pend_docs`, `refer_review`), not toward a guess.
- **No information gain.** Our input is already a validated form. A model adds risk without adding information there.

## Where a model genuinely helps
| Addition | Direction | One line |
|---|---|---|
| Extraction | in | Emails and scans become the existing intake template, with a confidence per field |
| Adjuster summaries | out | Narrative built from the rule trace; rejected if it cites anything not in it |
| Document triage | in | Classify uploads before the R-DOC-01 check; a person can override |
| Similarity flags | in | Near-duplicate narratives route to review, never to a denial |
| Chat assistant | out | Read-only tools over decision, history and metrics; answers in plain language; hands off when unsure |

## Likely questions and short answers
- **"So you did not use AI?"** The product has no model by design. The design for adding one is written down, with the
  contract, the guardrails and the test plan, and the measurement harness comes before the model.
- **"How would you stop it making things up?"** Closed schema for extraction, read-only tools for chat, and a post-check
  that every id, rule, date and amount in a reply appears in the tool results. If it cannot ground an answer it says so and
  routes to a person.
- **"How do you know the extractor is good enough?"** Render narratives from generated claims (true fields known), score
  per field, pick the confidence threshold from the confidence-versus-correctness curve, then compare the decision on the
  extracted draft with the decision on the true claim, by edge case. A hard gate before it is switched on.
- **"What about prompt injection in claim text?"** Claim text is data. It is quoted, outputs are schema-validated, and no
  claim text can change a rule, threshold or approver. The chat has no write tools to abuse.
- **"Why a deterministic mapper before a model?"** Structured formats (837, ACORD) are exact, free and testable. A model is
  only for what the mapper cannot read.
- **"What would you refuse to do?"** Let a model approve, deny, price or cap a claim; generate the dataset or its labels
  with a model; trust model confidence without calibrating it on our own data.
- **"What is the cheapest real step?"** A narrative generator plus a field-level extraction scoring harness, with the
  extractor stubbed. It proves the "scored against the answer key" claim in code before any model is involved.

## Local models (see [../LOCAL_MODELS.md](../LOCAL_MODELS.md))
- **Why local:** claim text is nonpublic personal information; a hosted LLM is a third-party recipient (NAIC #668 wording,
  our reading), health claims add HIPAA business associate agreements, and local means no keys or retention questions. The
  data here is synthetic, so this is a design argument, not a present legal duty.
- **Default stack, low to medium confidence:** Ollama in Docker on CPU, a small Apache-2.0 model (Qwen3.5 4B; Gemma 4 E2B or
  E4B as alternates), nomic-embed-text for similarity. Expect 10 to 30 seconds per extraction on a laptop, so precompute.
- **What the evidence says:** schema-constrained decoding gives valid JSON, not correct values; verbalised confidence is
  badly calibrated, so route on value-token log-probs plus code checks; models are weak at dates, so extract the phrase and
  resolve it in code; embeddings over-match templated text, so they only suggest duplicate candidates.
- **Honest limits:** no source measured hallucination rates of 1 to 8B models on insurance text, speeds are secondary-source
  figures, and regulator claims come from secondary summaries. The first step is a 10-claim trial, then shadow mode.
- **Reproducibility answer:** "same machine, same build, same flags, run twice, compare hashes", never identical across
  machines, and model output never feeds a rule or the dataset.

## Terms
See the AI section of [GLOSSARY.md](GLOSSARY.md).
