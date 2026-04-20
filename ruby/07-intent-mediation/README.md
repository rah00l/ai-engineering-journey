# ✅ **v0.8.0 — Intent Mediation & Canonicalization (Phase 4)**

## Purpose

This milestone introduces **explicit intent mediation** for the AI Analyst Assistant.

While **Phase 3 (v0.7.x)** focused on extracting **authoritative truth** from known documents,
v0.8.0 focuses on **bridging human language to document language** safely and deterministically.

The intent is to ensure that:

*   human questions are understood correctly,
*   document vocabulary remains authoritative,
*   and grounding purity is preserved.

This milestone makes the system **usable without being unsafe**.

***

## Scope

✅ **Includes:**

*   Explicit intent resolution (`Intent`)
*   Canonicalization of human phrasing into document terms
*   Controlled alias mapping (e.g. *parsing* → *PARSED*)
*   Intent categorization (definition vs workflow)
*   Ambiguity detection and explicit refusal
*   Deterministic, explainable intent output
*   Clean orchestration boundary before grounding

❌ **Excludes:**

*   Document access or parsing
*   Section identification or term extraction
*   Vector search or embeddings
*   Ranking, scoring, or recall logic
*   Knowledge expansion or explanation
*   Workflow guidance or recommendations
*   Persistence or memory

***

## Version Progression (Clear Differentiation)

*   **v0.6.x** — Document‑aware reasoning  
    *“Can documentation be consulted at all?”*

*   **v0.7.x** — Knowledge grounding  
    *“What exactly does the document say?”*

*   **v0.8.0** — Intent mediation (this milestone)  
    *“What does the user mean, in document terms?”*

*   **v1.x** — Retrieval (RAG)  
    *“Which document(s) should I consult?”*

***

## Core Semantic Concepts Introduced

v0.8.0 formalizes the separation between **meaning** and **truth**:

*   **Intent Object** — a canonical, structured representation of user request
*   **Canonical Vocabulary** — document terms override conversational phrasing
*   **Alias Mediation** — explicit translation, never inference
*   **Ambiguity Detection** — unclear intent blocks execution
*   **Pre‑Grounding Gate** — grounding is invoked only with valid intent

Importantly:

> These concepts control *what* is asked, not *what is true*.

***

## Example Behavior

This milestone changes **how user questions are prepared**, not how answers are derived.

### Scenario: Informal Definition Question

**User Input**

    What does parsing mean?

**v0.8.0 Behavior**

*   Intent resolver detects a definition request
*   Canonicalizes `"parsing"` → `"PARSED"`
*   Emits a grounding‑ready intent

```json
{
  "category": "definition",
  "source": "RECONCILIATION_HANDBOOK",
  "version": "v2.1",
  "section": "definitions",
  "term": "PARSED"
}
```

Grounding (v0.7.3) proceeds **unchanged**.

***

### Scenario: Ambiguous or Unsafe Question

**User Input**

    Explain reconciliation workflows

**v0.8.0 Behavior**

*   Intent category unclear (definition vs workflow)
*   No safe canonical mapping available
*   Execution halts with explicit refusal

```json
{
  "status": "NOT_DEFINED",
  "reason": "AMBIGUOUS_INTENT"
}
```

No document access occurs.

***

## Folder Structure

```text
ruby/07-intent-mediation/
├── intent_resolver.rb
├── canonicalizer.rb
├── alias_map.rb
├── README.md
```

*   Intent logic is isolated from grounding
*   No adapter or document code is reused here
*   This folder produces **data**, not answers

***

## Key Learnings (Expected)

*   Users rarely speak in document vocabulary
*   Canonicalization must be explicit to remain auditable
*   Guessing “close enough” undermines trust
*   Separating intent from grounding simplifies RAG later
*   UX safety improves without touching truth extraction

***

## Mental Model Update

*   **v0.7.3:** *The system knows exactly what the document says.*
*   **v0.8.0:** *The system knows what the user means.*

Truth remains untouched.

***

## Why This Milestone Matters

Without intent mediation:

*   grounding appears brittle
*   users experience unnecessary `NOT_DEFINED`
*   RAG recall later becomes noisy
*   workflow explanations risk starting from wrong premises

v0.8.0 ensures:

*   grounding is called correctly
*   vocabulary mismatches surface cleanly
*   retrieval (RAG) has a stable semantic target
*   the system remains human‑usable without relaxing safety

✅ **Status:** Designed  
➡️ **Next:** v0.9.0 — Guided Explanations & Role‑Based Workflows

***

## Final Alignment Statement

Nothing in v0.8.0 alters:

*   Phase 2 reasoning discipline
*   Phase 3 grounding guarantees
*   Future RAG boundaries

It exists purely to **mediate meaning**, not **manufacture truth**.

***
