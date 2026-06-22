import { render, screen } from "@testing-library/react";
import { expect, it } from "vitest";
import { CentralNode, LeafNode, TierNode } from ".";

it("renders semantic tier nodes", () => {
  render(<><CentralNode label="Home" /><TierNode label="Work" expanded /><LeafNode label="Article" href="/article" /></>);
  expect(screen.getByRole("button", { name: "Home" })).toHaveAttribute("type", "button");
  expect(screen.getByRole("button", { name: "Work" })).toHaveAttribute("aria-expanded", "true");
  expect(screen.getByRole("link", { name: "Article" })).toHaveAttribute("href", "/article");
});
