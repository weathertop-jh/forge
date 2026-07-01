# Forge UI Visual Engine Design

## Purpose

Create Forge's sole reusable UI package at `packages/ui` by migrating the existing `packages/ui-components` scaffold and implementing app-agnostic primitives for spatial node interfaces. The package translates the visual rules in `docs/design/landing-dashboard-visual-system.md` into typed React components, deterministic layout utilities, interaction hooks, design tokens, and motion presets.

The first consumer will be the landing dashboard, but the package must not contain its labels, topology, routes, or project-specific behavior.

## Scope

The package will provide:

- semantic central, tier, and leaf node controls;
- SVG connection threads;
- reusable glow treatments;
- controlled and uncontrolled locked and expanded state primitives;
- a deterministic particle field;
- hybrid HTML/SVG graph composition;
- deterministic radial and explicit-position layout utilities;
- shared interaction and reduced-motion hooks;
- CSS custom-property tokens for the Forge visual system;
- package-level tests, TypeScript validation, and documented exports.

The package will not provide routing, content, application topology, zoom or pan controls, force simulation, canvas rendering, data fetching, or a landing-dashboard composition.

## Migration

`packages/ui-components` will be renamed to `packages/ui`; no duplicate UI package will remain. Its README intent will be preserved and expanded for the new visual engine.

Every repository reference to the old path or dependency name will change:

- project manifests will depend on `ui` instead of `ui-components`;
- scaffold generation and scaffold tests will create and expect `packages/ui`;
- documentation references will use the new package name;
- the npm package name will be `@forge/ui`;
- no import, manifest, script, or documentation reference may retain `ui-components`.

Because this changes the repository's shared-package convention, the migration will be recorded in the relevant repository decision documentation. It does not change an app's scope or runtime behavior.

## Package Structure

```text
packages/ui/
├── components/
│   ├── glow/
│   ├── graph/
│   ├── node/
│   ├── particles/
│   └── thread/
├── hooks/
├── lib/
├── styles/
├── index.ts
├── package.json
├── tsconfig.json
├── vitest.config.ts
└── README.md
```

Tests live beside the module they verify. Each component folder exports through a local barrel, and the package root exposes the supported public surface. Internal helpers are not exported accidentally.

## Rendering Architecture

The package uses a hybrid layered graph:

1. `ParticleField` provides the non-interactive atmosphere at the back.
2. An SVG layer renders `ConnectionThread` paths in the graph coordinate space.
3. An HTML layer positions semantic node controls over the same coordinates.
4. Optional consumer content or controls occupy a separate foreground slot.

`GraphLayout` owns the shared coordinate system and layer ordering. Layout utilities produce positions; rendering components consume them. This prevents visual components from embedding a layout algorithm and allows future algorithms to be added without replacing the accessible controls.

All graph coordinates use a normalized `0–1` space. `GraphLayout` maps them into its measured content bounds, applying a configurable safe-area inset. This keeps graph data independent of pixels and makes server rendering deterministic before the container is measured.

## Graph Model and Data Flow

The public graph model is generic:

```ts
type GraphNodeId = string;

interface GraphNode<TData = unknown> {
  id: GraphNodeId;
  parentId?: GraphNodeId;
  tier: "central" | "tier" | "leaf";
  position?: NormalizedPoint;
  data?: TData;
}

interface GraphEdge {
  id: string;
  sourceId: GraphNodeId;
  targetId: GraphNodeId;
}
```

Consumers retain ownership of labels and behavior. The layout layer returns stable positioned nodes and resolved edges without mutating input objects.

The initial radial algorithm requires one central node and places direct children across deterministic angular sectors. Descendants are placed within their parent's sector and closer to their parent than the parent's distance from the center. Explicit positions override generated positions. Input order is stabilized by node ID so the same topology and options always produce the same output.

The utility validates duplicate IDs, missing edge endpoints, invalid parent references, multiple central nodes, and parent cycles. Development builds provide descriptive errors. Pure layout functions return a typed result with issues so applications can decide whether to render partial output; `GraphLayout` does not silently invent missing relationships.

## Component API

### Nodes

`CentralNode`, `TierNode`, and `LeafNode` share a typed base API for:

- `label` and accessible naming;
- link or button semantics;
- disabled state;
- active, hovered, focused, locked, expanded, and contextually dimmed visual state;
- normalized position when used inside `GraphLayout`;
- consumer class names, style, and safe event handlers;
- Framer Motion props through a constrained extension point.

Each tier applies its own size, typography, luminance, and halo defaults. Consumers may theme those defaults through CSS variables but cannot change semantic tier behavior accidentally. Visible node bodies remain smaller than their minimum 44 px interactive target.

### ConnectionThread

`ConnectionThread` renders an SVG path from source and target points. The default organic curve uses a deterministic perpendicular offset derived from the edge ID, producing variation without randomness or hard elbows. Props control resting, active, dimmed, and disabled states. An optional signal layer animates from parent to child and is removed under reduced motion.

### HoverGlow

