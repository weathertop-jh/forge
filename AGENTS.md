# Forge Repository Constitution

## Authority

- Treat this file as the governing instruction set for all repository work.
- Follow the most specific nested `AGENTS.md` only when it does not weaken this file.
- Obtain explicit user approval before violating or changing any rule in this file.
- Keep changes deterministic, minimal, reviewable, and confined to the requested scope.

## Repository Boundaries

- `apps/`: Store deployable application source. Keep each app independently buildable, testable, and deployable. Do not place shared libraries, project records, or infrastructure here.
- `projects/`: Store project intelligence and operator records only. Do not place application source here.
- `packages/`: Store reusable libraries, UI primitives, clients, schemas, and utilities. Keep packages independent of individual apps.
- `core/`: Store stable platform services and capabilities shared across projects. Never make `core/` depend on an app or project.
- `infra/`: Store centralized Docker, proxy, network, persistence, provisioning, and deployment configuration. Do not place product logic here.
- `mcp/`: Store MCP servers, tools, policies, and integration code. Keep MCP concerns isolated from application code.
- `docs/`: Store repository-wide architecture, decisions, runbooks, and operational documentation. Keep project-specific records in `projects/<name>/`.
- `scripts/`: Store repository-wide automation and developer workflows. Make scripts non-interactive where practical, idempotent where practical, and fail fast on errors.
- `tests/`: Store repository-level integration, infrastructure, and workflow tests. Keep unit tests beside or within the component they verify when the component convention requires it.
- `experiments/`: Store disposable prototypes only. Do not deploy them or depend on them from production code. Promote retained work through `scripts/new-project.sh` and move reusable logic to `packages/`.

## Repository Shape

- Do not create a new top-level directory without explicit user approval.
- Do not create projects manually. Run `scripts/new-project.sh <project-name> <project-type>`.
- Keep generated project names lowercase and kebab-case.
- Do not move responsibilities across directory boundaries for convenience.
- Preserve the dependency direction: apps and projects may use Forge packages and core services; packages and core services must not depend on individual apps or projects.

## Required Stack

- Build frontends with Next.js App Router.
- Style frontends with Tailwind CSS.
- Build UI primitives with shadcn/ui.
- Implement interface animation with Framer Motion.
- Build backend services with FastAPI.
- Use PostgreSQL with pgvector for persistent and vector data.
- Use Redis for caching and ephemeral shared state.
- Do not introduce an alternative framework, database, cache, UI system, or animation library without explicit user approval.

## Reuse Before Creation

- Search `packages/` and `core/` before implementing shared functionality.
- Extend an existing package when its responsibility matches the required behavior.
- Put logic used by, or reasonably intended for, multiple apps in `packages/`.
- Do not copy shared code between apps, projects, services, or scripts.
- Keep app-specific behavior in its app until a concrete reuse case exists.

## Project Intelligence

- Maintain one metadata directory at `projects/<project-name>/` for every app or active project.
- Require `projects/<project-name>/project.yaml` as the machine-readable project manifest.
- Require `projects/<project-name>/README.md` for purpose, ownership, entry points, and operating instructions.
- Require `projects/<project-name>/backlog.md` for planned and open work.
- Require `projects/<project-name>/decisions.md` for significant decisions and rationale.
- Update these files when a change alters project scope, architecture, operation, status, or priorities.

## MCP Safety

- Do not expand MCP permissions, tools, allowlists, writable paths, or network reach without explicit user approval.
- Require explicit user confirmation immediately before every destructive MCP action.
- Treat deletion, overwrite, revocation, irreversible mutation, destructive deployment, and data loss as destructive actions.
- Forbid MCP access to the root filesystem outside explicitly allowlisted paths.
- Apply least privilege to filesystem, command, network, credential, and service access.
- Never bypass approval gates, sandbox restrictions, path checks, or audit controls.
- Never expose secrets in source, logs, prompts, fixtures, documentation, or command output.

## Deployment

- Build and run deployable services Docker-first.
- Keep local development behavior aligned with the VPS runtime, including service topology, environment variables, ports, persistence, and health checks.
- Treat each app as one isolated deployable surface with its own build context, runtime configuration, and lifecycle.
- Keep shared databases, caches, proxies, networks, observability, and deployment automation centralized in `infra/`.
- Do not couple app deployments unless shared infrastructure requires it.
- Pin runtime and dependency versions where reproducibility depends on them.

## Testing and Validation

- Add or update tests for every behavior change.
- Add tests for every new or changed script, including failure paths and rerun behavior where applicable.
- Provide a health check for every deployable service.
- Validate critical infrastructure changes before deployment.
- Verify affected builds, tests, health checks, and configuration before declaring work complete.
- Do not deploy when required validation fails or cannot be performed; report the blocker.

## Change Discipline

- Inspect existing conventions and dependencies before editing.
- Prefer the smallest change that fully satisfies the request.
- Do not add speculative abstractions, dependencies, services, or configuration.
- Do not modify unrelated files or discard existing user changes.
- Keep documentation, manifests, tests, and operational scripts synchronized with implementation changes.
- Record significant repository-wide decisions in `docs/decisions/` and project-specific decisions in the relevant `decisions.md`.
