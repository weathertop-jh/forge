# Forge UI

Reusable React primitives for Forge's spatial node, constellation, and graph interfaces. The package is app-agnostic: consumers provide graph data, labels, links, and application behavior.

## Setup

Install `@forge/ui` with its React, Tailwind CSS, and Motion peer dependencies. Import the theme stylesheet once:

```css
@import "tailwindcss";
@import "@forge/ui/styles.css";
@source "../node_modules/@forge/ui";
```

Apply `forge-ui-theme` to the graph surface or an ancestor. Override semantic CSS variables there to create another Forge theme. Space Grotesk is recommended for node labels and IBM Plex Mono for optional utility text; fonts are not bundled.

## Composition

```tsx
import {
  CentralNode,
  ConnectionThread,
  GraphCanvas,
  GraphCanvasNodes,
  GraphCanvasParticles,
  GraphCanvasThreads,
  ParticleField,
  TierNode,
} from "@forge/ui";
import "@forge/ui/styles.css";

export function Map() {
  return (
    <GraphCanvas className="forge-ui-theme h-dvh">
      <GraphCanvasParticles><ParticleField seed="example" /></GraphCanvasParticles>
      <GraphCanvasThreads>
        <ConnectionThread id="root-work" source={{ x: 0.5, y: 0.5 }} target={{ x: 0.75, y: 0.3 }} />
      </GraphCanvasThreads>
      <GraphCanvasNodes>
        <CentralNode label="Home" position={{ x: 0.5, y: 0.5 }} />
        <TierNode label="Work" position={{ x: 0.75, y: 0.3 }} />
      </GraphCanvasNodes>
    </GraphCanvas>
  );
}
```

SVG threads use the `0 0 100 100` coordinate system. HTML nodes use normalized `0–1` coordinates. `layoutGraph` generates deterministic positions when applications do not supply them.

`useLockedNode` supports controlled and uncontrolled selection. `useHoverIntent` provides delayed pointer intent with immediate keyboard focus behavior. Nodes remain real buttons or links; applications retain responsibility for meaningful labels and semantic DOM order.

This package intentionally contains no routes, portfolio labels, physics simulation, zoom/pan controls, or application topology.
