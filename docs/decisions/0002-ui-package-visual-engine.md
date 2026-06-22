# ADR 0002: Use One Deterministic Forge UI Visual Engine

- Status: Accepted
- Date: 2026-06-22

## Context

Forge needs reusable primitives for spatial node interfaces. The former UI component scaffold named a broad responsibility but contained no implementation.

## Decision

Rename the sole shared UI package to `packages/ui` with npm identity `@forge/ui`. Render graph interfaces with aligned HTML node, SVG thread, and decorative atmosphere layers. Keep layout and particles deterministic and keep application content outside the package.

## Consequences

Forge apps share one accessible visual engine without copying node behavior. Stable normalized coordinates support server rendering and tests. Physics, zoom, pan, and app-specific topology remain deferred and can build on the same component contracts later.
