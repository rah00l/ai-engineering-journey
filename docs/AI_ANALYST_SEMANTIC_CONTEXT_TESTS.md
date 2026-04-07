
# 📄 `docs/AI_ANALYST_SEMANTIC_CONTEXT_TESTS.md`

## Semantic Context Validation — v0.4.0 vs v0.5.0

### Purpose

This document validates **conversation‑level semantic behavior** introduced in **v0.5.0 (Phase 2)** by comparing it with **v0.4.0**.

It is structured around **user workflows**, not individual prompts, and demonstrates **where and why v0.5.0 semantics were required**.

***

## Workflow 1 — Meaning → Cause → Action (Primary Analyst Flow)

### User Workflow

    1. What does MAPPING ERROR – Payment ID Not Found mean?
    2. Why did this happen?
    3. What should I do now?

### v0.4.0 Behavior

*   Meaning, cause, and action often mixed
*   “Why” either hallucinated or failed inconsistently
*   No clear conversation closure

### v0.5.0 Behavior

*   Step‑wise explanation:
    1.  Meaning only
    2.  One bounded cause explanation
    3.  Action guidance and closure
*   Reasoning stops after action

### Semantic Concepts Used

*   Reasoning State
*   Context Window Management
*   Progressive Disclosure
*   Bounded Working Memory
*   Session Scope

### AnalysisContext Attributes

*   `session_id`
*   `current_focus`
*   `file_state`
*   `reasoning_budget`
*   `lifecycle.state`

***

## Workflow 2 — Preventing Over‑Reasoning (“Why” Loop)

### User Workflow

    1. Why did this happen?
    2. Why did this happen?

### v0.4.0 Behavior

*   Repeated speculative explanations
*   No stopping condition

### v0.5.0 Behavior

*   First “why”: allowed (if context exists)
*   Second “why”: BLOCKED
*   Reason explicitly stated: budget exhausted

### Semantic Concepts Used

*   Bounded Working Memory
*   Failure‑Safe Continuation

### AnalysisContext Attributes

*   `reasoning_budget.turns_remaining`
*   `blocking_condition`

***

## Workflow 3 — Unsafe “Why” Without Context

### User Workflow

    Why did this happen?

*(no prior context)*

### v0.4.0 Behavior

*   Generic or hallucinated cause

### v0.5.0 Behavior

*   BLOCKED
*   Clear explanation of insufficient context
*   Responsibility assigned

### Semantic Concepts Used

*   Separation of Facts vs AI Output
*   Failure‑Safe Continuation

### AnalysisContext Attributes

*   `blocking_condition.reason`
*   `blocking_condition.responsibility`

***

## Workflow 4 — Topic Change & Intentional Forgetting

### User Workflow

    1. Why did this happen?
    2. What does PARTIALLY RECONCILED mean?

### v0.4.0 Behavior

*   No guaranteed separation between topics

### v0.5.0 Behavior

*   Previous reasoning session closed
*   New reasoning session created
*   Clean explanation without reference to past topic

### Semantic Concepts Used

*   Intentional Forgetting
*   Session Scope
*   Reasoning State

### AnalysisContext Attributes

*   `lifecycle.state`
*   new `session_id`
*   reset `reasoning_budget`

***

## Workflow 5 — Action Ends Conversation

### User Workflow

    What should I do now?

### v0.4.0 Behavior

*   Conversation could continue indefinitely

### v0.5.0 Behavior

*   Action response provided
*   Lifecycle marked completed
*   Follow‑ups treated as new session

### Semantic Concepts Used

*   Session Scope
*   Progressive Disclosure

### AnalysisContext Attributes

*   `current_focus = :next_action`
*   `lifecycle.state = :COMPLETED`

***

## Semantic Coverage Matrix

| Semantic Concept                 | Workflow(s) |
| -------------------------------- | ----------- |
| Reasoning State                  | 1, 4        |
| Context Window Management        | 1           |
| Separation of Facts vs AI Output | 3           |
| Progressive Disclosure           | 1, 5        |
| Failure‑Safe Continuation        | 2, 3        |
| Bounded Working Memory           | 1, 2        |
| Intentional Forgetting           | 4           |
| Session Scope                    | 1, 4, 5     |

***

## Summary

*   v0.4.0 ensured **reliable single responses**
*   v0.5.0 ensures **safe, human‑like conversational reasoning**
*   All 8 semantic concepts are validated through real workflows
*   These behaviors cannot be achieved via prompts alone

This document serves as:

*   proof of semantic evolution
*   regression baseline for future milestones
*   justification for introducing higher‑level capabilities (RAG, tools)

***

✅ **Status:** Review‑ready  
🔗 **Referenced from:** README v0.5.0

***

### Next Step

If this structure meets your expectations, please confirm:

> ✅ **“Semantic Context Test document approved”**

After that, we will:

1.  Lock this test document
2.  Update **Decision Log**
3.  Update **Learning Milestones**
4.  Commit Phase 5.5 and tag **v0.5.0**

This version is intentionally **minimal, structured, and reviewer‑first**, exactly as you requested.
