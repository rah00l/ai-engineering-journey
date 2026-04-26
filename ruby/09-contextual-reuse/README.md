
# ✅ **v0.9.0 — Guided Status & Error Workflows (Phase 4)**

## Purpose

This milestone introduces **guided explanations for system statuses and error states** in the AI Analyst Assistant.

While **Phase 3 (v0.7.x)** focused on extracting **authoritative truth** and  
**v0.8.0** focused on **understanding what the user means**,

v0.9.0 focuses on **how that grounded truth is explained to humans**  
in a way that is **clear, actionable, and role‑appropriate**.

The intent is to ensure that:

*   grounded facts are interpretable by real users,
*   system states and errors are explained consistently,
*   and safety guarantees remain intact.

This milestone makes the system **operationally useful**, not just correct.

***

## Scope

✅ **Includes:**

*   Guided explanation strategies for:
    *   processing statuses
    *   blocking states
    *   error conditions (e.g. mapping errors, parsing errors)
*   Semantic classification of grounded concepts:
    *   status
    *   error
    *   terminal state
*   Structured explanation sections such as:
    *   meaning
    *   impact / implications
    *   blocking status
    *   typical next steps
    *   ownership
*   Deterministic explanation templates per concept type
*   Clear separation between document facts and human guidance

❌ **Excludes:**

*   Document access or parsing
*   Section discovery or term grounding
*   Alias resolution or intent mediation
*   Retrieval or ranking (RAG)
*   Workflow execution or automation
*   Live system or database access
*   Speculative root‑cause analysis
*   Memory or persistence

***

## Version Progression (Clear Differentiation)

*   **v0.6.x** — Knowledge source eligibility  
    *“Can authoritative documentation be consulted at all?”*

*   **v0.7.x** — Knowledge grounding  
    *“What exactly does the document say?”*

*   **v0.8.0** — Intent mediation  
    *“What does the user mean, in document terms?”*

*   **v0.9.0** — Guided explanations (this milestone)  
    *“How should this meaning be explained to a human?”*

*   **v1.x** — Retrieval (RAG)  
    *“Which document(s) should I consult?”*

***

## Core Semantic Concepts Introduced

v0.9.0 formalizes the separation between **truth** and **guidance**:

*   **Concept Classification** — status vs error vs terminal state
*   **Explanation Strategy** — how different concept types are explained
*   **Human‑Ready Sections** — consistent explanation structure
*   **Blocking Awareness** — whether processing can continue
*   **Ownership Attribution** — who is expected to act next

Importantly:

> These concepts determine *how information is presented*,  
> not *what information is true*.

***

## Example Behavior

This milestone changes **how grounded facts are explained**, not how they are derived.

### Scenario: Mapping Error Explanation

**Grounded Concept**

    MAPPING ERROR – Payment ID Not Found

**v0.9.0 Behavior**

*   Classifies the concept as a **mapping error**
*   Applies an error‑specific explanation strategy
*   Produces a structured, human‑oriented explanation

**Conceptual Output**

*   Meaning of the error
*   Why the file cannot proceed
*   Typical next step (correct and re‑upload)
*   Ownership (Accounting / Operations)
*   Blocking indication

Grounded truth remains **unchanged and auditable**.

***

### Scenario: Terminal Status Explanation

**Grounded Concept**

    FULL RECONCILED

**v0.9.0 Behavior**

*   Recognizes terminal, non‑blocking status
*   Explains completion without suggesting further action
*   Avoids unnecessary guidance

***

## Folder Structure

```text
ruby/08-guided-explanations/
├── README.md
├── concept_classifier.rb
├── explanation_contract.rb
├── explanation_builder.rb
└── templates/
    ├── mapping_error_template.rb
    └── status_template.rb
```

*   Explanation logic is isolated from grounding
*   No adapter or document code is duplicated
*   Outputs are **structured explanations**, not decisions or actions

***

## Key Learnings (Expected)

*   Correct answers are insufficient without structured explanation
*   Errors and statuses require different explanation strategies
*   Users care about impact and next steps, not raw definitions
*   Guidance must remain document‑safe and auditable
*   Separating explanation from grounding prevents hallucination

***

## Mental Model Update

*   **v0.7.x:** *The system knows what is true.*
*   **v0.8.0:** *The system knows what the user meant.*
*   **v0.9.0:** *The system knows how to explain it.*

Truth remains untouched.

***

## Why This Milestone Matters

Without guided explanations:

*   users encounter correct but unhelpful responses
*   errors appear opaque and blocking without guidance
*   operational confidence is low
*   the system feels incomplete despite correctness

v0.9.0 ensures:

*   grounded facts are understandable
*   error states are actionable
*   safety guarantees remain intact
*   the assistant behaves like a trained analyst

✅ **Status:** Designed  
➡️ **Next:** v0.9.x — Implementation of Mapping Error Explanations

***

## Final Alignment Statement

Nothing in v0.9.0 alters:

*   Phase 3 grounding guarantees
*   Phase 4 intent mediation behavior
*   Future RAG boundaries

It exists solely to **explain grounded truth**, not to discover or infer it.

***
