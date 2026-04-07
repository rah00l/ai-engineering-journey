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

