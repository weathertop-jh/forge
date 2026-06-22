#!/usr/bin/env bash
set -euo pipefail

SCRIPT=${1:?usage: scaffold_test.sh /path/to/create-forge-scaffold.sh}
ROOT=$(mktemp -d "${TMPDIR:-/tmp}/forge-scaffold-test.XXXXXX")
trap 'rm -rf "$ROOT"' EXIT

"$SCRIPT" "$ROOT"

required_dirs=(
  apps/landing-dashboard apps/prompt-dashboard apps/forge-dashboard
  apps/rag-playground apps/evals-dashboard core/api core/auth core/db core/mcp
  core/deploy packages/forge-sdk packages/ui packages/rag-utils
  packages/eval-utils projects/landing-dashboard projects/prompt-dashboard
  projects/rag-playground projects/evals-dashboard experiments infra/docker infra/nginx
  infra/scripts mcp/forge-server/src/forge_mcp docs/architecture docs/decisions
  docs/runbooks scripts
)

required_files=(
  README.md .env.example .gitignore docker-compose.yml core/api/main.py
  core/db/README.md mcp/forge-server/README.md mcp/forge-server/pyproject.toml
  mcp/forge-server/src/forge_mcp/__init__.py
  mcp/forge-server/src/forge_mcp/server.py
  mcp/forge-server/src/forge_mcp/tools.py
  mcp/forge-server/src/forge_mcp/security.py
  projects/landing-dashboard/project.yaml projects/prompt-dashboard/project.yaml
  projects/rag-playground/project.yaml projects/evals-dashboard/project.yaml
  docs/architecture/overview.md docs/architecture/repo-rules.md
  docs/decisions/0001-monorepo-structure.md docs/runbooks/local-dev.md
  docs/runbooks/deployment.md scripts/bootstrap.sh scripts/dev.sh
  scripts/format.sh scripts/test.sh
)

for path in "${required_dirs[@]}"; do
  test -d "$ROOT/$path" || { echo "missing directory: $path" >&2; exit 1; }
done

for path in "${required_files[@]}"; do
  test -f "$ROOT/$path" || { echo "missing file: $path" >&2; exit 1; }
done

grep -q '@app.get("/health")' "$ROOT/core/api/main.py"
grep -q 'pgvector' "$ROOT/core/db/README.md"
for service in postgres redis api mcp; do
  grep -q "^  $service:" "$ROOT/docker-compose.yml"
done

for tool in list_project_files read_file write_file run_command git_status git_commit deploy_app restart_service view_logs upload_asset; do
  grep -q "def $tool" "$ROOT/mcp/forge-server/src/forge_mcp/tools.py" || {
    echo "missing MCP tool placeholder: $tool" >&2
    exit 1
  }
done

printf '%s\n' 'user-edited-content' > "$ROOT/README.md"
"$SCRIPT" "$ROOT"
test "$(cat "$ROOT/README.md")" = 'user-edited-content' || {
  echo 'rerun overwrote an existing file' >&2
  exit 1
}

echo 'scaffold verification passed'
