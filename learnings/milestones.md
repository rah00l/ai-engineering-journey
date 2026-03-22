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

