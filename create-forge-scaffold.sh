#!/usr/bin/env bash
set -euo pipefail

ROOT=${1:-"$(pwd)"}

create_file() {
  local relative_path=$1
  local destination="$ROOT/$relative_path"
  mkdir -p "$(dirname "$destination")"
  if [[ -e "$destination" ]]; then
    cat >/dev/null
    return 0
  fi
  cat >"$destination"
  printf 'created %s\n' "$relative_path"
}

create_readme() {
  local directory=$1
  local title=$2
  local purpose=$3
  printf '# %s\n\n%s\n\n%s\n' \
    "$title" \
    "$purpose" \
    'This folder is intentionally scaffold-only. Add implementation here when the component is promoted into active development.' \
    | create_file "$directory/README.md"
}

directories=(
  apps/landing-dashboard apps/prompt-dashboard apps/forge-dashboard
  apps/rag-playground apps/evals-dashboard core/api core/auth core/db core/mcp
  core/deploy packages/forge-sdk packages/ui-components packages/rag-utils
  packages/eval-utils projects/landing-dashboard projects/prompt-dashboard
  projects/rag-playground projects/evals-dashboard experiments infra/docker infra/nginx
  infra/scripts mcp/forge-server/src/forge_mcp docs/architecture docs/decisions
  docs/runbooks scripts
)
for directory in "${directories[@]}"; do
  mkdir -p "$ROOT/$directory"
done

create_file README.md <<'EOF'
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
EOF

create_file .env.example <<'EOF'
# Runtime
FORGE_ENV=development
FORGE_ROOT=/workspace

# Postgres / pgvector
POSTGRES_DB=forge
POSTGRES_USER=forge
POSTGRES_PASSWORD=change-me
DATABASE_URL=postgresql://forge:change-me@postgres:5432/forge

# Redis
REDIS_URL=redis://redis:6379/0

# API and MCP
API_PORT=8000
MCP_PORT=8001
FORGE_MCP_ALLOWED_ROOTS=/workspace
FORGE_MCP_ALLOWED_COMMANDS=git,docker,docker-compose,ls,find,rg
FORGE_MCP_AUDIT_LOG=/var/log/forge/mcp-audit.jsonl

# Deployment placeholders
FORGE_DEPLOY_HOST=
FORGE_DEPLOY_USER=
EOF

create_file .gitignore <<'EOF'
.env
.venv/
venv/
__pycache__/
*.py[cod]
.pytest_cache/
.ruff_cache/
.mypy_cache/
node_modules/
.next/
dist/
build/
coverage/
.DS_Store
*.log
EOF

