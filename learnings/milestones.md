# AI Engineering Learning Milestones

This document tracks learning goals and takeaways across each milestone.

---

## v0.1.0 — LLM API Connectivity

**Goal**
- Treat an LLM as an external service
- Set up a reproducible environment

**What Was Learned**
- Model APIs behave like unreliable dependencies
- Authentication and deployment matter more than prompts
- Docker-first setup eliminates local friction

---

## v0.2.0 — Interactive AI Console

**Goal**
- Enable conversational interaction with AI
- Explore reconciliation-related "why" questions

**What Was Learned**
- Users ask vague and ambiguous questions
- AI tends to over-explain unless constrained
- Prompt boundaries are as important as prompts themselves


## v0.2.0 – Observation

The model initially provided generic reconciliation explanations
(e.g., approvals, unresolved discrepancies).

This revealed the need for:
- stricter domain vocabulary constraints
- explicit exclusion of non-existent workflows
- earlier focus on tenancy-specific semantics

Prompt boundary tightening significantly improved alignment.

---

## v0.3.0 — Structured, Rule‑Faithful Explanations (JSON)

### What We Expected
- JSON output would improve consistency and enable validation.
- Behavior would remain similar to v0.2.0 but more structured.

### What Actually Happened
- The AI sometimes refused with `INSUFFICIENT_CONTEXT` for the same input.
- This appeared inconsistent but was rule‑consistent behavior.

### Concrete Example
- Input: "What does PARTIALLY RECONCILED mean?"
- Output alternated between valid JSON and refusal.
- This occurred only when assistant responses were reused as memory.

### What We Learned
- The model does not treat its own outputs as ground truth.
- Conversational memory conflicts with strict output contracts.
- Refusal is safer than guessing under strong constraints.
- Structure exposes uncertainty that free text hides.

### Mental Model Update
- v0.2.0: AI as a conversational assistant.
- v0.3.0: AI as a deterministic system component.
- Deterministic components must be stateless to remain reliable.

---


## v0.4.0 — Reliability & Guardrails

**Goal**
- Make AI behavior predictable under failure
- Prevent AI from blocking or destabilizing operational workflows

**What We Learned**
- Correctness alone is insufficient for production AI
- AI failures must be classified, not treated uniformly
- Retries are business decisions, not technical defaults
- Latency and cost are architectural concerns
- Safe failure preserves more trust than partial success

**Mental Model Update**
- v0.3.x: “AI answers must be correct”
- v0.4.0: “AI behavior must be predictable under stress”

---

## **v0.5.0 — Controlled Context & Semantic Reasoning (Phase 2)**

### **Goal**

*   Make AI explanations feel **human‑like without unsafe memory**
*   Enable **safe conversational continuity**
*   Prevent hallucination by design
*   Establish cognitive discipline before adding knowledge (RAG, DB access)

***

### **What We Expected**

*   Limited follow‑up questions could feel more natural
*   Explicit context handling might reduce repetition
*   Conversational behavior could be improved incrementally

***

### **What Actually Happened**

*   Human‑like behavior did **not** depend on memory or model intelligence
*   Most conversation issues were semantic, not linguistic
*   Unsafe behavior emerged whenever legitimacy, limits, or forgetting were missing
*   Explicit “don’t answer” paths increased user trust
*   Bounded reasoning felt *more* human than unlimited reasoning

***

### **What We Learned**

*   **Human‑like AI is driven by semantic discipline, not memory**
*   Intent awareness (meaning vs cause vs action) removes over‑explanation naturally
*   Conversational memory without semantic control amplifies hallucination
*   Blocking with explanation is better than partial answers
*   Reasoning must be explicitly bounded to avoid cognitive loops
*   Forgetting must be intentional and lifecycle‑driven
*   Stateless execution with semantic control is safer than stateful replay
*   Domain handbooks are essential for defining legitimate reasoning boundaries

***

