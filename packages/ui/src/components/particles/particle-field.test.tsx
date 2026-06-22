import { render } from "@testing-library/react";
import { expect, it } from "vitest";
import { ParticleField } from "./particle-field";

it("renders seeded decorative particles", () => {
  const first = render(<ParticleField seed="forge" count={5} />).container.innerHTML;
  const second = render(<ParticleField seed="forge" count={5} />).container.innerHTML;
  expect(first).toBe(second);
  expect(first.match(/data-particle/g)).toHaveLength(5);
});
