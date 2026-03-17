
# OpenAI Ruby API – Minimal Kickstart

Minimal, Dockerized Ruby script to test connectivity with the OpenAI API.

This repository serves as a **kickstart and validation step** for integrating AI models into Ruby-based systems, without introducing frameworks or local dependency issues.

---

## Purpose

- Verify OpenAI API access and authentication  
- Understand basic request/response flow with an LLM  
- Establish a clean, reproducible setup using Docker  
- Act as a foundation for further AI engineering experiments  

---

## What It Does

- Sends a prompt to the OpenAI Chat Completions API  
- Receives a response from the model  
- Prints the generated text to the console  

---

## Tech Stack

- **Ruby** – scripting language  
- **HTTParty** – HTTP client for API calls  
- **Docker** – environment isolation and reproducibility  

---

## Model Used

- `gpt-4o-mini`

Chosen for:
- low cost
- fast responses
- suitability for experimentation

---

## Project Structure

```

openai-ruby-test/
├── Dockerfile
├── docker-compose.yml
├── Gemfile
├── Gemfile.lock
├── .env.example
└── openai\_test.rb

```

---

## Setup

1. Copy `.env.example` to `.env`
2. Add your OpenAI API key:
```

OPENAI\_API\_KEY=sk-xxxxxxxx

````

---

## Run

```bash
docker compose build
docker compose run --rm openai-test
````

You should see an AI-generated response printed to the console.

***

## Scope

This repository intentionally focuses on **only API connectivity**.

It does **not** cover:

*   application architecture
*   state or memory
*   document retrieval
*   RAG or agents

Those will be added incrementally in future iterations.

***
