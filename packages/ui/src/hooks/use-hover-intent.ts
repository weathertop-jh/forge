import { useCallback, useEffect, useRef, useState } from "react";

export interface UseHoverIntentOptions { enterDelay?: number; leaveDelay?: number }
export function useHoverIntent({ enterDelay = 120, leaveDelay = 80 }: UseHoverIntentOptions = {}) {
  const [isHovered, setHovered] = useState(false); const timer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const cancel = useCallback(() => { if (timer.current) clearTimeout(timer.current); timer.current = null; }, []);
  const schedule = useCallback((value: boolean, delay: number) => { cancel(); timer.current = setTimeout(() => setHovered(value), delay); }, [cancel]);
  useEffect(() => cancel, [cancel]);
  return { isHovered, cancel, getHoverProps: () => ({ onPointerEnter: (event: { defaultPrevented: boolean }) => { if (!event.defaultPrevented) schedule(true, enterDelay); }, onPointerLeave: (event: { defaultPrevented: boolean }) => { if (!event.defaultPrevented) schedule(false, leaveDelay); }, onFocus: (event: { defaultPrevented: boolean }) => { if (!event.defaultPrevented) { cancel(); setHovered(true); } }, onBlur: (event: { defaultPrevented: boolean }) => { if (!event.defaultPrevented) { cancel(); setHovered(false); } } }) };
}
