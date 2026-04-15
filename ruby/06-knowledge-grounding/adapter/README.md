
# 1️⃣ `adapter/README.md` — v0.7.0 (Execution Skeleton)

### Purpose

The document adapter exists to:

- Provide a deterministic execution boundary for document access
- Ensure that documentation usage is deliberate and auditable
- Prevent implicit retrieval or heuristic grounding
- Enable safe, staged introduction of grounded explanations

The adapter is intentionally conservative by design.

---

### v0.7.0 — Execution Skeleton

In v0.7.0, the adapter provides **plumbing only**.

It establishes:
- A stable execution interface (`DocumentAdapter`)
- A callable implementation (`PdfDocumentAdapter`)
- A safe failure contract (`nil` → `NOT_DEFINED`)

No document content is accessed or interpreted at this stage.

This milestone exists solely to prove that:
> execution can occur safely once permission is granted.

---

### Responsibilities

The document adapter **must**:

- Accept an explicit source pointer, section, and version
- Return extracted text **only if it is deterministically available**
- Return `nil` when content is missing or undefined
- Never guess, infer, or approximate content
- Never perform permission or intent checks

---

### Non‑Responsibilities

The document adapter **does not**:

- Decide whether documentation may be consulted
- Parse or interpret document semantics
- Perform semantic search or embeddings
- Cache, persist, or remember content
- Fall back to model knowledge

---

### Failure Semantics

Returning `nil` is an intentional and valid outcome.

It signifies:
- Documentation access was allowed
- Execution was attempted
- No authoritative content could be located

The system must respond with `NOT_DEFINED` in this case.

---

### Evolution Plan (v0.7.x)

This adapter evolves incrementally across sub‑milestones:

- **v0.7.0** — Execution skeleton (no document access)
- **v0.7.1** — Source pointer resolution (file existence)
- **v0.7.2** — Section identification (deterministic blocks)
- **v0.7.3** — Term‑level grounding (exact definitions)

Each stage adds execution capability without weakening safety guarantees.

---

### Design Principle

> **Execution must fail safely before it succeeds accurately.**

This principle guides all future adapter enhancements.
```
