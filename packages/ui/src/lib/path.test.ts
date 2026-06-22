import { expect, it } from "vitest";
import { createOrganicPath } from "./path";

it("creates deterministic organic paths", () => {
  const a = { x: 0, y: 0 };
  const b = { x: 100, y: 50 };
  expect(createOrganicPath(a, b, "a")).toBe(createOrganicPath(a, b, "a"));
  expect(createOrganicPath(a, b, "a")).not.toBe(createOrganicPath(a, b, "b"));
  expect(createOrganicPath(a, b, "a")).toMatch(/^M 0 0 C .* 100 50$/);
});
