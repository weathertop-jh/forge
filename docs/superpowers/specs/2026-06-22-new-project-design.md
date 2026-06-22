# New Project Scaffolding Design

## Purpose

Add a standard command for onboarding Forge projects consistently:

```bash
./scripts/new-project.sh <project-name> <project-type>
```

The command creates the deployable application directory and its matching project metadata and documentation directory.

## Command behavior

`scripts/new-project.sh` will be a self-contained Bash script using `set -euo pipefail`. It will require exactly two non-empty arguments. The project name must match `^[a-z0-9]+(-[a-z0-9]+)*$`, which permits lowercase letters, numbers, and single separating hyphens while rejecting spaces, uppercase characters, leading or trailing hyphens, and repeated hyphens. The project type is stored as supplied and must be non-empty.

Validation and collision checks happen before any filesystem mutation. If either `apps/<project-name>` or `projects/<project-name>` exists, the command exits unsuccessfully and creates nothing. This strict check prevents partial or mismatched project structures.

On success the command creates:

- `apps/<project-name>/`
- `projects/<project-name>/`
- `projects/<project-name>/project.yaml`
- `projects/<project-name>/README.md`
- `projects/<project-name>/backlog.md`
- `projects/<project-name>/decisions.md`

It prints a clear line for every created directory and file, followed by a success summary.

## Generated content

`project.yaml` uses top-level fields and records the creation date in UTC as `YYYY-MM-DD`:

```yaml
name: <project-name>
type: <project-type>
status: planned
visibility: private
description: ""
entrypoints: []
dependencies: []
services: []
created_at: <YYYY-MM-DD>
notes: ""
```

The README identifies the project and points to its application directory. `backlog.md` and `decisions.md` contain headings and short prompts so they are immediately usable without inventing a more elaborate workflow.

## Testing and documentation

`tests/new_project_test.sh` runs the real script against isolated temporary repositories. It verifies successful creation, required YAML values, terminal output, invalid-name rejection, missing-argument rejection, and strict collision handling for both application and project directories. Collision tests also verify that no counterpart directory is created.

`docs/runbooks/new-project.md` documents usage, naming rules, generated paths, metadata defaults, overwrite behavior, and how to run the validation test.

The script and test are executable. The repository's existing `scripts/test.sh` will invoke the new shell test so the validation is included in the normal test entry point.
