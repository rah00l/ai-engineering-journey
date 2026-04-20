# AI Engineering Decision Log

This document captures key system design and domain-driven decisions made during this AI engineering journey.

The goal is to record **why** certain approaches were chosen over others, especially when building AI systems for enterprise domains.

---

## Decision 001: AI as Explainer, Not Executor

**Context**
The reconciliation system already performs correct business logic through deterministic backend processes. However, accounting users struggle to understand the reasoning behind system outcomes.

**Decision**
The AI assistant will be designed as an *explainability layer only*.  
It will **not** modify data, execute reconciliation, or trigger workflows.

**Rationale**
- Financial systems require auditability and determinism.
- AI models are probabilistic and unsuitable for acting directly on accounting data.
- The highest value lies in translating system behavior into business-friendly explanations.

---

## Decision 002: Delay Database Access Until AI Is Grounded

**Context**
Explaining transaction-specific outcomes requires database context.

**Decision**
AI access to transactional data will be introduced only after:
- rule understanding is stable
- document grounding (RAG) is complete
- safe read-only APIs exist

**Rationale**
- Prevent hallucinations on financial data
- Avoid early over-coupling
- Preserve learning signal during early stages

## Decision 003: Introduce Conversational AI Without Data Access

We intentionally built an interactive console before adding document retrieval
or database context to understand AI conversational behavior and failure modes safely.

---

## Decision 004: Stateless Execution for Structured AI Components

### Context
- In v0.2.0, the AI was conversational.
- Previous assistant responses were passed as memory to support follow‑ups.
- Output was free text, and approximation was acceptable.

### Trigger (What Happened)
- In v0.3.0, strict JSON output contracts were introduced.
- When the same question was asked repeatedly, responses alternated:
  - Sometimes valid JSON
  - Sometimes `INSUFFICIENT_CONTEXT`

### Root Cause
- Previous assistant responses were fed back as conversation memory.
- The model re‑evaluated its own prior output under stricter rules.
- Under zero‑guessing constraints, the safest option became refusal.

### Decision Made
- Structured, contract‑based AI components must be stateless.
- Assistant outputs must not be reused as conversational memory.

### Why This Decision
- Conversational memory assumes trust in earlier AI output.
- Strict contracts require independent, zero‑trust evaluation.
- Stateless execution avoids feedback loops and instability.

### Forward Impact
- v0.3.0 and later decision components will be stateless.
- Memory will be reintroduced later in a controlled, data‑driven way
  (not conversational replay).
---

## **Decision 005: Introduce Explicit Semantic Context Instead of Conversational Memory**

### Context

Earlier versions explored conversational memory by replaying assistant outputs.
While useful for demos, this approach introduced instability under strict output contracts and made reasoning behavior unpredictable.

### Decision

The AI Analyst Assistant will **not use conversational replay or implicit memory**.
Instead, all conversational behavior will be governed by **explicit semantic context**, represented through structured models (e.g., `AnalysisContext`).

### Rationale

*   Conversational memory assumes correctness of past AI output.
*   Strict enterprise systems require **zero‑trust evaluation**.
*   Semantic context allows controlled continuity without trusting previous responses.
*   This mirrors how deterministic systems reason safely.

### Impact

*   Prevents hallucination amplification.
*   Enables bounded follow‑ups without persistence.
*   Forms the foundation for safe future memory (RAG, DB context).

***

## **Decision 006: Review Domain Handbook Before Encoding Semantic Rules**

### Context

As the system moved toward conversational continuity, understanding **domain‑specific semantics** became critical.
Generic reasoning patterns were insufficient without grounding in reconciliation workflows.

### Decision

Before finalizing v0.5.0 semantics, the **reconciliation domain handbook was explicitly reviewed** to:

*   enumerate valid workflows
*   identify unsafe reasoning paths
*   align semantics with real analyst behavior

### Rationale

*   Semantic rules must reflect **domain reality**, not generic AI intuition.
*   Human analysts reason within workflow boundaries.
*   Reviewing the handbook ensured semantic rules aligned with actual reconciliation practices.

### Impact

*   Prevented encoding non‑existent workflows.
*   Improved intent classification fidelity.
*   Ensured blocking rules matched real business constraints.

