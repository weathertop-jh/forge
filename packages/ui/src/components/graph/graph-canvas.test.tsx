import { render, screen } from "@testing-library/react";
import { expect, it } from "vitest";
import { GraphCanvas, GraphCanvasForeground, GraphCanvasNodes, GraphCanvasParticles, GraphCanvasThreads } from ".";

it("renders ordered hybrid graph layers", () => {
  const { container } = render(<GraphCanvas><GraphCanvasParticles /><GraphCanvasThreads /><GraphCanvasNodes><button>Node</button></GraphCanvasNodes><GraphCanvasForeground>Tools</GraphCanvasForeground></GraphCanvas>);
  expect([...container.querySelectorAll("[data-graph-layer]")].map((node) => node.getAttribute("data-graph-layer"))).toEqual(["particles", "threads", "nodes", "foreground"]);
  expect(screen.getByRole("button", { name: "Node" })).toBeInTheDocument();
  expect(container.querySelector("svg")).toHaveAttribute("viewBox", "0 0 100 100");
});
