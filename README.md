# Forge

Forge is a VPS-hosted personal AI engineering platform and monorepo for building, operating, and onboarding projects without repository sprawl.

## Repository map

- `apps/` contains deployable applications.
- `core/` contains shared, stable platform services.
- `packages/` contains reusable libraries.
- `projects/` contains project metadata and documentation only.
- `experiments/` contains disposable prototypes that are not production apps.
- `infra/` contains Docker, nginx, and infrastructure scripts.
- `mcp/forge-server/` is the future Codex/VPS control surface.
- `docs/` records architecture, decisions, and runbooks.
- `scripts/` provides common developer workflows.

## Applications

- `landing-dashboard`: public portfolio and navigation UI.
- `prompt-dashboard`: migrated Athena prompt-engineering tool.
- `forge-dashboard`: private Forge control centre.
- `rag-playground`: retrieval-augmented generation workbench.
- `evals-dashboard`: evaluation workflows and reporting.

## Dependency rule

A project may depend on Forge. Forge core must never depend on a project. Shared code belongs in `packages/`; stable platform services belong in `core/`.

## Local start

1. Copy `.env.example` to `.env` and adjust secrets.
2. Run `./scripts/bootstrap.sh`.
3. Run `./scripts/dev.sh`, or `docker compose up --build`.

The initial API health check is available at `http://localhost:8000/health`.
