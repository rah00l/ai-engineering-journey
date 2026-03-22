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
