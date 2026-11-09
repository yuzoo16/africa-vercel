import test from "node:test";
import assert from "node:assert/strict";
import path from "node:path";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import os from "node:os";
import { StaticPublisher } from "./phase3-engine.js";
import { fileURLToPath } from "node:url";

test("publisher creates an isolated full inventory build and manifest", async () => {
  const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
  const inventory = JSON.parse(await readFile(path.join(projectRoot, "documentation", "inventory", "website-inventory.json"), "utf8"));
  const page = inventory.pages.find((entry) => entry.language === "en");
  const publisher = new StaticPublisher({
    projectRoot,
    store: {
      async publishedWebsitePages() {
        return [{
          sourcePath: page.sourcePath,
          status: "published",
          title: "Publisher test title",
          contentHtml: "<h1>CMS content survives validation</h1>"
        }];
      }
    }
  });
  const result = await publisher.build({ languages: ["en"], label: "test" });
  const manifest = JSON.parse(await readFile(path.join(result.buildRoot, "build-manifest.json"), "utf8"));
  assert.equal(manifest.buildId, result.buildId);
  assert.equal(manifest.pageCount, 318);
  assert.equal(manifest.languages[0], "en");
  assert.equal(result.pageCount, 318);
  const output = await readFile(path.join(result.buildRoot, page.sourcePath), "utf8");
  assert.match(output, /CMS content survives validation/);
  assert.match(output, /Publisher test title/);
  await rm(result.buildRoot, { recursive: true });
});
