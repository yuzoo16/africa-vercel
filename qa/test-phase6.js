import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { Phase6Acceptance } from "./phase6-acceptance.js";

test("acceptance audit recognizes required project phases", async () => {
  const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
  const acceptance = new Phase6Acceptance({ projectRoot });
  const inventory = JSON.parse(await readFile(path.join(projectRoot, "documentation", "inventory", "website-inventory.json"), "utf8"));
  assert.equal(acceptance.expectedPageCount(inventory), 1458);
});
