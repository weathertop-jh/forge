# Forge UI Visual Engine Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate Forge's existing UI scaffold to `packages/ui` and build a small, app-agnostic React visual engine for accessible node graphs.

**Architecture:** `GraphCanvas` aligns a decorative particle layer, SVG connection layer, and semantic HTML node layer in one normalized coordinate system. Pure TypeScript helpers validate and position graph data; React hooks own optional interaction state; components expose Tailwind structure, CSS-variable theming, and Framer Motion behavior without application content.

**Tech Stack:** React 19, TypeScript 6, Tailwind CSS 4, Motion for React 12 (the current Framer Motion package), Vitest 4, Testing Library 16, jsdom 29.

## Global Constraints

- Follow the repository `AGENTS.md` and preserve existing user changes.
- Rename `packages/ui-components` to `packages/ui`; never leave duplicate UI packages.
- Keep all package components, hooks, data types, styles, and examples app-agnostic.
- Do not change or build `apps/landing-dashboard`.
- Keep React, React DOM, Motion, and Tailwind as peer dependencies; pin local development tooling.
- Use deterministic layout and particle output; do not add a force engine, canvas renderer, router, or data layer.
- Every behavior change starts with a failing test and ends with fresh tests and type checks.

---

## File Map

- `packages/ui/package.json`: package metadata, peer dependencies, exports, and scripts.
- `packages/ui/tsconfig.json`: strict React library compilation to `dist`.
- `packages/ui/vitest.config.ts`: jsdom unit-test configuration.
- `packages/ui/src/test/setup.ts`: Testing Library matchers and Motion test setup.
- `packages/ui/src/lib/types.ts`: graph, point, node-state, and layout contracts.
- `packages/ui/src/lib/class-names.ts`: dependency-free conditional class composition.
- `packages/ui/src/lib/layout.ts`: validation and deterministic radial/explicit positioning.
- `packages/ui/src/lib/path.ts`: deterministic organic SVG path generation.
- `packages/ui/src/lib/motion.ts`: visual and reduced-motion presets.
- `packages/ui/src/hooks/use-controllable-state.ts`: controlled/uncontrolled state helper.
- `packages/ui/src/hooks/use-locked-node.ts`: locked-node state and Escape dismissal.
- `packages/ui/src/hooks/use-hover-intent.ts`: delayed, pointer-safe hover intent.
- `packages/ui/src/components/node/node-base.tsx`: shared semantic node renderer.
- `packages/ui/src/components/node/{central,tier,leaf}-node.tsx`: tier-specific node APIs.
- `packages/ui/src/components/glow/glow-shell.tsx`: decorative composable halo.
- `packages/ui/src/components/thread/connection-thread.tsx`: accessible-inert SVG edge.
- `packages/ui/src/components/particles/particle-field.tsx`: seeded decorative field.
- `packages/ui/src/components/graph/graph-canvas.tsx`: layered normalized canvas and context.
- `packages/ui/src/styles/forge-ui.css`: semantic tokens and reusable component styles.
- `packages/ui/src/index.ts`: supported package exports.
- `packages/ui/README.md`: install, Tailwind source registration, styling, and examples.
- `projects/*/project.yaml`: dependency rename from `ui-components` to `ui`.
- `create-forge-scaffold.sh`: generate `packages/ui` and new manifest dependency name.
- `tests/scaffold_test.sh`: assert the migrated package name.
- `docs/decisions/0002-ui-package-visual-engine.md`: repository-wide package naming decision.

---

### Task 1: Migrate the package identity and establish the standalone toolchain

**Files:**
- Move: `packages/ui-components/README.md` to `packages/ui/README.md`
- Create: `packages/ui/package.json`
- Create: `packages/ui/tsconfig.json`
- Create: `packages/ui/vitest.config.ts`
- Create: `packages/ui/src/test/setup.ts`
- Modify: `projects/evals-dashboard/project.yaml`
- Modify: `projects/landing-dashboard/project.yaml`
- Modify: `projects/prompt-dashboard/project.yaml`
- Modify: `projects/rag-playground/project.yaml`
- Modify: `create-forge-scaffold.sh`
- Modify: `tests/scaffold_test.sh`

**Interfaces:**
- Produces package identity `@forge/ui`, source entry `src/index.ts`, stylesheet export `@forge/ui/styles.css`, and scripts `build`, `typecheck`, and `test`.