***

## **Decision 007: Divide v0.5.0 into Internal Phases (5.1–5.5)**

### Context

v0.5.0 introduced multiple cognitive capabilities.
Implementing them at once would reduce observability and increase design risk.

### Decision

The milestone was explicitly divided into **five internal phases**, each introducing **one semantic capability only**:

*   5.1 — Reasoning state
*   5.2 — Intent awareness
*   5.3 — Failure‑safe blocking & responsibility
*   5.4 — Bounded continuity
*   5.5 — Intentional forgetting & lifecycle

### Rationale

*   Human cognition develops incrementally.
*   Isolating phases preserves correctness at each step.
*   Simplifies debugging and validation.

### Impact

*   Each semantic rule can be validated independently.
*   Reduced coupling between reasoning, continuity, and lifecycle.
*   Clear audit trail of cognitive evolution.

***

## **Decision 008: Enforce Bounded Reasoning Instead of Open‑Ended Continuity**

### Context

Unbounded follow‑up reasoning leads to:

*   cognitive loops
*   speculative explanations
*   loss of analyst‑grade discipline

### Decision

Reasoning continuity must be **explicitly capped** via a reasoning budget.
Once exhausted, the system must block further reasoning and explain why.

### Rationale

*   Human analysts stop when inference limits are reached.
*   Infinite reasoning reduces trust.
*   Bounded reasoning is essential for auditability.

### Impact

*   Prevents runaway conversations.
*   Makes reasoning limits transparent to users.
*   Improves reliability under repeated follow‑ups.

***

## **Decision 009: Make Forgetting a First‑Class Capability**

### Context

Without explicit forgetting, semantic context can linger and corrupt new conversations.

### Decision

The system must **intentionally forget** reasoning context when:

*   a reasoning session completes
*   the reasoning budget is exhausted
*   a new topic is introduced
*   a terminal block occurs

### Rationale

*   Forgetting is a core feature of safe cognition.
*   Implicit decay is unpredictable and unsafe.
*   Explicit lifecycle control is inspectable and auditable.

### Impact

*   Prevents stale context bleed.
*   Provides clean conversation boundaries.
*   Makes the system predictable and trustworthy.

***

## **Decision 010: Complete Cognitive Discipline Before Adding Knowledge (RAG)**

### Context

It was tempting to introduce RAG or data access earlier.
However, uncontrolled reasoning amplifies hallucination when combined with knowledge.

### Decision

All semantic reasoning controls (Phases 5.1–5.5) must be completed **before** introducing:

*   document retrieval
*   database access
*   tool usage

### Rationale

*   Knowledge must sit on top of disciplined reasoning.
*   RAG without lifecycle, blocking, and limits is unsafe.
*   Semantic correctness precedes informational correctness.

### Impact

*   v0.5.0 cleanly separates *how to think* from *what to know*.
*   Makes Phase 6 safe by design.

***

#### Decision 011: Introduce Knowledge Governance Before Retrieval

**Context**  
As the system evolves toward knowledge grounding (RAG), we intentionally separated:

*   knowledge existence
*   knowledge access
*   knowledge usage

to avoid unsafe or ungoverned retrieval.

**Decision**  
We introduced a dedicated knowledge registry (v0.6.0) that:

*   explicitly declares authoritative knowledge sources
*   records domain, authority, and version
*   stores only metadata and stable pointers
*   does not retrieve or store document content

**Consequences**

*   RAG cannot be enabled without governance
*   Absence of documentation becomes an explicit, safe outcome
*   Future retrieval and grounding remain auditable and bounded


### **Decision 012: Treat “NOT\_DEFINED” as a Valid, First‑Class Outcome**

This decision captures a behavior you have already implemented and validated.

***

### **Decision 012: Explicitly Return NOT\_DEFINED When Documentation Is Allowed but Content Is Absent**

#### Context

Once knowledge eligibility is introduced (v0.6.1), situations arise where:

*   documentation access is **legitimate**
*   but the documentation **does not define the requested concept**

Without an explicit rule, systems often:

*   hallucinate
*   fall back to general knowledge
*   blur the boundary between authority and inference

#### Decision

When documentation access is allowed **but no authoritative content is found**, the system must:

*   explicitly return **NOT\_DEFINED**
*   avoid fallback to model knowledge
*   preserve trust by refusing to guess

#### Rationale

*   Absence of documentation is meaningful information
*   “I don’t know” is safer than incorrect authority
*   Explicit refusal maintains auditability and trust
*   This behavior allows execution (v0.7.x) to fail safely

#### Impact

*   v0.6.1 produces honest, predictable outcomes
*   v0.7.x execution is bounded and safe
*   The system distinguishes:
    *   *not allowed*
    *   *allowed but missing*
    *   *allowed and grounded*

***

### **Decision 013: Introduce an Explicit Knowledge Execution Boundary**

#### Context

After establishing knowledge governance (v0.6.0) and eligibility discipline (v0.6.1),
we needed a concrete way to **execute approved knowledge access** safely.

Without an explicit execution boundary, document grounding would:
- blur decision and execution responsibilities
- make failure modes ambiguous
- risk accidental retrieval or hallucination

#### Decision

We introduced a dedicated **execution layer** (v0.7.0) consisting of:

- a stable `DocumentAdapter` contract
- a concrete execution strategy (`PdfDocumentAdapter`)
- deterministic failure semantics (`nil → NOT_DEFINED`)

Execution is attempted **only after eligibility is approved** and may fail safely without fallback.

#### Rationale

- Execution is the highest‑risk stage of RAG systems
- Safe execution requires structure before intelligence
- Explicit failure is preferable to inferred authority
- Separating execution enables auditable, incremental evolution

#### Impact

- v0.7.0 makes knowledge execution a real, testable subsystem
- Document access remains controlled and honest
- Future execution enhancements (v0.7.1+) occur without reopening eligibility or reasoning logic

***

### **Decision 014: Resolve and Validate Knowledge Source Pointers at Runtime**

#### Context

After introducing an explicit execution boundary (v0.7.0), the system
was able to attempt knowledge execution safely, but it was still unclear
whether the approved document actually existed in the runtime environment.

Without explicit source pointer resolution:
- execution failures become ambiguous
- missing documents are indistinguishable from missing content
- infrastructure gaps surface late and unsafely

#### Decision

We introduced deterministic **source pointer resolution** (v0.7.1) as a
separate execution step.

This step:
- resolves a stable document identifier to a concrete runtime path
- explicitly validates document existence
- fails safely when documents are missing
- does not read or parse document content

#### Rationale

- Runtime existence is an infrastructure concern, not a parsing concern
- Execution should distinguish:
  - document missing
  - document present but content not yet defined
- Explicit validation strengthens auditability and trust
- File existence must be proven before any parsing is attempted

#### Impact

- v0.7.1 makes execution environment assumptions explicit
- Missing documentation surfaces as a safe, expected outcome
- Future parsing work (v0.7.2+) proceeds with guaranteed file availability
- Eligibility and reasoning logic remain unchanged

***

### **Decision 015: Introduce Section‑Level Grounding Before Term‑Level Interpretation**

#### Context

After validating document existence at runtime (v0.7.1), the system
could confirm that authoritative documentation was available.
However, extracting meaning directly from full documents risked:
* ambiguity
* accidental relevance assumptions
* unsafe keyword‑based matching
* silent hallucination

A deliberate intermediate step was required.

#### Decision

We introduced **explicit section‑level grounding** (v0.7.2) as a
mandatory execution step before any semantic interpretation.

Under this decision:
* The system must identify *where* knowledge lives structurally
* Semantic extraction is prohibited without a validated section
* Section boundaries are determined via explicit, human‑authored headers

#### Rationale

* Documents encode authority through structure, not keyword proximity
* Sections represent intentional scoping by the document author
* Separating structure from semantics improves auditability
* Large intermediate artifacts are acceptable when they preserve truth
* Refusing to guess is safer than partially extracting meaning

#### Observed Effects

During implementation, v0.7.2 surfaced:
* entire operational tables and explanatory content
* unexpected formatting from PDF conversion
* the necessity of handling noisy but deterministic text streams

These outcomes validated the need for:
* strict structure detection
* deferred semantic interpretation
* a dedicated term‑level grounding milestone (v0.7.3)