### **Key Semantic Capabilities Established**

*   Explicit reasoning state via structured context
*   Intent‑aware explanation modes
*   Separation of system facts vs AI interpretation
*   Progressive disclosure of information
*   Failure‑safe continuation with responsibility attribution
*   Bounded short‑term continuity
*   Intentional forgetting and session lifecycle control

These semantics collectively enabled **continuous yet safe conversation**.

***

### **Mental Model Update**

*   **v0.4.0:** “AI must behave predictably under operational stress”
*   **v0.5.0:** “AI must reason like a trained analyst, with clear limits”

Instead of asking:

> *Can the AI answer this?*

The system now asks:

> *Should the AI answer this, how far should it go, and when should it stop or reset?*

***

### **Outcome**

After v0.5.0, the AI Analyst Assistant:

*   reasons transparently
*   explains constraints clearly
*   supports bounded follow‑ups
*   avoids hallucination by design
*   resets context predictably
*   is ready for safe knowledge grounding

***

## **v0.6.0 — Knowledge Source Registration (Phase 3)**

### **Goal**

*   Make **knowledge explicit and governed**
*   Remove implicit assumptions about documentation
*   Prepare for safe knowledge grounding (RAG) without changing behavior

***

### **What We Learned**

*   Knowledge must be **declared before it can be used**
*   Document existence, authority, and scope matter more than content
*   Not every question should consult documentation
*   Explicit governance simplifies future retrieval decisions
*   Zero‑behavior‑change milestones can be structurally critical

***

### **Key Capability Added**

*   Central **Knowledge Registry**
*   Knowledge sources modeled as metadata only:
    *   authority
    *   domain
    *   version
    *   stable source pointer
*   Read‑only, explanation‑only usage guarantee

(No retrieval, no RAG, no response changes.)

***

### **Mental Model Update**

*   **v0.5.0:** How the AI reasons
*   **v0.6.0:** What knowledge exists

Instead of guessing:

> “Should the AI look this up?”

The system now knows:

> “Does authoritative knowledge even exist for this?”

***

### **Outcome**

After v0.6.0, the AI Analyst Assistant:

*   preserves all Phase 2 reasoning guarantees
*   has explicit awareness of authoritative documentation
*   avoids implicit or assumed knowledge
*   is ready for retrieval discipline in v0.6.1

✅ **Status:** Locked
➡️ **Next:** v0.6.1 — Retrieval Legitimacy & Discipline

***

Perfect — thanks for sharing the **v0.6.0 milestone “log” section**.  
I understand exactly what you want now:

✅ You want an **equivalent, disciplined “closure section” for v0.6.1**,  
✅ written in the **same tone, structure, and maturity**,  
✅ suitable to **lock the milestone officially**,  
✅ and ready to drop into the README or changelog without further debate.

Below is the **v0.6.1 counterpart**, aligned line‑by‑line with the v0.6.0 style you posted.

***

## **v0.6.1 — Retrieval Legitimacy & Discipline (Phase 3)**

### **Goal**

*   Introduce **explicit discipline around knowledge usage**
*   Prevent unsafe or implicit document consultation
*   Decide **when documentation is allowed**, without executing retrieval
*   Prepare the system for grounded explanations without changing AI behavior

***

### **What We Learned**

*   Knowledge presence alone is **not sufficient** to consult documentation
*   Every retrieval must be **explicitly justified**
*   Intent must be **normalized and evaluated**, not assumed
*   Authority and coverage checks prevent accidental misuse of documents
*   Safe AI systems must distinguish **permission** from **execution**
*   Correct behavior sometimes means returning **NOT\_DEFINED**

***

### **Key Capability Added**

*   **Knowledge Eligibility Gate** with deterministic outcomes
*   Explicit **intent normalization** between conversational semantics and governance semantics
*   Auditable **ALLOW / DENY** decisions with clear reasons
*   Authority sufficiency and coverage validation
*   Runtime enforcement of documentation discipline

