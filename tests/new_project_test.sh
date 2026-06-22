#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SOURCE_SCRIPT="$REPO_ROOT/scripts/new-project.sh"
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/forge-new-project-test.XXXXXX")
trap 'rm -rf "$TEST_ROOT"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

new_repo() {
  local root
  root=$(mktemp -d "$TEST_ROOT/repo.XXXXXX")
  mkdir -p "$root/scripts"
  cp "$SOURCE_SCRIPT" "$root/scripts/new-project.sh"
  chmod +x "$root/scripts/new-project.sh"
  echo "$root"
}

assert_dir() {
  [[ -d $1 ]] || fail "missing directory: $1"
}

assert_file() {
  [[ -f $1 ]] || fail "missing file: $1"
}

assert_contains() {
  local file=$1
  local expected=$2
  grep -Fqx -- "$expected" "$file" || fail "$file does not contain: $expected"
}

success_root=$(new_repo)
success_output="$success_root/output.txt"
(
  cd "$success_root"
  ./scripts/new-project.sh rag-lab rag >"$success_output"
)

assert_dir "$success_root/apps/rag-lab"
assert_dir "$success_root/projects/rag-lab"
for filename in project.yaml README.md backlog.md decisions.md; do
  assert_file "$success_root/projects/rag-lab/$filename"
done

yaml="$success_root/projects/rag-lab/project.yaml"
assert_contains "$yaml" 'name: rag-lab'
assert_contains "$yaml" 'type: rag'
assert_contains "$yaml" 'status: planned'
assert_contains "$yaml" 'visibility: private'
assert_contains "$yaml" 'description: ""'
assert_contains "$yaml" 'entrypoints: []'
assert_contains "$yaml" 'dependencies: []'
assert_contains "$yaml" 'services: []'
assert_contains "$yaml" "created_at: $(date -u +%Y-%m-%d)"
assert_contains "$yaml" 'notes: ""'

for path in \
  'apps/rag-lab/' \
  'projects/rag-lab/' \
  'projects/rag-lab/project.yaml' \
  'projects/rag-lab/README.md' \
  'projects/rag-lab/backlog.md' \
  'projects/rag-lab/decisions.md'; do
  grep -Fq -- "$path" "$success_output" || fail "output does not list: $path"
done

missing_root=$(new_repo)
if (cd "$missing_root" && ./scripts/new-project.sh >output.txt 2>&1); then
  fail 'missing arguments were accepted'
fi
[[ ! -e $missing_root/apps && ! -e $missing_root/projects ]] || fail 'missing arguments created project folders'

for invalid_name in Uppercase 'has space' -leading trailing- double--hyphen under_score; do
  invalid_root=$(new_repo)
  if (cd "$invalid_root" && ./scripts/new-project.sh "$invalid_name" rag >output.txt 2>&1); then
    fail "invalid project name was accepted: $invalid_name"
  fi
  [[ ! -e $invalid_root/apps && ! -e $invalid_root/projects ]] || fail "invalid name created project folders: $invalid_name"
done

empty_type_root=$(new_repo)
if (cd "$empty_type_root" && ./scripts/new-project.sh valid-name '' >output.txt 2>&1); then
  fail 'empty project type was accepted'
fi
[[ ! -e $empty_type_root/apps && ! -e $empty_type_root/projects ]] || fail 'empty project type created project folders'

app_collision_root=$(new_repo)
mkdir -p "$app_collision_root/apps/taken"
printf '%s\n' 'keep me' >"$app_collision_root/apps/taken/sentinel.txt"
if (cd "$app_collision_root" && ./scripts/new-project.sh taken rag >output.txt 2>&1); then
  fail 'existing application directory was accepted'
fi
assert_contains "$app_collision_root/apps/taken/sentinel.txt" 'keep me'
[[ ! -e $app_collision_root/projects/taken ]] || fail 'application collision created a project directory'

project_collision_root=$(new_repo)
mkdir -p "$project_collision_root/projects/taken"
printf '%s\n' 'keep me' >"$project_collision_root/projects/taken/sentinel.txt"
if (cd "$project_collision_root" && ./scripts/new-project.sh taken rag >output.txt 2>&1); then
  fail 'existing project directory was accepted'
fi
assert_contains "$project_collision_root/projects/taken/sentinel.txt" 'keep me'
[[ ! -e $project_collision_root/apps/taken ]] || fail 'project collision created an application directory'

echo 'new-project validation passed'
