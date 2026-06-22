import type { PropsWithChildren } from "react";
import { cx } from "../../lib/class-names";

export interface GlowShellProps extends PropsWithChildren { tone?: "pearl" | "cyan" | "violet"; active?: boolean; intensity?: "soft" | "medium" | "strong"; className?: string }
export function GlowShell({ children, tone = "cyan", active = false, intensity = "medium", className }: GlowShellProps) {
  return <span className={cx("forge-glow-shell relative inline-flex", className)} data-active={active || undefined} data-intensity={intensity} data-tone={tone}><span aria-hidden="true" className="forge-glow-shell__halo pointer-events-none absolute inset-0" />{children}</span>;
}
