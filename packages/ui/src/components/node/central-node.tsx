import type { NodeProps } from "./node-base"; import { NodeBase } from "./node-base";
export function CentralNode(props: NodeProps) { return <NodeBase {...props} tier="central" />; }
