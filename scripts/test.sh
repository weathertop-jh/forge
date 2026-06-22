#!/usr/bin/env bash
set -euo pipefail

bash tests/new_project_test.sh

python -m compileall -q core mcp/forge-server/src
if command -v pytest >/dev/null 2>&1; then
  pytest
fi
if [[ -f package.json ]]; then
  npm test --if-present
fi