- [ ] **Step 1: Update the scaffold test first**

Change its expected package directory from `packages/ui-components` to `packages/ui` and add a repository assertion:

```bash
if rg -n 'ui-components|packages/ui-components' \
  create-forge-scaffold.sh projects packages tests docs --glob '!docs/superpowers/**'; then
  echo 'Legacy UI package reference remains' >&2
  exit 1
fi
```

- [ ] **Step 2: Verify the migration test fails**

Run: `bash tests/scaffold_test.sh`

Expected: FAIL because the generator still creates `packages/ui-components`.

- [ ] **Step 3: Move the scaffold and replace every live reference**

Use the filesystem move for the existing README, update the generator and all four manifests to `ui`, and confirm:

Run: `rg -n 'ui-components|packages/ui-components' create-forge-scaffold.sh projects packages tests docs --glob '!docs/superpowers/**'`

Expected: no matches.

- [ ] **Step 4: Create package configuration**

Use package name `@forge/ui`, ESM output, `sideEffects: ["**/*.css"]`, React/React DOM `>=18 <20`, Motion `>=12 <13`, and Tailwind `>=4 <5` peer ranges. Pin development dependencies to the versions recorded in the plan header and add `@types/react`, `@types/react-dom`, `@testing-library/jest-dom`, and `@testing-library/user-event`.

Scripts:

```json
{
  "build": "tsc -p tsconfig.json",
  "typecheck": "tsc -p tsconfig.json --noEmit",
  "test": "vitest run"
}
```

Configure strict TypeScript with `jsx: "react-jsx"`, `moduleResolution: "Bundler"`, declarations, `outDir: "dist"`, and `rootDir: "src"`. Configure Vitest for jsdom and `src/test/setup.ts`.

- [ ] **Step 5: Install package dependencies and verify the scaffold test passes**

Run: `npm install --prefix packages/ui`

Run: `bash tests/scaffold_test.sh`

Expected: PASS with no legacy package path.

---

### Task 2: Define graph contracts and deterministic layout helpers

**Files:**
- Create: `packages/ui/src/lib/types.ts`
- Create: `packages/ui/src/lib/layout.ts`
- Create: `packages/ui/src/lib/layout.test.ts`
- Create: `packages/ui/src/lib/class-names.ts`

**Interfaces:**
- Produces `NormalizedPoint`, `GraphNode`, `GraphEdge`, `PositionedGraphNode`, `GraphLayoutIssue`, `GraphLayoutResult`, `GraphLayoutOptions`, `validateGraph`, `layoutGraph`, and `cx`.

- [ ] **Step 1: Write failing layout tests**

Cover these exact behaviors:

```ts
expect(layoutGraph(nodes, edges).nodes.get("root")?.position).toEqual({ x: 0.5, y: 0.5 });
expect(layoutGraph(nodes, edges)).toEqual(layoutGraph([...nodes].reverse(), [...edges].reverse()));
expect(validateGraph(duplicateNodes, [])).toContainEqual(expect.objectContaining({ code: "duplicate-node" }));
expect(validateGraph(nodes, missingEdge)).toContainEqual(expect.objectContaining({ code: "missing-endpoint" }));
expect(validateGraph(cyclicNodes, [])).toContainEqual(expect.objectContaining({ code: "parent-cycle" }));
```

Also assert generated values remain within `[0, 1]`, explicit positions are preserved, leaves remain within their parent's angular sector, and two central nodes produce `multiple-central-nodes`.

- [ ] **Step 2: Run the tests and verify RED**

Run: `npm test --prefix packages/ui -- src/lib/layout.test.ts`

Expected: FAIL because layout modules do not exist.

- [ ] **Step 3: Implement graph types and validation**

Use generic data and typed issue codes:

```ts
export type GraphNodeTier = "central" | "tier" | "leaf";
export interface NormalizedPoint { x: number; y: number }
export interface GraphNode<T = unknown> {
  id: string;
  parentId?: string;
  tier: GraphNodeTier;
  position?: NormalizedPoint;
  data?: T;
}
export interface GraphEdge {
  id: string;
  sourceId: string;
  targetId: string;
}
```

Validation must not mutate inputs and must report all discoverable issues in one pass.

- [ ] **Step 4: Implement deterministic radial positioning**

