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

