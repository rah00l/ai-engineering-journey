# v0.1.0 — LLM API Connectivity (Ruby + Docker)

## Purpose

Establish a minimal, production-style foundation for interacting with a Large Language Model (LLM)
by treating it as an external HTTP service, similar to any third-party API.

This milestone validates end-to-end connectivity, authentication, and deployment setup
without introducing application logic or frameworks.

---

## Scope

✅ Includes:
- Calling OpenAI Chat Completions API from Ruby
- Secure API key handling via environment variables
- Dockerized runtime setup
- Minimal request/response handling

❌ Excludes:
- Interactive user input
- Business or domain-specific logic
- Structured outputs
- Reliability mechanisms (retries, cost tracking)
- System or database integration

---

## What This Demonstrates

- LLMs are external services, not embedded intelligence
- API-first thinking for AI systems
- Secure configuration management
- Reproducible execution using Docker

This milestone answers the question:
**“Can I reliably call an LLM in a production-style setup?”**

---

## Tech Stack

- Ruby 3.x
- HTTParty (HTTP client)
- OpenAI Chat Completions API
- Docker & Docker Compose

---

## Folder Structure

```

01-openai-connect/
├── Dockerfile
├── docker-compose.yml
├── Gemfile
├── Gemfile.lock
├── openai\_test.rb
├── README.md
└── .env.example

````

---

## How to Run

1. Create a `.env` file from `.env.example` and add your API key.

2. From this folder, run:

```bash
docker compose build
docker compose run openai-test
````

***

## Example Output

    AI engineering is the discipline of designing, building, and operating
    AI-powered systems using software engineering principles.

***

## Key Learnings

*   LLM APIs behave like any other unreliable external dependency
*   Environment variables are mandatory for secure configuration
*   Docker eliminates local setup drift
*   Prompting is not intelligence — it is interface design