Sort by ID before generated placement. Center the root at `{x: 0.5, y: 0.5}`. Place Tier nodes at configurable radius and start angle; place leaves inside the parent's sector at a smaller local radius. Preserve explicit positions. Return maps keyed by ID plus resolved edges and issues.

- [ ] **Step 5: Verify GREEN**

Run: `npm test --prefix packages/ui -- src/lib/layout.test.ts`

Expected: all layout tests PASS.

---

### Task 3: Add deterministic paths and motion presets

**Files:**
- Create: `packages/ui/src/lib/path.ts`
- Create: `packages/ui/src/lib/path.test.ts`
- Create: `packages/ui/src/lib/motion.ts`
- Create: `packages/ui/src/lib/motion.test.ts`

**Interfaces:**
- Consumes `NormalizedPoint`.
- Produces `createOrganicPath`, `stableHash`, `nodeMotion`, `threadMotion`, `particleMotion`, and `reducedMotion`.

- [ ] **Step 1: Write failing geometry and preset tests**

Assert identical IDs produce identical SVG `C` paths, different IDs alter the control offset, endpoints remain exact, and the reduced-motion presets contain no looping transition:

```ts
expect(createOrganicPath(a, b, "edge-a")).toBe(createOrganicPath(a, b, "edge-a"));
expect(createOrganicPath(a, b, "edge-a")).not.toBe(createOrganicPath(a, b, "edge-b"));
expect(reducedMotion.central.transition).not.toHaveProperty("repeat", Infinity);
```

- [ ] **Step 2: Verify RED**

Run: `npm test --prefix packages/ui -- src/lib/path.test.ts src/lib/motion.test.ts`

Expected: FAIL because the modules do not exist.

- [ ] **Step 3: Implement the minimal helpers**

Generate a cubic Bézier whose midpoint offset is derived from a stable string hash and capped relative to edge length. Export typed Motion variants using smooth non-bouncing easing and the timing ranges from the visual brief.

- [ ] **Step 4: Verify GREEN**

Run: `npm test --prefix packages/ui -- src/lib/path.test.ts src/lib/motion.test.ts`

Expected: all path and motion tests PASS.

---

### Task 4: Implement interaction hooks

**Files:**
- Create: `packages/ui/src/hooks/use-controllable-state.ts`
- Create: `packages/ui/src/hooks/use-locked-node.ts`
- Create: `packages/ui/src/hooks/use-locked-node.test.tsx`
- Create: `packages/ui/src/hooks/use-hover-intent.ts`
- Create: `packages/ui/src/hooks/use-hover-intent.test.tsx`
- Create: `packages/ui/src/hooks/index.ts`

**Interfaces:**
- Produces `useLockedNode(options)` returning `{ lockedNodeId, isLocked, lock, unlock, toggle, getLockProps }`.
- Produces `useHoverIntent(options)` returning `{ isHovered, getHoverProps, cancel }`.

- [ ] **Step 1: Write failing hook tests**

Test uncontrolled defaults, controlled callbacks without local divergence, toggling, Escape unlock, consumer key handlers, hover delay, leave cancellation, focus-immediate behavior, and blur reset.

- [ ] **Step 2: Verify RED**

Run: `npm test --prefix packages/ui -- src/hooks`

Expected: FAIL because hook modules do not exist.

- [ ] **Step 3: Implement controlled state and locked-node behavior**

The hook accepts:

```ts
interface UseLockedNodeOptions {
  value?: string | null;
  defaultValue?: string | null;
  onValueChange?: (value: string | null) => void;
  escapeToUnlock?: boolean;
}
```

`getLockProps(id)` returns composable `onClick` and `aria-pressed`. Escape listeners exist only while a node is locked and are cleaned up on unmount.

- [ ] **Step 4: Implement hover intent**

Use pointer enter/leave timers with a 120 ms default entry delay and 80 ms leave delay. Focus enters immediately. Merge event props by calling the consumer handler before internal behavior and respecting `event.defaultPrevented`.

- [ ] **Step 5: Verify GREEN**

Run: `npm test --prefix packages/ui -- src/hooks`

Expected: all hook tests PASS with no timer warnings.

---

### Task 5: Implement accessible node primitives and GlowShell

