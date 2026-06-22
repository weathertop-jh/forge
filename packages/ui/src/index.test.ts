import { describe, expect, it } from "vitest";
import * as ui from "./index";

describe("public API", () => {
  it("exports the Forge visual primitives", () => {
    for (const name of ["CentralNode", "TierNode", "LeafNode", "ConnectionThread", "GlowShell", "ParticleField", "GraphCanvas", "useLockedNode", "useHoverIntent", "layoutGraph"]) {
      expect(ui).toHaveProperty(name);
    }
  });
});