#### Impact

* Structural grounding became a first‑class execution concern
* Semantic grounding could be introduced safely and precisely later
* The system gained a clear, explainable grounding pipeline
* Phase 3 execution guarantees remained intact

This decision closed the structural gap between
document existence and semantic meaning.

***

### **Decision 016: Enforce Explicit Term‑Level Grounding Before User Interpretation**

#### Context

After completing section‑level grounding (v0.7.2), the system was capable of
identifying *where* authoritative knowledge lived inside a document.
However, early attempts to extract meaning revealed a critical ambiguity:

* The system lacked an explicit representation of *which concept* the user was asking about.
* Existing identifiers (e.g. document source pointers) were unintentionally reused as semantic placeholders.
* Vocabulary mismatches between user phrasing and document terminology surfaced silently.

Without a clear semantic boundary, definition extraction risked becoming implicit, inferred, or unsafe.

#### Decision

We introduced **explicit term‑level grounding** (v0.7.3) as a mandatory execution step.

This decision enforces that:

* The semantic **term** being queried must be passed explicitly from intent analysis.
* Execution adapters must **never infer or guess** the term.
* Only terms defined exactly in authoritative documentation are considered valid.
* Vocabulary mismatches result in an explicit `NOT_DEFINED` outcome.

#### Rationale

* Semantic correctness requires explicit intent, not positional or contextual inference.
* Reusing non‑semantic identifiers (e.g. document names) as terms creates silent coupling.
* Exact matching preserves auditability and prevents hallucinated definitions.
* Forcing explicit term propagation exposes contract violations early and safely.

#### Observed Failures (Accepted by Design)

During implementation, the system correctly rejected:

* `PARTIALLY RECONCILED` when the document defines `PARTIAL RECONCILED`
* `PARSING` when the document defines `PARSED`
* Informal or conversational status names not declared structurally

These failures validated:
* The necessity of a strict semantic contract
* The correctness of refusing approximate matches
* The need for a **future intent‑mediation layer** rather than weakening grounding rules

#### Impact

* Phase 3 execution is now **semantically precise and closed**
* Grounded answers are concise, authoritative, and defensible
* Human‑friendly interpretation is intentionally deferred to later phases
* Future enhancements can be layered without compromising truth integrity

***

### **Decision 017: Separate Intent Mediation from Knowledge Grounding**

#### Context

After completing Phase 3 (v0.7.0–v0.7.3), the system gained the ability to extract
authoritative truth from known documents with strict guarantees.

However, real console usage revealed a recurring gap:
users often phrase questions differently than the vocabulary used in
authoritative documentation (e.g. “parsing” vs “PARSED”,
Unicode punctuation variants, informal phrasing).

Embedding such logic directly into grounding would have weakened
structural guarantees and conflated concerns.

#### Decision

We introduced a dedicated **Intent Mediation layer (v0.8.0)**,
positioned *before* grounding and *after* user input collection.

This layer:

- Translates human phrasing into canonical document terms
- Normalizes casing, punctuation, whitespace, and Unicode variants
- Resolves only **explicit, auditable aliases**
- Produces a single, explicit intent object
- Refuses resolution when ambiguity exists

Grounding logic (v0.7.x) remains frozen and untouched.

#### Rationale

- Understanding *what the user means* is orthogonal to *what the document says*
- Canonicalization must be deterministic, not heuristic
- Explicit alias mapping preserves auditability
- Strict failure (`NOT_DEFINED`) is safer than partial guessing
- A separate intent contract enables future RAG and workflow layers cleanly

#### Observed Outcomes

- User questions with punctuation and Unicode differences resolve correctly
- Informal phrasing maps cleanly to canonical document terms
- Ambiguous or workflow‑oriented questions fail safely
- Errors and status codes resolve intent but defer explanation appropriately

These outcomes validated that intent mediation is necessary,
but should not expand semantic scope beyond definition intent.

#### Impact

- Grounding remains the single source of document truth
- UX improves without weakening safety guarantees
- Alias growth is controlled and explicit
- Clear handoff point is established for future explanation (v0.9) and retrieval (v1.x)

This decision formalizes intent mediation as a first‑class,
pre‑grounding semantic layer.

*** 
