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

