import type { NodeProps } from "./node-base"; import { NodeBase } from "./node-base";
export function TierNode(props: NodeProps) { return <NodeBase {...props} tier="tier" />; }