create_file docker-compose.yml <<'EOF'
services:
  postgres:
    image: pgvector/pgvector:pg16
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-forge}
      POSTGRES_USER: ${POSTGRES_USER:-forge}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-change-me}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-forge} -d ${POSTGRES_DB:-forge}"]
      interval: 5s
      timeout: 5s
      retries: 10

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 10

  api:
    build:
      context: .
      dockerfile: infra/docker/api.Dockerfile
    environment:
      DATABASE_URL: ${DATABASE_URL:-postgresql://forge:change-me@postgres:5432/forge}
      REDIS_URL: ${REDIS_URL:-redis://redis:6379/0}
    ports:
      - "${API_PORT:-8000}:8000"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy

  mcp:
    build:
      context: .
      dockerfile: infra/docker/mcp.Dockerfile
    environment:
      FORGE_ROOT: /workspace
      FORGE_MCP_ALLOWED_ROOTS: ${FORGE_MCP_ALLOWED_ROOTS:-/workspace}
      FORGE_MCP_ALLOWED_COMMANDS: ${FORGE_MCP_ALLOWED_COMMANDS:-git,ls,find,rg}
      FORGE_MCP_AUDIT_LOG: ${FORGE_MCP_AUDIT_LOG:-/var/log/forge/mcp-audit.jsonl}
    volumes:
      - .:/workspace
      - mcp_logs:/var/log/forge
    ports:
      - "${MCP_PORT:-8001}:8001"
    depends_on:
      - api

volumes:
  postgres_data:
  redis_data:
  mcp_logs:
EOF

create_readme apps Apps "Deployable Forge applications live here. Experiments and metadata do not."
create_readme apps/landing-dashboard "Landing Dashboard" "The public portfolio, project directory, and navigation experience."
create_readme apps/prompt-dashboard "Prompt Dashboard" "The migrated Athena prompt-engineering application."
create_readme apps/forge-dashboard "Forge Dashboard" "The private internal control centre for Forge services and deployments."
create_readme apps/rag-playground "RAG Playground" "A deployable workbench for retrieval-augmented generation experiments that have graduated from prototypes."
create_readme apps/evals-dashboard "Evals Dashboard" "A deployable interface for evaluation suites, runs, and results."

create_readme core Core "Shared platform services live here. Core must not import project-specific code."
create_readme core/api "Core API" "The shared FastAPI service and platform-facing HTTP endpoints."
create_readme core/auth "Core Auth" "Shared authentication and authorization primitives for Forge applications."
create_readme core/mcp "Core MCP" "Shared MCP domain logic that is independent of the MCP transport server."
create_readme core/deploy "Core Deploy" "Stable deployment orchestration shared across Forge projects."

create_file core/api/main.py <<'EOF'
"""Forge platform API."""

from fastapi import FastAPI

app = FastAPI(title="Forge API", version="0.1.0")


@app.get("/health")
async def health() -> dict[str, str]:
    """Return a lightweight process health signal."""
    return {"status": "ok", "service": "forge-api"}
EOF

create_file core/api/requirements.txt <<'EOF'
fastapi>=0.115,<1
uvicorn[standard]>=0.30,<1
EOF

create_file core/db/README.md <<'EOF'
# Core Database

This folder owns shared database conventions, migrations, and connection helpers for Postgres.

The local Compose stack uses the `pgvector/pgvector` Postgres image so vector columns and indexes can be introduced without replacing the database service. Enable the extension in a future migration with:

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

Keep project-specific schemas and queries with their application. Only stable, cross-project persistence logic belongs here. Redis is available as a separate service for caching, queues, and ephemeral coordination; durable state stays in Postgres.
EOF

create_readme packages Packages "Reusable libraries shared by apps and platform services live here."
create_readme packages/forge-sdk "Forge SDK" "Typed clients and integration helpers for consuming Forge platform APIs."
create_readme packages/ui-components "UI Components" "Shared Next.js-compatible React, Tailwind CSS, shadcn/ui, and Framer Motion building blocks."
create_readme packages/rag-utils "RAG Utilities" "Reusable ingestion, retrieval, chunking, and vector-search utilities."
create_readme packages/eval-utils "Evaluation Utilities" "Reusable datasets, scoring helpers, and evaluation-run primitives."

create_readme projects Projects "Project metadata, manifests, and operator notes live here. Application code does not."

create_file projects/landing-dashboard/project.yaml <<'EOF'
schema_version: 1
project:
  id: landing-dashboard
  name: Landing Dashboard
  description: Public portfolio, project directory, and navigation UI.
  status: scaffolded
  visibility: public
application:
  path: apps/landing-dashboard
  type: nextjs
  runtime: node
  deployable: true
dependencies:
  forge_core: false
  packages:
    - ui-components
deployment:
  service_name: landing-dashboard
  healthcheck: /
  domain: null
owners: []
tags: [portfolio, navigation, public]
EOF

create_file projects/prompt-dashboard/project.yaml <<'EOF'
schema_version: 1
project:
  id: prompt-dashboard
  name: Prompt Dashboard
  description: Migrated Athena prompt-engineering tool.
  status: scaffolded
  visibility: private
application:
  path: apps/prompt-dashboard
  type: nextjs
  runtime: node
  deployable: true
dependencies:
  forge_core: true
  packages:
    - forge-sdk
    - ui-components
    - eval-utils
deployment:
  service_name: prompt-dashboard
  healthcheck: /
  domain: null
owners: []
tags: [prompts, athena-migration, internal]
EOF

create_file projects/rag-playground/project.yaml <<'EOF'
schema_version: 1
project:
  id: rag-playground
  name: RAG Playground
  description: Workbench for retrieval-augmented generation workflows.
  status: scaffolded
  visibility: private
application:
  path: apps/rag-playground
  type: nextjs
  runtime: node
  deployable: true
dependencies:
  forge_core: true
  packages:
    - forge-sdk
    - ui-components
    - rag-utils
deployment:
  service_name: rag-playground
  healthcheck: /
  domain: null
owners: []
tags: [rag, pgvector, internal]
EOF

create_file projects/evals-dashboard/project.yaml <<'EOF'
schema_version: 1
project:
  id: evals-dashboard
  name: Evals Dashboard
  description: Interface for defining, running, and reviewing AI evaluations.
  status: scaffolded
  visibility: private
application:
  path: apps/evals-dashboard
  type: nextjs
  runtime: node
  deployable: true
dependencies:
  forge_core: true
  packages:
    - forge-sdk
    - ui-components
    - eval-utils
deployment:
  service_name: evals-dashboard
  healthcheck: /
  domain: null
owners: []
tags: [evals, quality, internal]
EOF

create_readme projects/landing-dashboard "Landing Dashboard Project" 'Metadata and operator notes for the public landing dashboard. Source code lives in `apps/landing-dashboard`.'
create_readme projects/prompt-dashboard "Prompt Dashboard Project" 'Metadata and operator notes for the migrated Athena prompt tool. Source code lives in `apps/prompt-dashboard`.'
create_readme projects/rag-playground "RAG Playground Project" 'Metadata and operator notes for the RAG workbench. Source code lives in `apps/rag-playground`.'
create_readme projects/evals-dashboard "Evals Dashboard Project" 'Metadata and operator notes for the evaluations UI. Source code lives in `apps/evals-dashboard`.'

create_file experiments/README.md <<'EOF'
# Experiments

Disposable prototypes belong here, not in `apps/`. An experiment may be incomplete, short-lived, or intentionally rough.

Promote an experiment into an application only after its purpose, ownership, dependencies, and operating expectations are stable. Move reusable code into `packages/` during promotion.
EOF

create_readme infra Infrastructure "Docker definitions, nginx configuration, and operational scripts for Forge live here."
create_readme infra/docker Docker "Container build definitions shared by the local and VPS environments."
create_readme infra/nginx Nginx "Reverse-proxy and TLS configuration placeholders for VPS deployment."
create_readme infra/scripts "Infrastructure Scripts" "Infrastructure-specific automation that is not part of everyday developer workflows."

create_file infra/docker/api.Dockerfile <<'EOF'
FROM python:3.12-slim
WORKDIR /workspace
COPY core/api/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt
COPY core /workspace/core
CMD ["uvicorn", "core.api.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

create_file infra/docker/mcp.Dockerfile <<'EOF'
FROM python:3.12-slim
WORKDIR /workspace/mcp/forge-server
COPY mcp/forge-server/pyproject.toml mcp/forge-server/README.md ./
COPY mcp/forge-server/src ./src
RUN pip install --no-cache-dir .
CMD ["forge-mcp"]
EOF

create_file mcp/README.md <<'EOF'
# MCP

MCP transport servers live here. They expose carefully constrained platform capabilities to Codex and other trusted clients. Shared domain logic belongs in `core/mcp`; transport and tool registration belong in each server folder.
EOF

create_file mcp/forge-server/README.md <<'EOF'
# Forge MCP Server

Placeholder MCP server for future Codex-to-VPS control. The initial surface names file, Git, command, deployment, service, log, and asset operations without implementing privileged behavior.

Security is deny-by-default: paths and commands require allowlist checks, secrets must be redacted, and every sensitive operation must produce an audit event. Production deployment should add authentication, authorization, approval policies, rate limits, and isolated execution before enabling mutation tools.
EOF

create_file mcp/forge-server/pyproject.toml <<'EOF'
[build-system]
requires = ["hatchling>=1.25"]
build-backend = "hatchling.build"

[project]
name = "forge-mcp"
version = "0.1.0"
description = "Security-conscious MCP control surface for Forge"
readme = "README.md"
requires-python = ">=3.11"
dependencies = ["mcp>=1.0"]

[project.scripts]
forge-mcp = "forge_mcp.server:main"

[tool.hatch.build.targets.wheel]
packages = ["src/forge_mcp"]
EOF

create_file mcp/forge-server/src/forge_mcp/__init__.py <<'EOF'
"""Forge MCP server package."""

__version__ = "0.1.0"
EOF

create_file mcp/forge-server/src/forge_mcp/security.py <<'EOF'
"""Deny-by-default security primitives for future Forge MCP tools."""

from __future__ import annotations

import json
import os
import re
from datetime import UTC, datetime
from pathlib import Path
from typing import Any, Iterable

SECRET_KEY_PATTERN = re.compile(
    r"(api[_-]?key|authorization|cookie|password|secret|token)", re.IGNORECASE
)
REDACTED = "[REDACTED]"


class SecurityViolation(PermissionError):
    """Raised when an MCP request falls outside an explicit allowlist."""


def _configured_items(name: str) -> tuple[str, ...]:
    return tuple(item.strip() for item in os.getenv(name, "").split(",") if item.strip())


def allowed_roots() -> tuple[Path, ...]:
    """Return resolved roots configured for MCP file access."""
    return tuple(Path(item).expanduser().resolve() for item in _configured_items("FORGE_MCP_ALLOWED_ROOTS"))


def require_allowed_path(path: str | Path, roots: Iterable[Path] | None = None) -> Path:
    """Resolve a path and reject it unless it is inside an allowed root."""
    resolved = Path(path).expanduser().resolve()
    configured_roots = tuple(roots) if roots is not None else allowed_roots()
    if not configured_roots:
        raise SecurityViolation("No file roots are allowlisted")
    if not any(resolved == root or resolved.is_relative_to(root) for root in configured_roots):
        raise SecurityViolation(f"Path is outside the allowlist: {resolved}")
    return resolved


def require_allowed_command(command: str) -> str:
    """Reject shell syntax and executables absent from the command allowlist."""
    if any(token in command for token in (";", "&&", "||", "|", "`", "$(", "\n")):
        raise SecurityViolation("Shell composition is not allowed")
    executable = command.split(maxsplit=1)[0] if command.strip() else ""
    if executable not in _configured_items("FORGE_MCP_ALLOWED_COMMANDS"):
        raise SecurityViolation(f"Command is not allowlisted: {executable or '<empty>'}")
    return command


def redact_secrets(value: Any) -> Any:
    """Recursively redact values whose keys commonly contain secrets."""
    if isinstance(value, dict):
        return {
            key: REDACTED if SECRET_KEY_PATTERN.search(str(key)) else redact_secrets(item)
            for key, item in value.items()
        }
    if isinstance(value, list):
        return [redact_secrets(item) for item in value]
    if isinstance(value, tuple):
        return tuple(redact_secrets(item) for item in value)
    return value


def audit_log(action: str, outcome: str, details: dict[str, Any] | None = None) -> None:
    """Append a redacted JSON audit event; fail closed if no log is configured."""
    log_path = os.getenv("FORGE_MCP_AUDIT_LOG")
    if not log_path:
        raise SecurityViolation("FORGE_MCP_AUDIT_LOG must be configured")
    destination = Path(log_path).expanduser()
    destination.parent.mkdir(parents=True, exist_ok=True)
    event = {
        "timestamp": datetime.now(UTC).isoformat(),
        "action": action,
        "outcome": outcome,
        "details": redact_secrets(details or {}),
    }
    with destination.open("a", encoding="utf-8") as stream:
        stream.write(json.dumps(event, sort_keys=True) + "\n")
EOF

create_file mcp/forge-server/src/forge_mcp/tools.py <<'EOF'
"""Declared Forge MCP tool surface.

Mutation and operational tools intentionally remain disabled until Forge has
authentication, authorization, approvals, sandboxing, and deployment adapters.
"""

from __future__ import annotations

from pathlib import Path
from typing import NoReturn

from .security import audit_log, require_allowed_path


def _not_implemented(tool: str) -> NoReturn:
    audit_log(tool, "denied", {"reason": "placeholder tool is disabled"})
    raise NotImplementedError(f"{tool} is scaffolded but not enabled")


def list_project_files(project_path: str) -> list[str]:
    root = require_allowed_path(project_path)
    files = [str(path.relative_to(root)) for path in root.rglob("*") if path.is_file()]
    audit_log("list_project_files", "allowed", {"path": str(root), "count": len(files)})
    return sorted(files)


def read_file(path: str) -> str:
    source = require_allowed_path(path)
    content = source.read_text(encoding="utf-8")
    audit_log("read_file", "allowed", {"path": str(source), "bytes": len(content.encode())})
    return content


def write_file(path: str, content: str) -> NoReturn:
    require_allowed_path(path)
    _not_implemented("write_file")


def run_command(command: str) -> NoReturn:
    _not_implemented("run_command")


def git_status(project_path: str) -> NoReturn:
    require_allowed_path(project_path)
    _not_implemented("git_status")


def git_commit(project_path: str, message: str) -> NoReturn:
    require_allowed_path(project_path)
    _not_implemented("git_commit")


def deploy_app(app_name: str) -> NoReturn:
    _not_implemented("deploy_app")


def restart_service(service_name: str) -> NoReturn:
    _not_implemented("restart_service")


def view_logs(service_name: str, lines: int = 100) -> NoReturn:
    _not_implemented("view_logs")


def upload_asset(destination: str, content: bytes) -> NoReturn:
    require_allowed_path(Path(destination))
    _not_implemented("upload_asset")
EOF

create_file mcp/forge-server/src/forge_mcp/server.py <<'EOF'
"""Forge MCP server entry point."""

from mcp.server.fastmcp import FastMCP

from . import tools

mcp = FastMCP("Forge")
mcp.tool()(tools.list_project_files)
mcp.tool()(tools.read_file)


def main() -> None:
    """Run the initial read-only MCP server over stdio."""
    mcp.run()


if __name__ == "__main__":
    main()
EOF

create_readme docs Documentation "Architecture notes, decisions, and operational runbooks live here."
create_readme docs/architecture Architecture "Current system boundaries and repository conventions."
create_readme docs/decisions "Architecture Decisions" "Immutable decision records explain why Forge is structured as it is."
create_readme docs/runbooks Runbooks "Repeatable local-development and production operating procedures."

create_file docs/architecture/overview.md <<'EOF'
# Architecture Overview

Forge is a modular monorepo deployed to a VPS. Next.js applications consume shared UI and domain packages and call the FastAPI platform service. Postgres is the durable store, with a pgvector-ready image for future embeddings. Redis is reserved for caching, queues, and ephemeral coordination. The Forge MCP server will eventually provide a constrained control plane for Codex and trusted operators.

Dependencies flow inward: projects and apps may depend on packages and core services; core services must never depend on a project. Metadata in `projects/` describes deployments but contains no application implementation.
EOF

create_file docs/architecture/repo-rules.md <<'EOF'
# Repository Rules

1. Do not put experiments directly into `apps/`.
2. Promote experiments only when stable.
3. Shared code goes into `packages/`.
4. Stable platform logic goes into `core/`.
5. Project-specific logic stays in project app folders under `apps/`.
6. Project metadata lives in `projects/`.
7. `apps/` contains real, deployable applications.
8. `projects/` contains metadata and documentation only.
9. A project may depend on Forge, but Forge core must not depend on a project.
10. Prefer extending an existing package or service over creating a new top-level repository.
EOF

create_file docs/decisions/0001-monorepo-structure.md <<'EOF'
# ADR 0001: Use a Forge Monorepo

- Status: Accepted
- Date: 2026-06-21

## Context

The previous Athena setup made it easy for related tools and deployment logic to spread across repositories. Forge must onboard future projects without repeating that sprawl.

## Decision

Use one monorepo with explicit boundaries for deployable apps, stable platform services, reusable packages, project metadata, disposable experiments, infrastructure, MCP servers, and documentation.

## Consequences

Shared changes can be coordinated in one place and repository rules are visible. Teams must maintain dependency direction: project code may consume Forge, while Forge core remains project-independent.
EOF

create_file docs/runbooks/local-dev.md <<'EOF'
# Local Development

1. Install Docker with the Compose plugin, Python 3.11+, and Node.js 20+.
2. Copy `.env.example` to `.env` and replace placeholder secrets.
3. Run `./scripts/bootstrap.sh` for local environment checks.
4. Run `./scripts/dev.sh` to start Postgres, Redis, the API, and MCP placeholder.
5. Verify the API at `http://localhost:8000/health`.

Applications are scaffolded as folders only; initialize each Next.js application when product work begins.
EOF

create_file docs/runbooks/deployment.md <<'EOF'
# Deployment

Forge targets a Docker Compose-managed VPS behind nginx.

Before production deployment, configure secrets outside Git, restrict exposed ports, add TLS, pin image versions, enable backups, and implement authenticated MCP authorization and sandboxing. Deployment and restart MCP tools remain disabled in this scaffold.
EOF

create_file scripts/README.md <<'EOF'
# Scripts

Common developer entry points live here. Scripts should be safe to rerun and should delegate complex logic to tested tooling.
EOF

create_file scripts/bootstrap.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo 'Created .env from .env.example; review secrets before deployment.'
fi

docker compose config --quiet
echo 'Forge bootstrap checks passed.'
EOF

create_file scripts/dev.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
docker compose up --build
EOF

create_file scripts/format.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if command -v ruff >/dev/null 2>&1; then
  ruff format core mcp/forge-server/src
fi
if [[ -f package.json ]]; then
  npm run format --if-present
fi
EOF

create_file scripts/test.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

python -m compileall -q core mcp/forge-server/src
if command -v pytest >/dev/null 2>&1; then
  pytest
fi
if [[ -f package.json ]]; then
  npm test --if-present
fi
EOF

chmod +x "$ROOT/scripts/bootstrap.sh" "$ROOT/scripts/dev.sh" "$ROOT/scripts/format.sh" "$ROOT/scripts/test.sh"

echo "Forge scaffold is ready at $ROOT"
