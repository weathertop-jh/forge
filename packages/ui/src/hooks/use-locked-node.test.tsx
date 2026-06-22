import { act, renderHook } from "@testing-library/react";
import { expect, it, vi } from "vitest";
import { useLockedNode } from "./use-locked-node";

it("locks, toggles, and unlocks with Escape", () => {
  const changed = vi.fn();
  const { result } = renderHook(() => useLockedNode({ onValueChange: changed }));
  act(() => result.current.lock("node-a"));
  expect(result.current.lockedNodeId).toBe("node-a");
  act(() => window.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape" })));
  expect(result.current.lockedNodeId).toBeNull();
  expect(changed).toHaveBeenLastCalledWith(null);
});
