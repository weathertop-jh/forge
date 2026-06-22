import { useCallback, useState } from "react";

export function useControllableState<T>(value: T | undefined, defaultValue: T, onChange?: (value: T) => void) {
  const [internal, setInternal] = useState(defaultValue);
  const current = value === undefined ? internal : value;
  const set = useCallback((next: T) => { if (value === undefined) setInternal(next); onChange?.(next); }, [onChange, value]);
  return [current, set] as const;
}
