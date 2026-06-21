# Architecture Overview

Forge is a modular monorepo deployed to a VPS. Next.js applications consume shared UI and domain packages and call the FastAPI platform service. Postgres is the durable store, with a pgvector-ready image for future embeddings. Redis is reserved for caching, queues, and ephemeral coordination. The Forge MCP server will eventually provide a constrained control plane for Codex and trusted operators.

Dependencies flow inward: projects and apps may depend on packages and core services; core services must never depend on a project. Metadata in `projects/` describes deployments but contains no application implementation.
