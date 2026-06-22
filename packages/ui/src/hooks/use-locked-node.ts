import { useCallback, useEffect } from "react";
import { useControllableState } from "./use-controllable-state";

export interface UseLockedNodeOptions { value?: string | null; defaultValue?: string | null; onValueChange?: (value: string | null) => void; escapeToUnlock?: boolean }
export function useLockedNode({ value, defaultValue = null, onValueChange, escapeToUnlock = true }: UseLockedNodeOptions = {}) {
  const [lockedNodeId, setLockedNodeId] = useControllableState(value, defaultValue, onValueChange);
  const lock = useCallback((id: string) => setLockedNodeId(id), [setLockedNodeId]);
  const unlock = useCallback(() => setLockedNodeId(null), [setLockedNodeId]);
  const toggle = useCallback((id: string) => setLockedNodeId(lockedNodeId === id ? null : id), [lockedNodeId, setLockedNodeId]);
  useEffect(() => {
    if (!escapeToUnlock || lockedNodeId === null) return;
    const listener = (event: KeyboardEvent) => { if (event.key === "Escape") unlock(); };
    window.addEventListener("keydown", listener); return () => window.removeEventListener("keydown", listener);
  }, [escapeToUnlock, lockedNodeId, unlock]);
  return { lockedNodeId, isLocked: (id: string) => lockedNodeId === id, lock, unlock, toggle, getLockProps: (id: string) => ({ "aria-pressed": lockedNodeId === id, onClick: () => toggle(id) }) };
}
