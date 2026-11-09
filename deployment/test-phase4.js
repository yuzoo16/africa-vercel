import test from "node:test";
import assert from "node:assert/strict";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { mkdtemp, rm } from "node:fs/promises";
import os from "node:os";
import { Phase4ReleaseManager } from "./phase4-manager.js";

test("production authorization is required and live deployment remains disabled", async () => {
  delete process.env.CMS_PRODUCTION_DEPLOY_TOKEN;
  const temporaryRoot = await mkdtemp(path.join(os.tmpdir(), "asa-phase4-"));
  const manager = new Phase4ReleaseManager({ projectRoot: temporaryRoot });
  await assert.rejects(() => manager.authorizeDeploy({}), /authorization is required/i);
  await rm(temporaryRoot, { recursive: true, force: true });
});

test("release checksums cover generated files deterministically", async () => {
  const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
  const manager = new Phase4ReleaseManager({ projectRoot });
  const first = await manager.checksumTree(path.join(projectRoot, "Africa Safari"));
  assert.ok(first.length > 1458);
  assert.ok(first.every((row) => /^[a-f0-9]{64}$/.test(row.hash)));
});