**Files:**
- Create: `packages/ui/src/components/node/node-base.tsx`
- Create: `packages/ui/src/components/node/central-node.tsx`
- Create: `packages/ui/src/components/node/tier-node.tsx`
- Create: `packages/ui/src/components/node/leaf-node.tsx`
- Create: `packages/ui/src/components/node/node.test.tsx`
- Create: `packages/ui/src/components/node/index.ts`
- Create: `packages/ui/src/components/glow/glow-shell.tsx`
- Create: `packages/ui/src/components/glow/glow-shell.test.tsx`
- Create: `packages/ui/src/components/glow/index.ts`

**Interfaces:**
- Produces `CentralNode`, `TierNode`, and `LeafNode` as polymorphic-by-prop nodes: `href` renders an anchor; absence of `href` renders `button type="button"`.
- Produces `NodeVisualState` and `GlowShell` with semantic tone and intensity props.

- [ ] **Step 1: Write failing component tests**

Assert button and anchor semantics, default button type, disabled anchor behavior, `aria-current`, `aria-expanded`, `aria-pressed`, stable labels, tier data attributes, forwarded refs, custom handlers, and decorative glow with `aria-hidden="true"`.

- [ ] **Step 2: Verify RED**

Run: `npm test --prefix packages/ui -- src/components/node src/components/glow`

Expected: FAIL because component modules do not exist.

- [ ] **Step 3: Implement shared NodeBase**

Use React 18-compatible `forwardRef`, Motion's `motion.button` and `motion.a`, Tailwind structural classes, CSS-variable state classes, and a visible label span. Disabled anchors omit navigation, set `aria-disabled`, and prevent activation. Consumer events run before internal motion/state logic.

- [ ] **Step 4: Implement tier wrappers and GlowShell**

Tier wrappers only set `tier` defaults and display names. `GlowShell` renders a relative wrapper plus an inert absolute halo and accepts `tone: "pearl" | "cyan" | "violet"`, `active`, and `intensity`.

- [ ] **Step 5: Verify GREEN**

Run: `npm test --prefix packages/ui -- src/components/node src/components/glow`

Expected: all semantic and glow tests PASS.

---

### Task 6: Implement ConnectionThread and ParticleField

**Files:**
- Create: `packages/ui/src/components/thread/connection-thread.tsx`
- Create: `packages/ui/src/components/thread/connection-thread.test.tsx`
- Create: `packages/ui/src/components/thread/index.ts`
- Create: `packages/ui/src/components/particles/particle-field.tsx`
- Create: `packages/ui/src/components/particles/particle-field.test.tsx`
- Create: `packages/ui/src/components/particles/index.ts`

**Interfaces:**
- Consumes normalized source/target points, `createOrganicPath`, and Motion presets.
- Produces inert SVG connection paths and seeded CSS particle markup.

- [ ] **Step 1: Write failing component tests**

Assert exact path stability, parent/child data attributes, state classes, signal suppression under reduced motion, inert SVG semantics, identical particle markup for identical seeds, different output for different seeds, bounded positions, and `pointer-events-none`/`aria-hidden` behavior.

- [ ] **Step 2: Verify RED**

Run: `npm test --prefix packages/ui -- src/components/thread src/components/particles`

Expected: FAIL because components do not exist.

- [ ] **Step 3: Implement ConnectionThread**

Render a group with base `motion.path` and optional signal `motion.path`. Use `vectorEffect="non-scaling-stroke"`, `fill="none"`, deterministic IDs, and state data attributes. Accept `active`, `dimmed`, `disabled`, `showSignal`, `reducedMotion`, and class overrides.

- [ ] **Step 4: Implement ParticleField**

Use a local seeded PRNG, cap density to a documented safe maximum, render deterministic CSS variables for x/y/size/delay/duration/depth, and never read viewport dimensions during render.

- [ ] **Step 5: Verify GREEN**

Run: `npm test --prefix packages/ui -- src/components/thread src/components/particles`

Expected: all thread and particle tests PASS.

---

### Task 7: Implement GraphCanvas and composition context

**Files:**
- Create: `packages/ui/src/components/graph/graph-canvas.tsx`
- Create: `packages/ui/src/components/graph/graph-canvas.test.tsx`
- Create: `packages/ui/src/components/graph/index.ts`

**Interfaces:**
- Produces `GraphCanvas`, `GraphCanvasParticles`, `GraphCanvasThreads`, `GraphCanvasNodes`, `GraphCanvasForeground`, and `useGraphCanvas`.
- Context exposes `toPercent(point)` and safe-area options; it does not own app graph data.

- [ ] **Step 1: Write failing composition tests**

