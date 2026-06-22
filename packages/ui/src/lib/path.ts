import type { NormalizedPoint } from "./types";

export function stableHash(value: string): number {
  let hash = 2166136261;
  for (const character of value) { hash ^= character.charCodeAt(0); hash = Math.imul(hash, 16777619); }
  return hash >>> 0;
}

export function createOrganicPath(source: NormalizedPoint, target: NormalizedPoint, id: string, bend = 0.16): string {
  const dx = target.x - source.x; const dy = target.y - source.y;
  const length = Math.hypot(dx, dy) || 1;
  const sign = stableHash(id) % 2 === 0 ? 1 : -1;
  const variation = 0.65 + (stableHash(`${id}:bend`) % 36) / 100;
  const offset = Math.min(length * bend * variation, length * 0.25) * sign;
  const nx = -dy / length; const ny = dx / length;
  const c1 = { x: source.x + dx * 0.34 + nx * offset, y: source.y + dy * 0.34 + ny * offset };
  const c2 = { x: source.x + dx * 0.66 + nx * offset, y: source.y + dy * 0.66 + ny * offset };
  return `M ${source.x} ${source.y} C ${c1.x} ${c1.y}, ${c2.x} ${c2.y}, ${target.x} ${target.y}`;
}
