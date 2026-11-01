# AI approach: why the decision path has no LLM, and the hybrid design we would add

Short version is in the [README](../README.md#ai-approach-in-brief). This page is the detail. Which local models and
runtimes would fit, and what the research says about them, is in [LOCAL_MODELS.md](LOCAL_MODELS.md).

## Position

The product is a deterministic rules engine with an AI-shaped gap in front of it. We did not put a model in the decision
path, and we did not ship one at the edges either. We did design the edges: what the model would do, what contract it
fills, what stops it from deciding anything, and how we would measure it before trusting it. Nothing below is built unless
it says so.

## Where AI appears today

The product contains no model. The only AI-related feature is a helper for reviewers:

| Where | How | Effect on the product |
|---|---|---|
| Test-claim authoring | [claim_prompt.py](../src/claimsgen/claim_prompt.py) builds a copy-and-paste prompt from the dataset input tables; any AI chat can answer with one claim as JSON, which is pasted into the Submit tab | Output passes the same `intake.parse_and_validate` and the same rules as a typed form. No key, no network call |
| Decisions, reserves, settlements | None | Every outcome cites a rule id (R-xxx) |

## Why the decision path stays deterministic

1. **The evaluation needs exact answers.** The same seed gives the same bytes, and precision and recall against planted
   cases only mean something if decisions repeat exactly. A model in the loop makes the scores approximate.
2. **Coverage and payment need an audit trail a person can check.** "R-PAY-01: eligible minus deductible, capped at the
   remaining limit" is a reason. "The model judged so" is not, and a wrongly denied claim is the costly error in this domain.
3. **The input is already structured.** The intake form is validated field by field. A model would add risk without adding
   information. It only earns its place where the input is not structured (below).
4. **Free and local.** The FAQ asks for free or locally runnable services. No keys, accounts or run-time network calls
   means a reviewer runs one Docker command.

## The hybrid design we would add

```
 emails / scans / portal text / ACORD, 837 files
            |
   [1] extraction  -- model proposes fields + confidence ----+
            |                                               |
     DraftClaim (same contract as the JSON form)        low confidence
            |                                               |
   intake.parse_and_validate  <-- unchanged            human confirm queue
            |
   rules engine (R-COV, R-ELG, R-DOC, R-FRD, R-PAY)  <-- unchanged, decides
            |
   decision + rule trace + history
            |
   [2] summary  [3] document triage  [4] similarity signals  -- read-only, never decide
            |
   [5] chat assistant: read-only tools over the decision, history and metrics,
       replies in plain language, hands off to a person when unsure
```

The rule: **AI proposes, rules decide, a person confirms anything uncertain.** Each addition sits on one side of the
engine, never inside it. There are two natural model calls: one **in** (free text becomes a structured claim) and one
**out** (a decision becomes a plain-language answer in a chat).

### 1. Extraction layer (highest value)

- **Problem.** Real claims arrive as loss notices, 837 files, portal forms, emails and scans, not as our JSON.
- **Step A, no model.** Structured formats (837, ACORD XML, CSV) get a deterministic field mapper. It is exact, free and
  testable, and it covers most volume in practice.
- **Step B, model.** Only free text and scans the mapper cannot read go to a model. It returns the intake template plus a
  confidence per field:

```json
{
  "draft": {"policy_id": "POL-AUTO-2026-000001", "incident_date": "2026-09-14", "items": [{"coverage_id": "COV-AUTO-001", "amount": "1850.00"}]},
  "confidence": {"policy_id": 0.98, "incident_date": 0.62, "items[0].amount": 0.91},
  "evidence": {"incident_date": "…happened last Saturday…"}
}
```

- **Routing.** Any required field below a threshold, any validation error, or a policy id that does not exist goes to a
  human confirm queue with the quoted evidence. Only a confirmed draft enters the engine. Dates and amounts the model
  cannot ground in the source text are left empty, never guessed.
- **Plugs in at.** A new module in front of `intake.parse_and_validate`; `intake`, `draft` and the rules do not change.

### 2. Adjuster summaries

- A short narrative of each decision (what was claimed, what fired, what is needed next).
- The input is the rule trace, so the model never sees a reason it could invent. A post-check rejects any summary that
  names a rule id, amount or date not present in the trace.

### 3. Document triage

- Classify an uploaded file as one of the document types the claim type requires, and flag a likely rejection (wrong
  type, unreadable, wrong claim) before R-DOC-01 runs.
- The R-DOC-01 check itself stays a rule. Triage only changes what is recorded as received or rejected, and a person
  can override it.

### 4. Similarity signals

- Embedding similarity between narratives to surface near-duplicates a date-and-policy match misses, and unusual
  phrasing for review.
- Output is a flag with a score that joins the existing fraud flags. It routes to `refer_review`. It never denies or pays.

### 5. Conversational layer (the response side)

Extraction is the model call going in. The matching call coming out is a chat assistant that explains the workflow in
plain language to the people who use it. Together they make the loop: a person writes in their own words, the model turns
that into a structured claim, the rules decide, and the model explains the result back in their own words.

- **Who talks to it.**
  - A *claimant or requester* asks "where is my claim?", "why was it denied?" or "what do I still need to send?".
  - An *adjuster or approver* asks "why is this under review?" or "which claims have been waiting longest?".
  - An *operations analyst* asks "how many claims hit the limit this month?".
- **How it answers.** The assistant does not remember or guess. It calls read-only tools over data the engine already
  produces and writes the answer from what comes back:

| Tool (read-only) | Returns | Source today |
|---|---|---|
| `get_claim_status(claim_id)` | current status and the append-only history | `claim_status_history` |
| `get_decision(claim_id)` | decision, rule id, reason code | `assessment` table |
| `get_missing_documents(claim_id)` | the document types still required | `assessment.missing_doc_types` |
| `what_would_make_it_payable(claim_id)` | plain-language list of what would make a stopped claim payable | `counterfactual` in [view_trace.py](../src/claimsgen/view_trace.py) |
| `get_metrics(filter)` | counts, rates, cycle times | [metrics.py](../src/claimsgen/metrics.py) |

- **Example.** "Why was my claim denied?" The tool returns `R-COV-02`, reason `policy_not_in_force`, cancelled on
  2026-03-01, incident on 2026-04-12. The reply: "Your policy was cancelled on 1 March 2026, and the incident happened on
  12 April 2026, so this claim isn't covered under the policy. If you believe the cancellation date is wrong, I can send
  this to an adjuster to review." The reply states the rule's result in plain words and offers a human next step.
- **What it must not do.**
  - Decide or change anything. Tools are read-only, and there is no tool to approve, deny, pay or edit.
  - Promise a payout, an amount or a date the engine has not produced.
  - Answer from memory. If a tool returns nothing, it says it cannot find the claim and offers a person.
  - Show one customer another customer's claim. The tool layer enforces the caller's access, not the prompt.
- **Check on the answer.** Before a reply is sent, a post-check compares every claim id, rule id, date and amount in it
  with the tool results and blocks the reply if any value does not appear there. Anything the assistant cannot ground, or
  any complaint, legal threat or distress, is handed to a person with the conversation attached.
- **How it is scored.** Generate questions from known claims (their true answers come from the engine and the answer key),
  then measure whether each reply is correct, grounded, and routed to a person when it should be. A reply that states an
  untrue fact or promises an unauthorised outcome fails the gate.
- **Plugs in at.** A new module beside the view. It calls the same functions the view already uses, and the engine does
  not change.

## Guardrails common to all five

- **Closed contract.** The model fills a schema that already exists; free-form output is never executed.
- **Rules keep the final say.** No decision, reserve or settlement is written from model output.
- **Versioned and logged.** Model name, prompt version and input hash are stored with every extraction, so a decision can
  be replayed and explained later.
- **Degrades safely.** If the model is down or slow, intake falls back to the structured form and the manual queue.
  Nothing stops.
- **Privacy.** A local model on the claim text, so personal data does not leave the machine; redact before any hosted call.
- **Prompt injection.** Claim text is data. It is passed as quoted content, the output is schema-validated, and nothing
  in it can change a rule, a threshold or an approver.

## How we would measure it before trusting it

We already have what most teams lack: an answer key.

1. **Render narratives from known claims.** Turn generated claims (their true fields are in the tables) into emails and
   notes with controlled noise: relative dates, typos, amounts in words, missing fields, two incidents in one message.
2. **Field-level scoring.** Accuracy, and the confidence-versus-correctness curve, per field. The confidence threshold is
   chosen from this curve, not guessed.
3. **End-to-end agreement.** Run the extracted draft through the engine and compare the decision with the decision on the
   true structured claim. Report agreement by edge case (duplicate, over limit, missing document).
4. **Ship gate.** A hard number: for example, no confirmed-and-wrong field reaching the engine, and decision agreement
   at or above a target on the edge cases, before the layer is switched on.
5. **Drift.** Re-run the same suite when the model or prompt changes. Log results next to the prompt version.

## Rollout order

| Phase | Adds | Needs |
|---|---|---|
| 0 (today) | Deterministic engine, answer key, AI-authored test claims via paste | Done |
| 1 | Deterministic mappers for structured formats | No model |
| 2 | Narrative generator + extraction scoring harness, extractor behind a flag, shadow mode (runs, never used) | Local model |
| 3 | Human-confirmed extraction in the Submit tab | Phase 2 gate passed |
| 4 | Summaries, document triage, similarity flags | Each with its own post-check and score |
| 5 | Chat assistant over read-only tools, adjuster-facing first, claimant-facing after | Grounding post-check and a question set scored against the engine |

## What we would refuse to do

- Let a model approve, deny, price or cap a claim.
- Generate the synthetic dataset or its labels with a model. It would break reproducibility and make the answer key
  untrustworthy.
- Trust model confidence without calibrating it on our own data.

## Why it is not built here

The brief asks for a claims workflow and a reproducible, scored test bed. The generated data has no narratives or
documents for a model to read, so a model behind the form would have nothing real to do, and it would add a secret, a
cost and non-repeatable behaviour to a repo whose headline claim is byte-identical rebuilds. The design above is what we
would build next, in the order above, with the measurement harness first.