Assert layer order, single shared relative container, SVG `viewBox="0 0 100 100"`, pointer-transparent decorative layers, semantic HTML node layer, custom foreground content, normalized point conversion, CSS safe-area variables, and a descriptive provider error.

- [ ] **Step 2: Verify RED**

Run: `npm test --prefix packages/ui -- src/components/graph`

Expected: FAIL because graph components do not exist.

- [ ] **Step 3: Implement GraphCanvas**

Use compound components instead of auto-rendering content. The root supplies shared IDs and safe-area variables. Threads use an absolute SVG layer; nodes use an absolute HTML layer; foreground remains consumer-controlled. No `ResizeObserver` is required because normalized placement uses percentages.

- [ ] **Step 4: Verify GREEN**

Run: `npm test --prefix packages/ui -- src/components/graph`

Expected: all composition tests PASS.

---

### Task 8: Add tokens, exports, usage documentation, and decision record

**Files:**
- Create: `packages/ui/src/styles/forge-ui.css`
- Create: `packages/ui/src/index.ts`
- Modify: `packages/ui/README.md`
- Create: `docs/decisions/0002-ui-package-visual-engine.md`
- Modify: `docs/decisions/README.md`

**Interfaces:**
- Produces the final `@forge/ui` public API and `@forge/ui/styles.css` theme entry.

- [ ] **Step 1: Write a failing public-export test**

Create `packages/ui/src/index.test.ts` that imports every required public primitive and helper from `./index`, asserts each is defined, and reads the package manifest to verify the stylesheet export.

- [ ] **Step 2: Verify RED**

Run: `npm test --prefix packages/ui -- src/index.test.ts`

Expected: FAIL because the root barrel and stylesheet do not exist.

- [ ] **Step 3: Implement CSS tokens and root exports**

Define the visual brief's named colors and semantic size, focus, glow, duration, and layer variables under `.forge-ui-theme`. Include forced-color, reduced-motion, and high-contrast adjustments. Export all supported components, hooks, types, layout functions, paths, and motion presets from `src/index.ts`.

- [ ] **Step 4: Write package documentation**

Document installation, `@import "@forge/ui/styles.css"`, Tailwind v4 `@source "../node_modules/@forge/ui"`, font recommendations, theme overrides, node/thread/particle composition, controlled locking, deterministic layout, accessibility responsibilities, and the explicit absence of landing-dashboard content.

- [ ] **Step 5: Record the repository decision**

Document why `packages/ui-components` became `packages/ui`, why the graph uses hybrid HTML/SVG layers, and why deterministic layout precedes physics, zoom, and pan.

- [ ] **Step 6: Verify GREEN**

Run: `npm test --prefix packages/ui -- src/index.test.ts`

Expected: public export test PASS.

---

### Task 9: Run repository-wide verification

**Files:**
- Modify only files required to fix failures caused by Tasks 1–8.

**Interfaces:**
- Verifies the completed package and migration as one repository change.

- [ ] **Step 1: Run all package tests**

Run: `npm test --prefix packages/ui`

Expected: all Vitest suites PASS with zero failures.

- [ ] **Step 2: Run type checking and build**

Run: `npm run typecheck --prefix packages/ui`

Run: `npm run build --prefix packages/ui`

Expected: both commands exit 0 and `packages/ui/dist/index.js` plus declarations exist.

- [ ] **Step 3: Verify the package artifact**

Run: `npm pack --dry-run --prefix packages/ui`

Expected: package contains `dist`, `src/styles/forge-ui.css`, `README.md`, and `package.json`, with no app files.

- [ ] **Step 4: Run repository tests**

Run: `bash scripts/test.sh`

Expected: scaffold, project creation, Python compilation, and available repository tests PASS.

- [ ] **Step 5: Scan migration and scope boundaries**

Run: `rg -n 'ui-components|packages/ui-components' . --glob '!.git/**' --glob '!docs/superpowers/**'`

Expected: no matches.

Run: `rg -n 'jameshowe|CONTACTS|PROJECTS|SPEAKING|BLOG|Athena|Ecommerce' packages/ui --glob '!README.md'`

Expected: no app-specific content matches.

- [ ] **Step 6: Inspect final diff**

Run: `git diff --check`

Run: `git status --short`

Expected: no whitespace errors; only approved UI migration, package implementation, tests, manifests, and synchronized documentation are changed.
