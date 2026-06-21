#!/usr/bin/env bash
set -euo pipefail

if command -v ruff >/dev/null 2>&1; then
  ruff format core mcp/forge-server/src
fi
if [[ -f package.json ]]; then
  npm run format --if-present
fi
