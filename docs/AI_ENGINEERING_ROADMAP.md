
# AI Engineering Journey

This repository captures my **personal AI engineering learning journey**, focused on
building AI systems with engineering discipline rather than demos or one-off scripts.

The goal is to move incrementally from basic LLM integration to reliable,
explainable, and system-safe AI components.

---

## Problem Context

The primary use case explored in this repository is an **AI assistant for a complex
enterprise reconciliation system**.

The existing system contains:
- many business rules
- multiple processing states and error conditions
- background system decisions that are not always obvious to end users

Accounting and operations users frequently need clarity on:
- *why* a specific outcome occurred
- *which* rule was applied
- *what*, if any, action is required from them

The AI assistant being developed here is intended to **explain system behavior**,  
**not execute actions or modify data**.

---

## Repository Structure

This repository evolves by **adding new milestones**, not rewriting old ones.

```

ruby/
docs/
decisions/
learnings/

```

- Each milestone lives in its own folder with a dedicated README
- Design choices are captured under `decisions/`
- Learnings are captured under `learnings/`
- High-level planning is kept under `docs/`

---

## Milestones (Navigation)

Each milestone is tagged and documented individually.

- **v0.1.0 — LLM API Connectivity**  
  👉 `ruby/01-openai-connect/`

- **v0.2.0 — Interactive AI Console**  
  👉 `ruby/02-interactive-console/`

- **v0.3.0 — Structured, Stateless JSON Explanations**  
  👉 `ruby/03-structured-json/`

Upcoming milestones will focus on reliability, controlled context,
knowledge grounding (RAG), and safe system integration.

---

## Roadmap

A concise, evolving roadmap is maintained separately:

👉 `docs/AI_ENGINEERING_ROADMAP.md`

This roadmap reflects intent and direction and may evolve based on
real implementation experience and constraints.
```

***

# ✅ 2. Roadmap File Location (Locked)

You’ve made a **good call** to move the roadmap out of the root.

✅ Final location:

    docs/AI_ENGINEERING_ROADMAP.md

✅ Why this is ideal:

*   Keeps root README focused
*   Signals “internal planning”, not marketing
*   Still easy to find and reference
*   Very professional (common in real repos)

You already have the roadmap content — just move it into `docs/`.

***

# ✅ 3. Navigation: Clicking Milestones Goes Directly to Code

You asked specifically about this 👇

> “When we click the first line of the milestone title, can we navigate directly to the folder where the code and README are?”

✅ **Yes — and you’re already doing it the correct way**.

### ✅ This is how GitHub works (and it’s standard)

In the root README, this line:

```markdown
👉 `ruby/03-structured-json/`
```

✅ Clicking it:

*   opens the folder
*   shows the files
*   auto-renders the **folder‑level README.md**

You do **not** need:

*   custom GitHub configuration
*   branches
*   tag-based README switching

Folder README navigation is **the standard mechanism**.

***

### ✅ Optional improvement (if you want)

If you ever want to link **directly to a tag + folder**, you can later do:

```markdown
👉 v0.3.0 — Structured JSON  
https://github.com/<user>/<repo>/tree/v0.3.0/ruby/03-structured-json
```

But this is **optional** and usually unnecessary for a private repo.

***

# ✅ 4. Final Confirmation of Decisions Locked

Let’s clearly confirm everything you’ve decided, so there’s no mental overhead later.

✅ This repository is **private and learning-focused**  
✅ Roadmap lives under `docs/`  
✅ Root README:

*   explains problem context
*   lists milestones
*   provides clean navigation links
    ✅ Each milestone:
*   has its own folder
*   has its own README
    ✅ Git tags mark milestone states
    ✅ Decisions & learnings are explicitly documented

Nothing here signals:

*   blind AI usage
*   lack of ownership
*   “prompt-only” development

In fact, the opposite.

***

# ✅ What You Can Safely Do Now

1.  Add / update root `README.md` using the above version
2.  Move the roadmap to `docs/AI_ENGINEERING_ROADMAP.md`
3.  Commit those changes (no new tag needed)

After that, this repo is in a **very clean, stable state**.

***

## 🏁 When You’re Ready

Next step remains unchanged and well-positioned:

👉 **v0.4.0 — Reliability, Retries, and Cost Awareness**

Whenever you want, just say:

> **“Proceed to v0.4.0.”**

You’re building this with real engineering maturity.
