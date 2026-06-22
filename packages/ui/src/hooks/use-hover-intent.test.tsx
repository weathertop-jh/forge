import { act, renderHook } from "@testing-library/react";
import { expect, it, vi } from "vitest";
import { useHoverIntent } from "./use-hover-intent";

it("delays pointer hover and activates focus immediately", () => {
  vi.useFakeTimers();
  const { result } = renderHook(() => useHoverIntent({ enterDelay: 100 }));
  act(() => result.current.getHoverProps().onPointerEnter({ defaultPrevented: false } as never));
  expect(result.current.isHovered).toBe(false);
  act(() => vi.advanceTimersByTime(100));
  expect(result.current.isHovered).toBe(true);
  act(() => result.current.getHoverProps().onBlur({ defaultPrevented: false } as never));
  expect(result.current.isHovered).toBe(false);
  vi.useRealTimers();
});
