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
