import test from "node:test";
import assert from "node:assert/strict";
import path from "node:path";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import os from "node:os";
import { StaticPublisher } from "./phase3-engine.js";
import { fileURLToPath } from "node:url";

test("publisher creates an isolated full inventory build and manifest", async () => {
  const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
  const publisher = new StaticPublisher({ projectRoot });
  const result = await publisher.build({ languages: ["en"], label: "test" });
  const manifest = JSON.parse(await readFile(path.join(result.buildRoot, "build-manifest.json"), "utf8"));
  assert.equal(manifest.buildId, result.buildId);
  assert.equal(manifest.pageCount, 318);
  assert.equal(manifest.languages[0], "en");
  assert.equal(result.pageCount, 318);
  await rm(result.buildRoot, { recursive: true });
});
