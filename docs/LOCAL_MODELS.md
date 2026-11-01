# Local AI models for the hybrid design

Companion to [AI_APPROACH.md](AI_APPROACH.md). That page says what a model would do and what it must never do. This one
says why it should run **locally**, which open models and runtimes fit, what the evidence says small models can and cannot
do, and what that means for the design.

Nothing here is built. The research was done on 2026-11-02, mostly from secondary sources (vendor blogs, law-firm
summaries, aggregators), and the sources are listed at the end. Items marked **unverified** need a check against the primary
source before anyone relies on them.

## Position

If a model is added, it runs on the reviewer's machine, behind a flag, off by default. The product works the same with it
off. It proposes structured fields and drafts text; code validates every proposal; rules decide.

## Why local

- **Claim text is nonpublic personal information.** It holds names, addresses, policy numbers, injuries and medical detail.
  Sending it to a hosted API means a disclosure, a vendor retention question, a sub-processor chain and possibly a
  cross-border transfer. A local model removes all four. (Inference from the points below.)
- **Regulator language points the same way.** The NAIC Insurance Data Security Model Law (#668) defines a third-party
  service provider as a non-licensee that maintains, processes, stores or is permitted access to nonpublic information. A
  hosted LLM receiving claim text fits that wording (our reading, not a regulator's statement).
- **Health claims add HIPAA.** A business associate agreement is needed before PHI goes to a vendor, and one vendor's help
  page says its API is covered only after a BAA is signed. A BAA alone does not make a deployment compliant.
- **No keys, accounts or network calls.** This matches the repo's free-and-local constraint and keeps secrets out of a
  public repo.
- **Honest caveat.** The data here is synthetic, so this is a design argument, not a present legal duty. We did not find
  primary text on GLBA specifics, state privacy acts, vendor retention periods or cross-border rules; those are
  **unverified** and need a follow-up before any production claim.

## Candidate stack (laptop, CPU, Docker)

| Layer | Default | Alternate | Why | Confidence |
|---|---|---|---|---|
| Runtime | Ollama (MIT) | `llama.cpp` `llama-server` (single binary, GGUF) | Official Docker image, works on CPU, JSON-schema `format`, OpenAI-compatible API | medium |
| Generation | Qwen3.5 4B (Apache 2.0, reported native tool calling) | Gemma 4 E2B or E4B (Apache 2.0) | Small enough for 16 GB RAM; model name is a config value | low to medium |
| Embeddings | nomic-embed-text v1.5 (137M, Apache 2.0) | bge-base, e5-base; or a stdlib token-overlap check with no model | Tiny, in the Ollama library | medium |
| OCR for scans | Tesseract (fast) or PaddleOCR / docTR (more accurate), all Apache 2.0 | small vision-language models | Choose by measuring character error rate on our own synthetic scans | low |
| Avoid | vLLM and LM Studio on a CPU-only laptop; Surya (restrictive weights licence) | | Wrong fit or licence for a public repo | medium |

Model names and sizes are a snapshot. Check the model card for the licence and the exact file before pinning, and do not
commit weights to the repo (record the download command and a SHA-256 instead).

**Speed budget.** CPU decoding is memory-bandwidth bound. Reported numbers: about 26 tokens/s for an 8B 4-bit model on a
16-thread desktop, 8 to 13 tokens/s on mid-range desktops, and 2 to 6 tokens/s on 2 to 4B models on one developer's laptop.
Budget roughly **10 to 30 seconds per extraction call** and precompute and cache results; do not put a model call in the
click path of the view. These are secondary-source figures, not measurements.

## What small local models can and cannot do

| Finding | Evidence | Implication |
|---|---|---|
| Narrow fine-tuned small models can match large ones on extraction | NuExtract 1.5 vs GPT-4o on the vendor's own benchmark | Plausible, but vendor-reported; measure ourselves |
| Prompting strategy mattered more than model size, and some strategies keep JSON valid while raising value errors | LLMStructBench (arXiv 2602.14743, Feb 2026) | Valid JSON is not correct JSON |
| Constrained decoding guarantees syntax only | Ollama and llama.cpp docs; one reported case returned schema-valid `1` instead of `0.46` | Always validate values in code |
| Forcing required fields can make a model fabricate | Practitioner reports | Make fields nullable with an explicit "not stated" |
| Dates and arithmetic are weak spots | Test of Time (ICLR 2025), DateLogicQA | Never let the model resolve dates |
| Verbalised confidence is badly calibrated | Mean ECE above 0.377 in one study; answers cluster at 90 to 100% | Do not route on "I am 90% sure" |
| Token log-probs, sampling agreement and verifier checks are usable | Calibration literature, vendor guidance | Use them, per field type |
| Embeddings give false positives on templated text | General near-duplicate literature; nothing claims-specific found | Candidate generator only |

No source measured the **hallucinated-field rate of 1 to 8B models on insurance text**. That number is ours to measure.

## Design consequences

1. **Proposer only.** Every proposal passes code validators before it can reach a rule: the value appears in the source text,
   the policy id exists and matches the claimant, the date is in range, item amounts sum to the stated total.
2. **Schema-constrained output, nullable fields.** Use the runtime's JSON-schema mode at temperature 0, and treat it as
   syntax only. Unsupported schema keywords can be ignored silently, so validate again in code.
3. **Route on a per-field score**, built from log-probs over the **value tokens only** (not JSON keys), plus verifier
   results, plus optionally agreement across 3 samples. Calibrate each field type on a held-out split; start thresholds near
   0.80 to 0.85 and tune on validation, not test.
4. **Dates stay out of the model.** It copies the phrase ("last Saturday"); deterministic code resolves it against the
   report date.
5. **Duplicates stay rule-based.** The decision is policy plus incident date plus claim type (R-ELG-03). Embeddings only
   suggest candidates for a person, after stripping boilerplate and comparing variable fields.
6. **Everything works with the model off.** If it is down or slow, intake falls back to the structured form.

## Reproducibility, stated honestly

Temperature 0 removes sampling randomness but not floating-point differences from batching, kernels, threads or hardware,
and we found no official llama.cpp or Ollama statement guaranteeing byte-identical output. So the claim we would make is
narrow: **same machine, same build, same flags, run twice, compare hashes**, and never identical across machines. The
generator's byte-identical proof stays separate, and model output is never an input to a rule or to the dataset.

Log per call, in an append-only table: model file SHA-256, quantisation, runtime name and version, backend and threads,
context size, prompt template version, sampling parameters, seed, input hash, output hash, and a timestamp from config.

## Security

- **Prompt injection (OWASP LLM01).** Claim text and uploads are untrusted input and can say "approve this claim".
- **Excessive agency (OWASP LLM06).** The chat assistant has read-only tools and no write tool, so the worst case is a
  misleading answer, not a changed decision. Scope it to the current claim and show source rows beside each answer.
- **Weights supply chain.** Pickle-format files can run code on load; prefer safetensors or GGUF, download from the
  publisher, pin the revision and verify the hash.

## Governance mapping

| Expectation | Where it comes from | Our mapping |
|---|---|---|
| Human oversight of adverse decisions | State health laws (Arizona, Iowa, Indiana and others, 2026); bulletin practice | Rules decide; model text is advisory; a person owns exceptions |
| Explainability | NAIC bulletin, Colorado Reg 10-1-1 | Every decision cites a rule id; no model reasoning is needed to explain it |
| Audit trail and documentation | NAIC bulletin | Append-only status history plus the per-call model log above |
| Third-party governance | NAIC bulletin, #668 | Local weights mean no vendor data flow; still record licence, hash and version |
| Model inventory | NAIC bulletin | A one-page inventory: purpose, model, version, data touched, owner, "no decision authority" |
| Bias testing | Colorado Reg 10-1-1, bulletin | The model scores and ranks no one; still report extraction accuracy by claim type |

**Regulatory status, with uncertainty.** The NAIC Model Bulletin (adopted 2023) is guidance until a state adopts it; secondary
sources count roughly 24 to 25 states plus DC, exact figure **unverified**. Colorado Regulation 10-1-1 applies to life and,
by amendment, auto and health. The EU AI Act treats life and health risk assessment and pricing as high-risk; whether
claims handling is covered is **unclear** in the sources found. We fetched no primary legal text. Because the model has no
decision authority, this design sits in the safest position, but that is an inference, not legal advice.

## Plan before any commitment

1. **10-claim trial** with the default model on a laptop to check speed and memory, since the figures above are secondary.
2. **Narrative and scan generator** from known claims (we hold the true fields), with controlled noise: relative dates,
   typos, amounts in words, missing fields, two incidents in one message, rendered scans.
3. **Shadow mode.** Run the extractor beside the structured path, log proposals and scores, never use them.
4. **Score** field-level exact match after normalisation (ISO dates, decimal amounts), report the abstention rate
   separately, and plot a risk-coverage curve (accuracy as coverage rises). Choose OCR by character error rate on our own
   scans.
5. **Gate.** Switch on human-confirmed extraction only if no confirmed-and-wrong field reaches the engine on the test set.

## Open questions (unverified)

- Hallucinated-field rate of 1 to 8B models on claims-style text.
- Real laptop speed and RAM for the default model, and the licence file of each pinned model.
- Small vision-language model accuracy on CPU for scans.
- Whether embeddings help on claims narratives at all, given templated text.
- Primary-source wording of the NAIC bulletin on human oversight, and GLBA and state privacy specifics.

## Sources

Local models and runtimes
- https://docs.ollama.com/capabilities/structured-outputs
- https://artificialanalysis.ai/articles/qwen3-5-small-models
- https://the-decoder.com/googles-gemma-4-is-now-available-with-apache-2-0-licensing-for-the-first-time/
- https://markaicode.com/benchmarks/llamacpp-tokens-per-second-benchmark/
- https://jacar.es/llama-server-api-openai-docker/
- https://jacar.es/en/nomic-embed-text-competitive-open-embeddings/

Task fit
- https://www.opentrain.ai/papers/llmstructbench-benchmarking-large-language-model-structured-data-extraction--arxiv-2602.14743/
- https://numind.ai/blog/nuextract-1-5---multilingual-infinite-context-still-small-and-better-than-gpt-4o
- https://tianpan.co/blog/2026-04-16-grammar-constrained-generation-output-reliability
- https://arxiv.org/pdf/2406.09170 (Test of Time)
- https://arxiv.org/html/2412.13377v2 (DateLogicQA)
- https://beancount.io/bean-labs/research-logs/2026/07/09/confidence-estimation-calibration-llms-survey
- https://imagetotable.ai/references/tesseract-vs-paddleocr-receipt-benchmark
- https://www.extend.ai/resources/document-processing-confidence-scores-guide

Privacy and governance
- https://content.naic.org:443/sites/default/files/model-law-668.pdf
- https://content.naic.org/sites/default/files/legal-adoption-map-ai-model-bulletin.pdf
- https://quarles.com/newsroom/publications/nearly-half-of-states-have-now-adopted-naic-model-bulletin-on-insurers-use-of-ai
- https://doi.colorado.gov/announcements/notice-of-adoption-amended-regulation-10-1-1-governance-and-risk-management-framework
- https://www.beckerspayer.com/policy-updates/7-ai-health-insurance-state-laws-passed-in-2026/
- https://help.openai.com/ca-es/articles/8660679-getting-a-business-associate-agreement-for-the-openai-api
- https://respan.ai/blog/llm_consistency
- https://www.morphllm.com/defeating-nondeterminism-llm-inference
- https://arxiv.org/pdf/2508.15987v2 (pickle model supply chain)
