# AI Engineering Journey

This repository tracks my incremental transition from traditional software engineering
to AI engineering through hands-on experiments and system-level implementations.

The focus is on:
- integrating AI models into real systems
- treating LLMs as external services
- building incrementally with engineering discipline
- documenting decisions and progress over time

---

## Structure

The repository evolves by **adding new stages**, not rewriting old ones.


## Milestones Overview

Each milestone lives in its own folder with a dedicated README describing
the intent, scope, and learnings of that stage.

- **v0.1.0 – LLM API Connectivity**  
  👉 [`ruby/01-openai-connect/`](ruby/01-openai-connect/)
  - Established basic OpenAI API integration
  - Treated the LLM as an external service
  - Introduced Docker-based reproducible execution

- **v0.2.0 – Interactive AI Console**  
  👉 [`ruby/02-interactive-console/`](ruby/02-interactive-console/)
  - Enabled conversational interaction with the AI
  - Explored reconciliation “why” questions
  - Observed hallucination and domain drift risks

- **v0.3.0 – Structured JSON Output**  
  👉 [`ruby/03-structured-json/`](ruby/03-structured-json/)
  - Introduced strict, deterministic JSON-only AI responses
  - Aligned explanations with reconciliation domain rules
  - Established stateless, rule-faithful behavior

- **v0.3.1 – AI Call Boundary**  
  👉 [`ruby/03-structured-json/`](ruby/03-structured-json-0.3.1/)
  - Centralized all AI interactions behind a single boundary
  - Removed direct OpenAI calls from business logic
  - Prepared the system for reliability hardening

- **v0.4.0 – Reliability & Guardrails**  
  👉 [`ruby/04-reliability-guardrails/`](ruby/04-reliability-guardrails/)
  - Introduced explicit AI failure classification
  - Defined retry, latency, and cost boundaries
  - Designed safe fallback behavior to preserve workflow trust