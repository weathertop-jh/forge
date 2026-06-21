#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo 'Created .env from .env.example; review secrets before deployment.'
fi

docker compose config --quiet
echo 'Forge bootstrap checks passed.'
