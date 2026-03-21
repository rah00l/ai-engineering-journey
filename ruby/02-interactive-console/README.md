
# v0.2.0 — Interactive AI Console (Reconciliation Domain)

## Purpose

Introduce an interactive, conversational AI interface that explains
payment reconciliation concepts in business-friendly language.

This milestone focuses on observing AI behavior in real-time,
understanding failure modes, and enforcing domain boundaries
without using any database or document retrieval.

---

## Scope

✅ Includes:
- Interactive CLI-based AI conversation loop
- Domain-aware explanations for reconciliation statuses and errors
- Explicit prompt boundaries to prevent hallucination
- Conversation history (memory) handling

❌ Excludes:
- Database or transaction-specific data access
- Document-based retrieval (RAG)
- Structured JSON outputs
- Automation, decision-making, or data modification

---

## What This Demonstrates

- Conversational AI behavior under real user input
- The importance of prompt boundaries in enterprise domains
- How easily models invent plausible but incorrect explanations
- Why explainability requires engineering, not just prompting

This milestone answers:
**“How does an AI behave when users ask open-ended ‘why’ questions?”**

---

## Tech Stack

- Ruby 3.x
- HTTParty
- OpenAI Chat Completions API (`gpt-4o-mini`)
- Docker & Docker Compose

---

## Folder Structure

````

02-interactive-console/
├── Dockerfile
├── docker-compose.yml
├── Gemfile
├── Gemfile.lock
├── ai\_console.rb
├── README.md
└── .env.example

````

---

## How to Run

1. Ensure `.env` contains a valid OpenAI API key.

2. From this folder:

```bash
docker compose build
docker compose run ai-console
````

***

## Example Interaction / Output

    > What does PARTIALLY RECONCILED mean?

    AI:
    PARTIALLY RECONCILED means that transaction reconciliation
    has completed successfully, but one or more tenancy-related
    amounts still require manual settlement before full reconciliation.

    Next step:
    Review the Tenancy Settlement Screen and complete all pending
    tenancy settlements before proceeding to full reconciliation.

***

## Key Learnings

*   Users naturally ask vague, ambiguous questions
*   AI models default to generic enterprise language if unconstrained
*   Prompt boundaries significantly affect trustworthiness
*   Domain correctness matters more than fluent wording