`HoverGlow` provides a composable halo whose color, strength, radius, and active state map to semantic CSS variables. It is decorative and excluded from the accessibility tree. Glow never replaces the crisp keyboard focus indicator.

### LockedState and ExpandState

These components use a render-prop/context pattern and support both controlled and uncontrolled operation:

- controlled: `value` plus `onValueChange`;
- uncontrolled: `defaultValue` plus internal state;
- keyboard dismissal through Escape;
- stable context selectors for descendant nodes and threads.

They do not enforce routing or determine which content appears. `LockedState` tracks the dominant group ID. `ExpandState` tracks a set of expanded group IDs and supports single or multiple expansion modes.

### ParticleField

`ParticleField` renders a seeded set of decorative particles using CSS-positioned elements. Seed, density, depth, and drift intensity are configurable. A fixed seed produces identical markup across server and client rendering. The field is pointer-transparent, hidden from assistive technology, and static under reduced motion.

### GraphLayout

`GraphLayout` provides:

- the measured normalized coordinate space;
- atmosphere, thread, node, and foreground slots;
- safe-area and aspect-ratio handling;
- graph context for position lookup and interaction state;
- optional radial generation or consumer-supplied positions;
- deterministic layer ordering and SVG definitions.

It does not render application nodes automatically. Consumers compose the specific node and thread primitives, retaining full control over labels, links, and semantics.

## Interaction Hooks

`useGraphInteraction` manages hover, focus, locked group, and expanded groups with controlled-state escape hatches. It exposes event-prop getters so pointer and keyboard behavior can be attached without overwriting consumer handlers.

`useReducedMotion` wraps the Framer Motion preference and produces stable package-level motion decisions.

`useGraphLayout` memoizes validation and position generation for generic graph data. Layout computation depends only on graph content and explicit options, not DOM measurements.

Hooks throw descriptive errors when used outside required providers. Optional hooks expose `null` where composition outside a provider is intentionally supported.

## Motion Presets

Motion definitions live in `lib/motion.ts` and are exported as reusable Framer Motion variants and transitions:

- node hover: 160–240 ms scale and luminance response;
- node press: short inward compression;
- group selection: 420–650 ms emphasis and contextual dimming;
- travelling signal: 500–900 ms parent-to-child path motion;
- central respiration: 4–6 second low-amplitude loop;
- particle drift: 12–30 second low-amplitude loop;
- reduced motion: immediate or at most 100 ms opacity changes.

Presets use smooth asymmetric easing and no bounce or elastic overshoot. Consumers may override duration through documented options without rebuilding variants.

## Styling and Theming

`styles/forge-ui.css` defines semantic custom properties for substrate, depth, dormant threads, active energy, secondary bloom, peak highlights, muted text, node sizes, focus rings, glow radii, and layer indices.

Component styles use Tailwind utilities for structure and CSS variables for theme values. The package declares the source paths consumers must include in Tailwind content scanning and exports the stylesheet explicitly. It does not ship a Tailwind preset or assume a particular application configuration in this version.

The package does not bundle fonts. Its README documents the preferred Space Grotesk and IBM Plex Mono roles and supplies robust fallbacks.

## Accessibility

- Node components render real anchors or buttons, never clickable generic elements.
- Keyboard focus uses a crisp high-contrast ring in addition to glow.
- Disabled, expanded, and pressed states map to appropriate ARIA attributes.
- DOM order remains consumer-defined and should follow semantic hierarchy rather than visual coordinates.
- Decorative layers are inert, pointer-transparent, and hidden from assistive technology.
- Motion respects reduced-motion preferences at both component and preset levels.
- Components remain operable at browser zoom and do not require hover.
- Graph context never traps focus or replaces standard Tab behavior.

## Testing and Validation

Implementation follows test-driven development. Tests cover:

- correct button and anchor semantics for every node tier;
- accessible names, focus visibility hooks, disabled behavior, and ARIA state;
- controlled and uncontrolled lock and expansion behavior;
- Escape dismissal without overwriting consumer handlers;
- deterministic radial positions and particle output;
- hierarchy validation, duplicate IDs, missing endpoints, and cycles;
- deterministic organic path generation;
- reduced-motion variants and static particles;
- GraphLayout layer ordering and normalized positioning;
- root package exports and stylesheet export;
- repository migration with no remaining `ui-components` references;
- scaffold generation and rerun behavior after the package rename.

Validation includes package unit tests, TypeScript checking, repository shell tests, and a repository-wide reference scan. No app build is required until a consuming app exists, but the package itself must type-check and test independently.

## Extensibility

Future layout algorithms implement the same positioned-graph result contract. Zoom, pan, progressive disclosure, spatial keyboard navigation, and canvas acceleration can be layered onto `GraphLayout` later without changing node or edge data. The normalized coordinate model and controlled state APIs are the compatibility boundary for that growth.

Physics simulation is intentionally deferred. Stable deterministic positions preserve spatial memory and make server rendering, testing, and accessibility more reliable for the initial system.
