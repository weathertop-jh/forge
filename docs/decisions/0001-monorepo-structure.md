# ADR 0001: Use a Forge Monorepo

- Status: Accepted
- Date: 2026-06-21

## Context

The previous Athena setup made it easy for related tools and deployment logic to spread across repositories. Forge must onboard future projects without repeating that sprawl.

## Decision

Use one monorepo with explicit boundaries for deployable apps, stable platform services, reusable packages, project metadata, disposable experiments, infrastructure, MCP servers, and documentation.

## Consequences

Shared changes can be coordinated in one place and repository rules are visible. Teams must maintain dependency direction: project code may consume Forge, while Forge core remains project-independent.
