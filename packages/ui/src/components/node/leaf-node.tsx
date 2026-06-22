import type { NodeProps } from "./node-base"; import { NodeBase } from "./node-base";
export function LeafNode(props: NodeProps) { return <NodeBase {...props} tier="leaf" />; }
