import test from "node:test";
import assert from "node:assert/strict";
import { mkdtemp, rm } from "node:fs/promises";
import path from "node:path";
import os from "node:os";

test("inventory has unique routes and supported language codes", async () => {
  const inventoryUrl = new URL("../../documentation/inventory/website-inventory.json", import.meta.url);
  const inventory = await import(inventoryUrl, { with: { type: "json" } }).then((module) => module.default);
  assert.equal(inventory.pages.length, 1458);
  const languages = [...new Set(inventory.pages.map((page) => page.language))];
  assert.deepEqual(languages.sort(), ["de", "en", "es", "fr", "it"]);
  assert.equal(new Set(inventory.pages.map((page) => page.route)).size, 1458);
});

test("temporary data directory can be isolated", async () => {
  const temporaryDirectory = await mkdtemp(path.join(os.tmpdir(), "asa-cms-"));
  assert.ok(temporaryDirectory);
  await rm(temporaryDirectory, { recursive: true });
});
