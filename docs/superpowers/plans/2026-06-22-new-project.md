# New Project Scaffolding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a safe Bash command that creates the standard Forge application and project metadata structure.

**Architecture:** A self-contained repository-root-aware Bash script validates all input and collisions before creating directories and template files. A shell integration test runs the command in temporary repositories and checks success, validation failures, and atomic collision behavior.

**Tech Stack:** Bash, standard Unix utilities, Markdown, YAML templates

## Global Constraints

- Usage is `./scripts/new-project.sh <project-name> <project-type>`.
- Project names use lowercase letters, numbers, and hyphens only, with no spaces.
- Existing application or project directories must never be overwritten.
- Failed validation or collision checks must not create partial project folders.
- `description` and `notes` are empty YAML strings.

---

### Task 1: Executable behavior and integration tests

**Files:**
- Create: `tests/new_project_test.sh`
- Create: `scripts/new-project.sh`

**Interfaces:**
- Consumes: two CLI arguments, `<project-name>` and `<project-type>`
- Produces: `apps/<project-name>/` and four files under `projects/<project-name>/`

- [ ] **Step 1: Write the failing integration test**

Create `tests/new_project_test.sh` with helpers that create temporary repository roots, copy the production script into `scripts/`, and fail with a descriptive assertion. Cover:

```bash
#!/usr/bin/env bash
set -euo pipefail

SOURCE_SCRIPT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/scripts/new-project.sh
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/forge-new-project-test.XXXXXX")
trap 'rm -rf "$TEST_ROOT"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }
new_repo() { local root; root=$(mktemp -d "$TEST_ROOT/repo.XXXXXX"); mkdir -p "$root/scripts"; cp "$SOURCE_SCRIPT" "$root/scripts/new-project.sh"; echo "$root"; }

# Success: required directories/files, YAML values, and output paths.
# Validation: missing arguments and representative invalid names fail without mutation.
# Collisions: pre-existing apps/name or projects/name fails without creating its counterpart.

echo 'new-project validation passed'
```

Use real process execution and filesystem assertions rather than mocked behavior.

- [ ] **Step 2: Run the test to verify it fails**

Run: `bash tests/new_project_test.sh`

Expected: FAIL because `scripts/new-project.sh` does not exist.

- [ ] **Step 3: Implement the minimal scaffolding script**

Create `scripts/new-project.sh` with this control flow:

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() { echo "Usage: $0 <project-name> <project-type>" >&2; }

[[ $# -eq 2 ]] || { usage; exit 2; }
project_name=$1
project_type=$2
[[ $project_name =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || { echo "Error: invalid project name: $project_name" >&2; exit 2; }
[[ -n $project_type ]] || { echo 'Error: project type must not be empty.' >&2; exit 2; }

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
app_dir="$repo_root/apps/$project_name"
project_dir="$repo_root/projects/$project_name"
[[ ! -e $app_dir && ! -e $project_dir ]] || { echo "Error: project already exists: $project_name" >&2; exit 1; }

# Create both directories, write project.yaml and the three Markdown templates,
# then print each created path and the completion summary.
```

The YAML template must contain the exact field order and defaults from the design spec. Use `date -u +%Y-%m-%d` for `created_at`.

- [ ] **Step 4: Make both files executable and run the test**

Run: `chmod +x scripts/new-project.sh tests/new_project_test.sh && bash tests/new_project_test.sh`

Expected: `new-project validation passed` with exit status 0.

### Task 2: Runbook and standard test integration

**Files:**
- Create: `docs/runbooks/new-project.md`
- Modify: `scripts/test.sh`

**Interfaces:**
- Consumes: the command and test from Task 1
- Produces: user documentation and inclusion in the standard Forge test command

- [ ] **Step 1: Add the runbook**

Document command usage and example, naming rules, generated paths, YAML defaults, strict overwrite protection, and the direct validation command.

- [ ] **Step 2: Add the shell test to the standard test runner**

Append `bash tests/new_project_test.sh` to `scripts/test.sh` so normal repository validation covers the new command.

- [ ] **Step 3: Verify direct and repository-wide tests**

Run: `bash tests/new_project_test.sh`

Expected: `new-project validation passed` with exit status 0.

Run: `bash scripts/test.sh`

Expected: all existing checks pass and output includes `new-project validation passed`.

- [ ] **Step 4: Check the final diff**

Run: `git diff --check && git status --short`

Expected: no whitespace errors; only the planned files are changed or added.
