import type { CSSProperties, MouseEventHandler } from "react";
import { motion, useReducedMotion } from "motion/react";
import { cx } from "../../lib/class-names";
import { nodeMotion, nodeTransition } from "../../lib/motion";
import type { GraphNodeTier, NormalizedPoint } from "../../lib/types";
import { GlowShell } from "../glow";

export interface NodeProps {
  label: string; href?: string; disabled?: boolean; active?: boolean; locked?: boolean; expanded?: boolean; dimmed?: boolean;
  position?: NormalizedPoint; className?: string; style?: CSSProperties; onClick?: MouseEventHandler<HTMLButtonElement | HTMLAnchorElement>;
  "aria-label"?: string;
}
export interface NodeBaseProps extends NodeProps { tier: GraphNodeTier }
export function NodeBase({ label, href, disabled, active, locked, expanded, dimmed, position, className, style, onClick, tier, "aria-label": ariaLabel }: NodeBaseProps) {
  const reduce = useReducedMotion();
  const shared = { className: cx("forge-node absolute inline-flex items-center justify-center", `forge-node--${tier}`, className), "data-tier": tier, "data-active": active || undefined, "data-locked": locked || undefined, "data-dimmed": dimmed || undefined, style: { ...style, ...(position ? { left: `${position.x * 100}%`, top: `${position.y * 100}%` } : {}) }, "aria-label": ariaLabel ?? label, "aria-expanded": expanded, "aria-pressed": locked, variants: nodeMotion, initial: "resting", animate: active || locked ? "active" : "resting", whileTap: reduce ? undefined : "pressed", transition: reduce ? { duration: 0.1 } : nodeTransition } as const;
  const content = <GlowShell active={active || locked} tone={tier === "central" ? "pearl" : tier === "tier" ? "cyan" : "violet"}><span className="forge-node__core" aria-hidden="true" /><span className="forge-node__label">{label}</span></GlowShell>;
  if (href) return <motion.a {...shared} href={disabled ? undefined : href} aria-disabled={disabled || undefined} onClick={(event) => { if (disabled) event.preventDefault(); onClick?.(event); }}>{content}</motion.a>;
  return <motion.button {...shared} type="button" disabled={disabled} onClick={onClick}>{content}</motion.button>;
}