(No document access, no PDF parsing, no RAG execution.)

***

### **Mental Model Update**

*   **v0.5.0:** How the AI reasons
*   **v0.6.0:** What knowledge exists
*   **v0.6.1:** **When knowledge may be used**

Instead of the system guessing:

> “Should I look this up?”

The system now decides deliberately:

> “Am I allowed to consult documentation at all?”

***

### **Outcome**

After v0.6.1, the AI Analyst Assistant:

*   makes **explicit, auditable decisions** about documentation usage
*   prevents opportunistic or accidental RAG behavior
*   preserves all Phase 2 reasoning guarantees
*   returns safe, honest responses when documentation is unavailable
*   cleanly separates **permission** from **execution**
*   establishes a stable boundary for grounded explanations in v0.7.x

✅ **Status:** Locked  
➡️ **Next:** v0.7.0 — Grounded Explanations & Document Adapter

***

## **v0.7.0 — Knowledge Execution Skeleton (Phase 3)**

### **Goal**

*   Introduce a concrete execution boundary for knowledge usage
*   Prove that document grounding can be attempted safely
*   Preserve all prior reasoning and eligibility guarantees

***

### **What We Learned**

*   Execution must be separated from permission
*   Safe systems must fail explicitly before succeeding accurately
*   Returning `NOT_DEFINED` is a successful execution outcome
*   Execution plumbing should be validated before document logic is added

***

### **Key Capability Added**

*   Stable **DocumentAdapter** execution contract
*   Concrete **PdfDocumentAdapter** execution strategy (stub)
*   Grounded execution routing after eligibility approval
*   Deterministic execution failure semantics (`nil → NOT_DEFINED`)

(No document access, no file parsing, no grounding logic.)

***

### **Mental Model Update**

*   **v0.6.1:** When knowledge may be used  
*   **v0.7.0:** **How knowledge execution is attempted**

Instead of imagining execution:

> “We could read a document here…”

The system now executes concretely:

> “Attempt execution; fail safely if nothing is defined.”

***

### **Outcome**

After v0.7.0, the AI Analyst Assistant:

*   has a real, testable knowledge execution path
*   attempts document grounding only after explicit approval
*   returns honest, non‑hallucinated outcomes when content is absent
*   preserves trust and auditability across execution failures
*   is ready for incremental execution enhancements in v0.7.1+

✅ **Status:** Locked  
➡️ **Next:** v0.7.1 — Source Pointer Resolution

***

## **v0.7.1 — Source Pointer Resolution (Phase 3)**

### **Goal**

*   Validate that approved knowledge sources exist at runtime
*   Make document availability an explicit execution concern
*   Preserve safe execution semantics established in v0.7.0

***

### **What We Learned**

*   Runtime availability is distinct from logical permission
*   Containers expose filesystem assumptions that must be validated
*   Missing documents are a normal, expected execution outcome
*   Infrastructure failures must surface before parsing begins

***

### **Key Capability Added**

*   Deterministic resolution of document source pointers
*   Explicit file existence validation during execution
*   Clear distinction between:
    *   document missing
    *   document present but content not defined
*   Continued support for safe failure (`nil → NOT_DEFINED`)

(No document parsing, no section detection, no grounding logic.)

***

### **Mental Model Update**

*   **v0.7.0:** How execution is attempted  
*   **v0.7.1:** **Whether the document exists at runtime**

Instead of assuming infrastructure:

> “The document should be there…”

The system now verifies explicitly:

> “The document is present and reachable before proceeding.”

***

### **Outcome**

After v0.7.1, the AI Analyst Assistant:

*   validates knowledge source availability at runtime
*   distinguishes infrastructure failures from content gaps
*   preserves honest, non‑hallucinatory behavior
*   maintains strict separation between execution and interpretation
*   is ready for deterministic document parsing in v0.7.2

