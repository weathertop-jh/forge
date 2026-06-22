export type GraphNodeTier = "central" | "tier" | "leaf";
export interface NormalizedPoint { x: number; y: number }
export interface GraphNode<T = unknown> { id: string; parentId?: string; tier: GraphNodeTier; position?: NormalizedPoint; data?: T }
export interface GraphEdge { id: string; sourceId: string; targetId: string }
export interface PositionedGraphNode<T = unknown> extends GraphNode<T> { position: NormalizedPoint }
export type GraphLayoutIssueCode = "duplicate-node" | "missing-endpoint" | "missing-parent" | "parent-cycle" | "multiple-central-nodes" | "missing-central-node";
export interface GraphLayoutIssue { code: GraphLayoutIssueCode; message: string; nodeId?: string; edgeId?: string }
export interface ResolvedGraphEdge extends GraphEdge { source: PositionedGraphNode; target: PositionedGraphNode }
export interface GraphLayoutResult<T = unknown> { nodes: Map<string, PositionedGraphNode<T>>; edges: ResolvedGraphEdge[]; issues: GraphLayoutIssue[] }
export interface GraphLayoutOptions { tierRadius?: number; leafRadius?: number; startAngle?: number }
export type NodeVisualState = "resting" | "active" | "locked" | "expanded" | "dimmed" | "disabled";
