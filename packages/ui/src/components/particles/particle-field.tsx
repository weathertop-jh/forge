import type { CSSProperties } from "react"; import { stableHash } from "../../lib/path"; import { cx } from "../../lib/class-names";
export interface ParticleFieldProps { seed?: string; count?: number; className?: string; reducedMotion?: boolean }
function random(seed: number) { let state = seed || 1; return () => { state = Math.imul(state ^ (state >>> 15), state | 1); state ^= state + Math.imul(state ^ (state >>> 7), state | 61); return ((state ^ (state >>> 14)) >>> 0) / 4294967296; }; }
export function ParticleField({ seed = "forge", count = 36, className, reducedMotion }: ParticleFieldProps) {
  const next = random(stableHash(seed)); const safeCount = Math.min(160, Math.max(0, Math.floor(count)));
  return <div aria-hidden="true" className={cx("forge-particle-field pointer-events-none absolute inset-0", className)} data-reduced-motion={reducedMotion || undefined}>{Array.from({ length: safeCount }, (_, index) => { const style = { "--particle-x": `${next() * 100}%`, "--particle-y": `${next() * 100}%`, "--particle-size": `${0.7 + next() * 1.8}px`, "--particle-opacity": `${0.18 + next() * 0.5}`, "--particle-duration": `${12 + next() * 18}s`, "--particle-delay": `${-next() * 12}s` } as CSSProperties; return <i data-particle key={index} style={style} />; })}</div>;
}