✅ **Status:** Locked  
➡️ **Next:** v0.7.2 — Section Identification

***

## **v0.7.2 — Section Identification (Phase 3)**

### **Goal**

* Introduce deterministic **section‑level grounding** within authoritative documents
* Identify *where* authoritative knowledge lives before extracting meaning
* Prepare the system for precise, term‑level grounding
* Preserve execution safety and trust guarantees from earlier milestones

***

### **What We Added**

* Deterministic **PDF → text conversion** using system tooling
* Structural extraction of declared document sections (e.g. `DEFINITIONS`)
* Explicit section boundary detection based on human‑authored headers
* Safe propagation of section content as an intermediate execution artifact

(No semantic interpretation or term matching at this stage.)

***

### **What We Learned**

* Authoritative documents encode intent through **structure**, not keywords
* Extracting meaning without first anchoring structure leads to ambiguity
* PDF text extraction produces noisy but **deterministic** artifacts that must be handled cautiously
* Large section payloads are acceptable as intermediate results
* Structural failures must surface explicitly, not be guessed around

***

### **Key Capability Added**

* **Section‑Level Grounding**
  - Locate a requested section using explicit header patterns
  - Extract only the content bounded by structural markers
  - Refuse to interpret or summarize section content

This establishes a stable execution boundary between:
* document presence (v0.7.1)
* semantic grounding (v0.7.3)

***

### **Failure Semantics (By Design)**

* If the document exists but the requested section does not:
  → return `NOT_DEFINED`
* No keyword search, fuzzy matching, or heuristic fallback is attempted
* Absence of structure is treated as absence of authority

***

### **Mental Model Update**

* **v0.7.1:** *Is the document available?*  
* **v0.7.2:** **Where inside the document is authoritative knowledge?**

Instead of:

> “Search the document for something relevant…”

The system now guarantees:

> “This entire section is the authoritative scope for this question.”

***

### **Outcome**

After v0.7.2, the AI Analyst Assistant:

* Can deterministically locate authoritative sections within documents
* Produces large but reliable intermediate grounding artifacts
* Avoids premature semantic interpretation
* Establishes the structural foundation required for precise term extraction
* Enables safe, auditable progression to v0.7.3

✅ **Status:** Complete  
➡️ **Next:** v0.7.3 — Term‑Level Grounding

***

## **v0.7.3 — Term‑Level Grounding (Phase 3)**

### **Goal**

* Enable **precise, term‑level grounding** within authoritative documentation
* Bind user questions to **exact document‑defined concepts**
* Eliminate semantic inference and accidental coupling
* Complete Phase 3: Knowledge Execution & Grounding

***

### **What We Added**

* Explicit **term propagation** as a first‑class execution input
* Deterministic extraction of a **single authoritative definition**
* Structural matching of term headers within validated document sections
* LLM prompt constraint to explain **only what the document defines**

(No document searching, no synonym resolution, no interpretation.)

***

### **What We Learned**

* Structural grounding alone is insufficient without explicit semantic intent
* PDF‑derived text introduces noise that must be handled deterministically
* Reusing identifiers across semantic layers creates hidden failure modes
* Exact vocabulary enforcement improves trust, even when it reduces recall
* Human‑friendly behavior must be layered *after* truth is secured

***

### **Key Capability Added**

* **Term‑Level Definition Extraction**
  - Operates exclusively within validated sections (v0.7.2)
  - Matches declared term headers structurally (case‑insensitive, exact)
  - Extracts content until the next structural boundary
* **Explicit semantic contract**
  - `term` is mandatory and never inferred
  - Missing or mismatched terms yield `NOT_DEFINED`

***

### **Failure Semantics (By Design)**

* If a term is not explicitly defined in the document:
  → return `NOT_DEFINED`
* No fuzzy matching, correction, or aliasing is attempted
* Failures surface vocabulary gaps transparently

***

