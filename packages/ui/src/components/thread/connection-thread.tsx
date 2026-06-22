import { motion } from "motion/react";
import { cx } from "../../lib/class-names"; import { createOrganicPath } from "../../lib/path"; import type { NormalizedPoint } from "../../lib/types";
export interface ConnectionThreadProps { id: string; source: NormalizedPoint; target: NormalizedPoint; active?: boolean; dimmed?: boolean; disabled?: boolean; showSignal?: boolean; reducedMotion?: boolean; className?: string }
export function ConnectionThread({ id, source, target, active, dimmed, disabled, showSignal = true, reducedMotion, className }: ConnectionThreadProps) {
  const d = createOrganicPath(
    { x: source.x * 100, y: source.y * 100 },
    { x: target.x * 100, y: target.y * 100 },
    id,
  );
  return <g aria-hidden="true" className={cx("forge-thread", className)} data-active={active || undefined} data-dimmed={dimmed || undefined} data-disabled={disabled || undefined} data-edge-id={id}><motion.path className="forge-thread__path" d={d} fill="none" vectorEffect="non-scaling-stroke" />{active && showSignal && !reducedMotion ? <motion.path className="forge-thread__signal" d={d} fill="none" vectorEffect="non-scaling-stroke" initial={{ pathLength: 0, opacity: 0 }} animate={{ pathLength: 1, opacity: [0, 1, 0] }} transition={{ duration: 0.7 }} /> : null}</g>;
}
