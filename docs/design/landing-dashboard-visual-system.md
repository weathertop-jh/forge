# Landing Dashboard Visual System

## Purpose

This brief defines the reusable visual system for the `jameshowe.dev` landing dashboard. The experience is a single-screen spatial portfolio and navigation surface, not a conventional landing page or scrolling dashboard. Visitors explore a living node network whose structure communicates the relationship between James, his work, speaking, writing, and contact channels.

The defining metaphor is **deep-field bioluminescent mycelium**: information appears as luminous growth suspended in a dark atmospheric field. Nodes behave like fruiting bodies, connecting paths like hyphae, and interaction like energy travelling through a living network. The metaphor should guide composition and motion without becoming literal illustration.

This document defines visual and interaction language only. It does not prescribe application architecture, data models, or implementation details.

## Visual Principles

### Spatial before sectional

The interface is one continuous field. It must not resolve into a hero, feature rows, cards, footer, or other standard landing-page sections. Hierarchy is expressed through position, scale, light, connection, and motion rather than vertical ordering.

### One luminous anchor

The central `jameshowe.dev` node is the strongest point of contrast and the stable visual anchor. Everything else must feel connected to it without competing with it. Accent light is spent primarily on this node and on the active path.

### Organic, not chaotic

Connections use irregular, gently curved paths and asymmetric spacing, but the hierarchy must remain immediately legible. Variation should feel grown rather than randomized. Avoid perfect radial symmetry, rigid grids, circuit-board angles, and decorative tangles.

### Darkness has structure

The background is not flat black. It uses restrained depth, local haze, and sparse particulate light to create spatial separation. Atmospheric effects must remain quieter than labels and interactive nodes.

### Light communicates state

Glow is functional. Brightness, bloom, pulse, and thread illumination indicate hierarchy, proximity, focus, selection, and relationship. Do not apply neon glow uniformly or as decoration.

### Minimal text, explicit meaning

Labels are short and concrete. Tier, relationship, and current state should be understandable without descriptive paragraphs. Avoid slogans, marketing copy, dashboard metrics, pills, badges, and ornamental interface labels.

## Layout Model

The system uses an asymmetric radial composition centered within the safe visual area of the viewport. The Tier 1 node occupies the visual origin. Tier 2 nodes sit in four distinct directional regions around it, and Tier 3 nodes branch outward from their parent.

The initial composition should fit within one viewport wherever the viewport can reasonably support it. There is no document-level scrolling in the primary experience. A protected perimeter keeps interactive content clear of browser edges, device cutouts, and persistent controls.

```text
          ○ Darktrace Live ─┐
                            ├── ● SPEAKING
          ○ ReInvent ───────┘        \
                                      \
○ LinkedIn ─┐                          \
○ Resume ───┼── ● CONTACTS ─────────── ◉ jameshowe.dev ─────────── ● PROJECTS ──┬── ○ Ecommerce
○ GitHub ───┤                          /                                        └── ○ Athena
○ Email ────┘                         /
                                     /
                            ● BLOG ──┬── ○ Notes
                                    ├── ○ Insights
                                    └── ○ Articles
```

This diagram expresses hierarchy only; it is not a fixed coordinate map. Final placement should balance label length, thread crossings, and visual mass.

Topology is strict:

- `CONTACTS`, `PROJECTS`, `SPEAKING`, and `BLOG` each connect directly and independently to `jameshowe.dev`.
- No Tier 2 node connects to, routes through, or acts as the parent of another Tier 2 node.
- Every Tier 3 node connects only to its named Tier 2 parent.

Layout rules:

- Keep the Tier 1 node near the optical center, with slight offset permitted to balance unequal branches.
- Give each Tier 2 group its own angular sector and local breathing room.
- Place Tier 3 nodes closer to their parent than their parent is to the center.
- Avoid thread crossings in the default state. If a crossing is unavoidable at a constrained size, separate the paths through opacity and depth.
- Maintain a minimum protected edge zone equal to the larger of 24 px or 4 viewport units.
- Recompose the field at narrow aspect ratios; do not merely scale a desktop map until labels become unreadable.
- On very small screens, retain the spatial field but reveal one selected branch at a time around the central node.

## Node Hierarchy

### Tier 1: identity

- `jameshowe.dev`

The central node is always visible and always connected to the four Tier 2 nodes. It uses the largest node body, strongest halo, and clearest label. It is a home position, not a conventional logo lockup.

### Tier 2: primary territories

- `CONTACTS`
- `PROJECTS`
- `SPEAKING`
- `BLOG`

Tier 2 nodes are primary navigation territories. They share one visual weight and connect directly to the center. Uppercase labels provide a compact, cartographic tone and distinguish territories from destinations.

### Tier 3: destinations

- `CONTACTS`: LinkedIn, Resume, GitHub, Email
- `PROJECTS`: Ecommerce, Athena
- `SPEAKING`: Darktrace Live, ReInvent
- `BLOG`: Notes, Insights, Articles

