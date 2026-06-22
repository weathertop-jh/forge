import type { GraphEdge, GraphLayoutIssue, GraphLayoutOptions, GraphLayoutResult, GraphNode, NormalizedPoint, PositionedGraphNode } from "./types";

const clamp = (value: number) => Math.min(1, Math.max(0, value));
const pointAt = (origin: NormalizedPoint, radius: number, angle: number): NormalizedPoint => ({
  x: clamp(origin.x + Math.cos(angle) * radius),
  y: clamp(origin.y + Math.sin(angle) * radius),
});

export function validateGraph<T>(nodes: readonly GraphNode<T>[], edges: readonly GraphEdge[]): GraphLayoutIssue[] {
  const issues: GraphLayoutIssue[] = [];
  const ids = new Set<string>();
  const byId = new Map<string, GraphNode<T>>();
  for (const node of nodes) {
    if (ids.has(node.id)) issues.push({ code: "duplicate-node", nodeId: node.id, message: `Duplicate node: ${node.id}` });
    ids.add(node.id); byId.set(node.id, node);
  }
  const centrals = nodes.filter((node) => node.tier === "central");
  if (centrals.length === 0) issues.push({ code: "missing-central-node", message: "Graph requires one central node" });
  if (centrals.length > 1) issues.push({ code: "multiple-central-nodes", message: "Graph supports one central node" });
  for (const node of nodes) if (node.parentId && !byId.has(node.parentId)) issues.push({ code: "missing-parent", nodeId: node.id, message: `Missing parent: ${node.parentId}` });
  for (const edge of edges) if (!byId.has(edge.sourceId) || !byId.has(edge.targetId)) issues.push({ code: "missing-endpoint", edgeId: edge.id, message: `Missing endpoint for edge: ${edge.id}` });
  for (const node of nodes) {
    const seen = new Set<string>(); let cursor: GraphNode<T> | undefined = node;
    while (cursor?.parentId) {
      if (seen.has(cursor.parentId)) { issues.push({ code: "parent-cycle", nodeId: node.id, message: `Parent cycle at: ${node.id}` }); break; }
      seen.add(cursor.id); cursor = byId.get(cursor.parentId);
    }
  }
  return issues;
}

export function layoutGraph<T>(inputNodes: readonly GraphNode<T>[], inputEdges: readonly GraphEdge[], options: GraphLayoutOptions = {}): GraphLayoutResult<T> {
  const sorted = [...inputNodes].sort((a, b) => a.id.localeCompare(b.id));
  const issues = validateGraph(sorted, inputEdges);
  const result = new Map<string, PositionedGraphNode<T>>();
  const centerNode = sorted.find((node) => node.tier === "central");
  const center = centerNode?.position ?? { x: 0.5, y: 0.5 };
  if (centerNode) result.set(centerNode.id, { ...centerNode, position: center });
  const tiers = sorted.filter((node) => node.tier === "tier");
  const start = options.startAngle ?? -Math.PI / 2;
  tiers.forEach((node, index) => {
    const angle = start + (index * Math.PI * 2) / Math.max(1, tiers.length);
    result.set(node.id, { ...node, position: node.position ?? pointAt(center, options.tierRadius ?? 0.32, angle) });
  });
  for (const node of sorted.filter((candidate) => candidate.tier === "leaf")) {
    const parent = node.parentId ? result.get(node.parentId) : undefined;
    const parentIndex = Math.max(0, tiers.findIndex((tier) => tier.id === node.parentId));
    const siblings = sorted.filter((candidate) => candidate.tier === "leaf" && candidate.parentId === node.parentId);
    const siblingIndex = siblings.findIndex((candidate) => candidate.id === node.id);
    const base = start + (parentIndex * Math.PI * 2) / Math.max(1, tiers.length);
    const spread = (siblingIndex - (siblings.length - 1) / 2) * 0.24;
    result.set(node.id, { ...node, position: node.position ?? pointAt(parent?.position ?? center, options.leafRadius ?? 0.14, base + spread) });
  }
  for (const node of sorted) if (!result.has(node.id)) result.set(node.id, { ...node, position: node.position ?? center });
  const edges = [...inputEdges].sort((a, b) => a.id.localeCompare(b.id)).flatMap((edge) => {
    const source = result.get(edge.sourceId); const target = result.get(edge.targetId);
    return source && target ? [{ ...edge, source, target }] : [];
  });
  return { nodes: result, edges, issues };
}
