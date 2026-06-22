#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <project-name> <project-type>" >&2
}

if [[ $# -ne 2 ]]; then
  usage
  exit 2
fi

project_name=$1
project_type=$2

if [[ ! $project_name =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "Error: project-name must contain lowercase letters, numbers, and single hyphens only." >&2
  exit 2
fi

if [[ -z $project_type ]]; then
  echo "Error: project-type must not be empty." >&2
  exit 2
fi

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
app_dir="$repo_root/apps/$project_name"
project_dir="$repo_root/projects/$project_name"

if [[ -e $app_dir ]]; then
  echo "Error: application folder already exists: apps/$project_name" >&2
  exit 1
fi

if [[ -e $project_dir ]]; then
  echo "Error: project folder already exists: projects/$project_name" >&2
  exit 1
fi

created_at=$(date -u +%Y-%m-%d)

mkdir -p "$app_dir" "$project_dir"
echo "Created: apps/$project_name/"
echo "Created: projects/$project_name/"

cat >"$project_dir/project.yaml" <<EOF
name: $project_name
type: $project_type
status: planned
visibility: private
description: ""
entrypoints: []
dependencies: []
services: []
created_at: $created_at
notes: ""
EOF
echo "Created: projects/$project_name/project.yaml"

cat >"$project_dir/README.md" <<EOF
# $project_name

Project metadata and operator notes for **$project_name**.

Application source lives in \`apps/$project_name/\`.
EOF
echo "Created: projects/$project_name/README.md"

cat >"$project_dir/backlog.md" <<EOF
# $project_name Backlog

Track planned work and open tasks for this project here.
EOF
echo "Created: projects/$project_name/backlog.md"

cat >"$project_dir/decisions.md" <<EOF
# $project_name Decisions

Record significant project decisions and their rationale here.
EOF
echo "Created: projects/$project_name/decisions.md"

echo "Project '$project_name' created successfully."