Tier 3 nodes are destinations or actions. They use smaller bodies, lower resting luminance, and title-case labels. Each connects only to its Tier 2 parent. A destination may expose a small directional cue when it opens an external resource, but this cue must not become a badge.

## Interaction States

### Resting

The center emits a slow, almost imperceptible pulse. Tier 2 nodes remain clearly discoverable. Tier 3 nodes and their threads are visible at reduced intensity, preserving the whole mental map without making every destination demand attention.

### Hover or pointer proximity

The target node brightens and expands slightly. Its inbound thread gains definition from parent to child, while sibling paths remain present but recede. A short travelling highlight may move along the active thread. Labels increase in contrast without shifting position.

Pointer proximity may create subtle local attraction or parallax, but movement must never make a target evade the pointer.

### Keyboard focus

Keyboard focus must be at least as clear as hover and must not rely on glow alone. Use a crisp outer focus ring or segmented orbit with sufficient contrast. Focus follows the logical hierarchy: center, Tier 2 groups, then the children within each group.

### Pressed

The node contracts briefly and the halo tightens. The connected thread brightens toward the node, giving the impression that energy is being drawn into the selection.

### Open or locked group

Selecting a Tier 2 node locks that branch open. The selected parent and its child paths become the dominant cluster; unrelated branches dim but remain spatially available. The group must not jump to an unrelated screen position. Selecting the parent again, selecting the center, or pressing Escape returns to the full-field state.

### Destination selected

An internal destination may transition the active field to its associated view later. An external destination should acknowledge activation before navigation without delaying it unnecessarily. The visual system must support both outcomes without changing node styling.

### Unavailable

Unavailable nodes remain structurally visible at low contrast, with no pulse or travelling light. If unavailable destinations are ever introduced, their state must be communicated in text accessible to assistive technology and not by opacity alone.

## Animation Language

Motion should feel like pressure and light moving through a responsive organism. It is fluid and slightly asynchronous, never springy for its own sake.

- **Ambient drift:** particles and haze move over 12–30 seconds with very low amplitude.
- **Central respiration:** the main halo expands and fades over 4–6 seconds with no hard loop boundary.
- **Hover response:** 160–240 ms for node scale, label contrast, and local thread emphasis.
- **Selection response:** 420–650 ms for branch locking and contextual dimming.
- **Travelling signal:** 500–900 ms from parent to child, used only on meaningful focus or selection changes.
- **Easing:** use smooth, asymmetric curves with gentle acceleration and a long settle. Avoid bounce, elastic overshoot, and mechanical linear motion.
- **Displacement:** node movement during interaction should remain within 2–6 px at desktop scale. Hierarchy must never become unstable.

Animate opacity and transforms where possible. Blur and large bloom changes should be sparse because they can muddy the scene and reduce performance. No continuous animation may be necessary to identify or operate a control.

Reduced-motion mode removes travelling signals, parallax, drift, and scale pulses. State changes become short opacity and color transitions of 100 ms or less, or immediate changes where preferred by the platform.

## Color Palette

The palette avoids flat black, acid green, and equal-strength cyan/magenta cyberpunk styling. Cyan carries navigation energy; violet adds depth; warm pearl keeps the identity node human.

| Token | Value | Role |
| --- | --- | --- |
| Substrate | `#05070D` | Primary field background |
| Deep indigo | `#0B1020` | Local depth, haze, and layered field variation |
| Thread dormant | `#33405A` | Resting connection lines |
| Hypha cyan | `#5CE1E6` | Active paths, focus energy, primary interactive accent |
| Spore violet | `#A78BFA` | Secondary bloom and depth separation |
| Living pearl | `#EAFBF7` | Central node, primary labels, peak highlights |
| Muted mist | `#8D99AE` | Secondary labels and inactive metadata |

Usage rules:

- Substrate and deep indigo should occupy most of the viewport.
- Living pearl marks the brightest point and should be used sparingly.
- Hypha cyan is the principal state color; spore violet supports it rather than competing with it.
- Threads must retain visible contrast against the substrate in their resting state.
- Glows are translucent derivatives of token colors, never additional arbitrary hues.
- State meaning must not depend on color alone.

## Typography

Typography should feel precise and contemporary without imitating a terminal. The recommended reusable pairing is:

- **Display and node labels:** Space Grotesk, medium to semibold. Its open geometry remains legible inside an atmospheric field while avoiding a generic geometric-sans neutrality.
- **Utility and optional coordinates:** IBM Plex Mono, regular to medium. Use only for compact status, keyboard hints, or future spatial coordinates.
- **Fallback:** a carefully matched system sans stack for labels and system monospace for utility text.

Type rules:

- Central label: 20–28 px responsive size, 600 weight, tight but not compressed tracking.
- Tier 2 labels: 12–14 px, 600 weight, uppercase, `0.08em–0.12em` tracking.
- Tier 3 labels: 13–15 px, 500 weight, title case.
- Utility text: 10–12 px, 500 weight, restrained uppercase or tabular formatting only when the content warrants it.
- Keep labels horizontal and readable; do not rotate text to follow paths.
- Never place long paragraphs inside the field.

Typography is part of the navigation geometry. Labels must have stable positions across interaction states so emphasis does not create layout jitter.

## Component Rules

The visual system should be reusable as a small family of primitives rather than a landing-dashboard-specific composition.

### Spatial field

Owns the dark substrate, atmospheric layers, protected viewport bounds, and coordinate space. It must not contain product-specific labels or links.

### Node

Supports hierarchy level, label, interaction state, and optional destination behavior. Node bodies are circular or softly irregular, with a solid core and restrained halo. Do not render nodes as rounded cards, glass panels, pills, or icon tiles.

Node size ratios should remain consistent: Tier 1 at `1.0`, Tier 2 at approximately `0.55–0.7`, and Tier 3 at approximately `0.3–0.45`. The interactive hit area must be larger than the visible node.

### Thread

Connects exactly one parent and one child. Threads are thin, organic curves with quiet resting contrast. Their width, opacity, and travelling highlight may respond to state. Avoid arrows, hard elbows, identical curves, and animated noise that makes the relationship ambiguous.

### Node group

Combines a parent, its children, and their local threads. It owns open, closed, and contextual-dimming behavior without changing the global hierarchy.

### Atmosphere

Provides particles, faint haze, and rare depth glints. Particles are non-interactive, sparse, and varied in size. They must never resemble additional nodes or compete with focus indicators.

### Field controls

Future reset, zoom, and pan controls should be compact, edge-aligned utilities. They may borrow the field palette and line language but must remain conventional enough to be understood. They must not become a floating SaaS toolbar.

## Accessibility Considerations

- Model every node as a semantic control or link with an accessible name and destination purpose.
- Preserve a logical keyboard order that follows the visual hierarchy rather than raw screen coordinates.
- Provide arrow-key movement within a group if spatial navigation is introduced; retain Tab as a complete fallback.
- Make visible hit targets at least 24 by 24 CSS pixels and combined interactive target areas at least 44 by 44 CSS pixels where spacing permits.
- Ensure labels and focus indicators meet WCAG contrast requirements against the effective background, including beneath haze and glow.
- Do not use bloom as the sole focus treatment; include a crisp boundary.
- Announce expanded and collapsed Tier 2 group state to assistive technology.
- Keep the full information hierarchy available when motion, transparency, or visual effects are reduced.
- Respect `prefers-reduced-motion`, `prefers-contrast`, forced-colors modes, and browser zoom.
- At 200% zoom or on narrow screens, allow a controlled branch-at-a-time composition rather than clipping or shrinking text below legibility.
- Provide a structurally equivalent linear navigation representation for screen readers without presenting a duplicate interactive experience to sighted keyboard users.
- Do not trap keyboard focus within the spatial field.

## Future Extensibility

The initial system should remain deliberately finite, but its rules must support growth without redesigning the metaphor.

- **Additional destinations:** allow Tier 3 siblings while enforcing sector capacity and avoiding thread collisions.
- **New territories:** permit additional Tier 2 groups only after recomposing the field; do not squeeze them into existing gaps.
- **Zoom and pan:** add only when content exceeds a legible single-viewport map. Always provide reset and keyboard alternatives, preserve the central home anchor, and prevent users from losing the network off-screen.
- **Progressive disclosure:** support hiding distant Tier 3 nodes at constrained scales while keeping their parent count and availability perceivable.
- **Content previews:** permit a selected node to reveal a compact contextual surface, but keep that surface visually subordinate to the map and avoid turning every node into a card.
- **Theming:** expose semantic tokens for substrate, node tiers, threads, atmosphere, focus, and selection so future Forge apps can reuse the system without copying landing-dashboard values.
- **Data-driven layouts:** future generated coordinates must remain deterministic for a given hierarchy so returning visitors can build spatial memory.
- **Input modes:** leave room for touch, trackpad, mouse, keyboard, and assistive technologies without privileging hover as the only discovery mechanism.

## Guardrails

The visual system is successful when a visitor can understand the central identity, recognize the four primary territories, and reach any destination without scrolling or decoding decorative effects.

Do not introduce:

- conventional hero, feature, testimonial, pricing, or footer sections;
- dashboard cards, KPI tiles, sidebars, or tab bars;
- decorative charts, code rain, grid tunnels, or generic AI imagery;
- excessive glassmorphism, chrome, borders, or floating panels;
- random node motion that disrupts targeting or spatial memory;
- dense star fields that obscure the hierarchy;
- equal-intensity glow on every element;
- interaction that depends exclusively on hover.

The lasting impression should be of entering a quiet, living network: technically precise, unmistakably spatial, and responsive enough to feel discovered rather than presented.
