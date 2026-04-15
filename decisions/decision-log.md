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