### **Mental Model Update**

* **v0.7.2:** *Where does authoritative knowledge live?*
* **v0.7.3:** **What exact concept is being defined?**

Instead of:

> “The document probably defines this.”

The system now guarantees:

> “This exact definition comes from this document, section, and term.”

***

### **Outcome**

After v0.7.3, the AI Analyst Assistant:

* Answers definition questions using only authoritative text
* Produces minimal, audit‑ready outputs
* Refuses to fabricate meaning when the document is silent
* Cleanly separates truth extraction from user experience concerns
* Completes Phase 3 with strong semantic guarantees

✅ **Status:** Locked  
➡️ **Next:** Phase 4 — Intent Mediation (v0.8)

***

## **v0.8.0 — Intent Mediation (Phase 4)**

### **Goal**

*   Enable **explicit interpretation of user intent** before grounding
*   Translate human phrasing into **canonical, grounding‑compatible intent**
*   Eliminate ambiguity caused by informal language, punctuation, and Unicode variance
*   Preserve the purity and safety guarantees of Phase 3 grounding

***

### **What We Added**

*   A dedicated **pre‑grounding intent mediation layer**
*   Explicit **intent contract** that separates *meaning* from *truth*
*   Deterministic canonicalization of:
    *   casing
    *   whitespace
    *   punctuation
    *   Unicode dash variants (`–`, `—`)
*   Explicit, auditable **alias → canonical term mappings**
*   Strict refusal when intent cannot be resolved safely

(No document access, no section routing, no workflow interpretation.)

***

### **What We Learned**

*   Users consistently ask *definition‑shaped questions* using non‑document vocabulary
*   Unicode punctuation and formatting differences break naive string matching
*   Canonicalization belongs **before grounding**, not inside it
*   Alias expansion must be explicit to remain auditable
*   Resolving *what the user means* is orthogonal to *what the document defines*
*   Errors and statuses are semantically “definitions” but not necessarily glossary entries

***

### **Key Capability Added**

*   **Intent Mediation Layer**
    *   Parses definition‑style questions (`What does X mean?`)
    *   Normalizes user input deterministically (punctuation, spacing, Unicode)
    *   Resolves aliases to canonical document terms
    *   Emits a single, structured intent object
*   **Explicit Intent Contract**
    *   Intent is produced only when resolution is unambiguous
    *   No defaults, inference, or fuzzy matching
    *   Ambiguity yields `NOT_DEFINED`
*   **Grounding Preservation**
    *   All grounding logic (v0.7.x) remains frozen
    *   Intent mediation never alters document truth or extraction rules

***

### **Failure Semantics (By Design)**

*   If intent cannot be resolved deterministically:
    → return `NOT_DEFINED`
*   If a canonical term exists but is not defined in the targeted section:
    → grounding returns `NOT_DEFINED`
*   No fallback across sections, no guessing, no silent corrections

***

### **Mental Model Update**

*   **v0.7.3:** *What exactly does the document say?*
*   **v0.8.0:** **What does the user mean, in document terms?**

Instead of:

> “Users must phrase questions exactly like the handbook.”

The system now guarantees:

> “User phrasing is normalized explicitly before grounding logic is invoked.”

***

### **Boundary Clarification**

*   v0.8.0 **does not decide where a concept is defined**
*   v0.8.0 **does not explain errors or workflows**
*   v0.8.0 **does not perform retrieval (RAG)**

These concerns are deliberately deferred to later phases.

***

✅ **Status:** Locked  
➡️ **Next:** v0.9.x — Guided Status & Error Explanations (Semantic Interpretation Layer)

***

### Why this milestone is *correctly scoped*

This milestone completes the separation between:

*   **Meaning resolution** (v0.8)
*   **Truth extraction** (v0.7)
*   **Explanation / action guidance** (v0.9+)

No safety guarantees were loosened, and no future capabilities were prematurely introduced.

***

