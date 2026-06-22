import { describe, expect, it } from "vitest";
import { layoutGraph, validateGraph } from "./layout";
import type { GraphNode } from "./types";

const nodes: GraphNode[] = [
  { id: "root", tier: "central" },
  { id: "work", parentId: "root", tier: "tier" },
  { id: "item", parentId: "work", tier: "leaf" },
];

describe("layoutGraph", () => {
  it("is deterministic and centers the central node", () => {
    const first = layoutGraph(nodes, []);
    const second = layoutGraph([...nodes].reverse(), []);
    expect(first.nodes.get("root")?.position).toEqual({ x: 0.5, y: 0.5 });
    expect([...first.nodes]).toEqual([...second.nodes]);
  });

  it("preserves explicit normalized positions", () => {
    const result = layoutGraph([{ id: "root", tier: "central", position: { x: 0.2, y: 0.3 } }], []);
    expect(result.nodes.get("root")?.position).toEqual({ x: 0.2, y: 0.3 });
  });

  it("reports invalid topology", () => {
    const duplicate = [...nodes, nodes[0]!];
    expect(validateGraph(duplicate, [])).toEqual(expect.arrayContaining([
      expect.objectContaining({ code: "duplicate-node" }),
    ]));
    expect(validateGraph(nodes, [{ id: "bad", sourceId: "root", targetId: "missing" }])).toEqual(
      expect.arrayContaining([expect.objectContaining({ code: "missing-endpoint" })]),
    );
    expect(validateGraph([
      { id: "a", tier: "tier", parentId: "b" },
      { id: "b", tier: "tier", parentId: "a" },
    ], [])).toEqual(expect.arrayContaining([expect.objectContaining({ code: "parent-cycle" })]));
  });
});
