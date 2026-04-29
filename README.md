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

---

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
  👉 [`ruby/03-structured-json-0.3.1/`](ruby/03-structured-json-0.3.1/)
  - Centralized all AI interactions behind a single boundary
  - Removed direct OpenAI calls from business logic
  - Prepared the system for reliability hardening

- **v0.4.0 – Reliability & Guardrails**  
  👉 [`ruby/04-reliability-guardrails/`](ruby/04-reliability-guardrails/)
  - Introduced explicit AI failure classification
  - Defined retry, latency, and cost boundaries
  - Designed safe fallback behavior to preserve workflow trust

- **v0.5.0 – Controlled Context & Semantic Reasoning**
  👉 [`ruby/05-controlled-context/`](ruby/05-controlled-context/)
  - Introduced explicit reasoning context without conversational memory
  - Enabled intent‑aware explanations (meaning / cause / next steps)
  - Added safe blocking, bounded follow‑ups, and intentional context reset
  - Established human‑like conversational behavior with strict safety guarantees

- **v0.6.0 – Knowledge Source Registration**
  👉 [`ruby/06-knowledge-registry/`](ruby/06-knowledge-registry/)
  - Introduced explicit registration of authoritative knowledge sources
  - Made knowledge existence, scope, authority, and version auditable
  - Separated knowledge definition from reasoning and retrieval
  - Established governance foundation for controlled knowledge grounding
  - Preserved all v0.5.0 reasoning behavior with zero response changes

- **v0.6.1 – Retrieval Legitimacy & Discipline**
  👉 [`ruby/06-knowledge-grounding/`](ruby/06-knowledge-grounding/)
  - Introduced an explicit eligibility gate to decide when documentation may be consulted
  - Enforced intent‑aware and authority‑aware permission checks for knowledge usage
  - Made documentation access an explicit ALLOW / DENY decision with auditable reasons
  - Clearly separated knowledge existence (v0.6.0) from knowledge execution (v0.7.0)
  - Preserved all existing reasoning and response behavior with zero runtime changes

- **v0.7.0 – Knowledge Execution Skeleton**
  👉 [`ruby/06-knowledge-grounding/adapter/`](ruby/06-knowledge-grounding/adapter/)
  - Introduced an explicit execution boundary for knowledge usage
  - Defined a stable document adapter contract
  - Added deterministic execution failure handling (`NOT_DEFINED`)
  - Confirmed safe execution routing after eligibility approval
  - Preserved all v0.6.x reasoning and governance guarantees

- **v0.7.1 – Source Pointer Resolution**
  👉 [`ruby/06-knowledge-grounding/adapter/`](ruby/06-knowledge-grounding/adapter/)
  - Introduced deterministic resolution of document source pointers
  - Validated knowledge source existence at runtime
  - Made infrastructure availability an explicit execution step
  - Preserved safe failure semantics (`NOT_DEFINED`)
  - Maintained strict separation from document parsing and grounding logic

- **v0.7.2 – Section Identification**
  👉 [`ruby/06-knowledge-grounding/adapter/`](ruby/06-knowledge-grounding/adapter/)
  - Introduced deterministic section‑level grounding within authoritative documents
  - Converted PDF documents into plain text safely at execution time
  - Identified *where* authoritative knowledge lives using structural headers (e.g. DEFINITIONS)
  - Established explicit section boundaries before any semantic interpretation
  - Preserved safe failure semantics (`NOT_DEFINED`) when structure is absent

- **v0.7.3 – Term‑Level Grounding**
  👉 [`ruby/06-knowledge-grounding/adapter/`](ruby/06-knowledge-grounding/adapter/)
  - Introduced explicit term‑level grounding within validated document sections
  - Required semantic intent (`term`) to be passed explicitly through execution
  - Extracted exact, authoritative definitions using structural term headers
  - Enforced strict document vocabulary (no synonym or fuzzy matching)
  - Preserved safe failure semantics (`NOT_DEFINED`) when terms are not defined
  
- **v0.8.0 – Intent Mediation**
    👉 [`ruby/07-intent-mediation/`](ruby/07-intent-mediation/)
  -   Introduced an explicit intent‑mediation layer prior to knowledge grounding
  -   Normalized human phrasing into canonical, document‑compatible terminology
  -   Added deterministic alias resolution with punctuation and Unicode normalization
  -   Separated user‑meaning interpretation from document truth extraction
  -   Preserved all v0.7.x grounding behavior with zero changes to grounded responses

- **v0.9.0 – Guided Status & Error Explanations**
    👉 [`ruby/08-guided-explanations/`](ruby/08-guided-explanations/)
  -  Introduced a **post‑grounding explanation layer** for statuses and errors
  -  Transformed grounded terms into **structured, human‑readable explanations**
  -  Added a formal **Explanation Contract** for consistent interpretation
  -  Implemented explicit explanation templates for:
      -  Mapping Errors
      -  Blocking Reconciliation States
      -  Terminal Reconciliation States
  -  Enforced a strict **analyzer‑only intent scope** (interpretation, not operation)
  -  Explicitly refused workflow execution, UI guidance, diagnosis, or automation
  -  Preserved all v0.7.x grounding and v0.8.x intent mediation behavior unchanged
  -  Produced stable, auditable outputs suitable for downstream UI usage

-  **v0.10.0 – Contextual Follow‑Ups**
    👉 [`ruby/09-contextual-reuse/templates`](ruby/09-contextual-reuse/templates/)
    -  Introduced a **read‑only contextual reuse layer** activated only after an authoritative explanation
    -  Enabled **follow‑up questions** to be answered by **projecting fields** from an existing `ExplanationContract`
    -  Added a **Follow‑Up Classifier** for projection‑safe intents  
        (blocking, ownership, completion, impact)
    -  Implemented a **Projection Resolver** producing short, deterministic, analyst‑safe responses
    -  Extended explanation coverage to **transitional lifecycle states** (`NEW`, `READY`, `PROCESSING`, `PARSED`)
    -  Explicitly enforced **projection‑only semantics** with no inference or sequencing
    -  Preserved all v0.7 grounding, v0.8 intent mediation, and v0.9 explanation behavior unchanged
    -  Explicitly refused workflow guidance, lifecycle ordering, or operational instructions

- **v0.11.0 – Lifecycle Sequencing**
    👉 [`ruby/09-contextual-reuse/lifecycle/`](ruby/09-contextual-reuse/lifecycle/)
    - Introduced a **read‑only lifecycle sequencing layer** for reconciliation states
    - Enabled deterministic answers to **state‑ordering questions** (e.g. *“What comes after PARSED?”*)
    - Centralized canonical lifecycle ordering in a **reference‑only lifecycle map**
    - Added a dedicated **Lifecycle Resolver** separate from explanation and projection
    - Explicitly classified lifecycle sequencing as **relationship semantics**, not projection
    - Preserved all v0.7.x grounding, v0.8.x intent mediation, v0.9.x explanations, and v0.10.x follow‑ups unchanged
    - Explicitly refused workflow guidance, transition authority, readiness, or execution

