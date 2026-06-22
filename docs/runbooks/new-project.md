# Create a New Project

Use the project scaffolding command to create a Forge application directory and its matching project metadata.

## Usage

Run the command from anywhere inside the repository:

```bash
./scripts/new-project.sh <project-name> <project-type>
```

For example:

```bash
./scripts/new-project.sh rag-lab rag
```

Project names must contain lowercase letters, numbers, and single hyphens only. They cannot contain spaces, uppercase letters, underscores, leading or trailing hyphens, or repeated hyphens.

## Generated structure

For the example above, the command creates:

```text
apps/rag-lab/
projects/rag-lab/
├── README.md
├── backlog.md
├── decisions.md
└── project.yaml
```

The generated `project.yaml` starts with `planned` status and `private` visibility. Its description and notes are empty strings, while entrypoints, dependencies, and services are empty lists. `created_at` records the current UTC date.

## Overwrite protection

The command exits without creating anything if either `apps/<project-name>/` or `projects/<project-name>/` already exists. It never overwrites an existing project structure. Resolve the collision or choose a different project name before rerunning the command.

## Validation

Run the dedicated integration test with:

```bash
bash tests/new_project_test.sh
```

A successful run prints `new-project validation passed`.
