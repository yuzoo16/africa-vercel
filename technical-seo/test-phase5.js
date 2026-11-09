import test from "node:test";
import assert from "node:assert/strict";
import { Phase5Audit } from "./phase5-audit.js";

test("Phase 5 audit inventories every legacy index page", async () => {
  const audit = new Phase5Audit();
  const report = await audit.run();
  assert.equal(report.pageCount, 1458);
  assert.ok(report.pages.length === report.pageCount);
});

test("Phase 5 audit preserves route normalization", () => {
  const audit = new Phase5Audit();
  assert.equal(audit.routeFromFile("index.html"), "/");
  assert.equal(audit.routeFromFile("national-parks/serengeti/index.html"), "/national-parks/serengeti/");
  assert.equal(audit.routeFromFile("404.html"), "/404/");
});
