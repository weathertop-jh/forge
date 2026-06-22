import { render } from "@testing-library/react";
import { expect, it } from "vitest";
import { ConnectionThread } from "./connection-thread";

it("renders an inert deterministic SVG path", () => {
  const { container } = render(<svg><ConnectionThread id="edge" source={{ x: 0, y: 0 }} target={{ x: 1, y: 1 }} active /></svg>);
  expect(container.querySelector("g")).toHaveAttribute("aria-hidden", "true");
  expect(container.querySelector("path")).toHaveAttribute("d", expect.stringMatching(/^M 0 0 C .* 100 100$/));
});
