import { createHash } from "node:crypto";
import { cp, mkdir, readFile, readdir, stat, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

export class Phase4ReleaseManager {
  constructor({ projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..") } = {}) {
    this.projectRoot = projectRoot;
    this.stagingRoot = path.join(projectRoot, "preview", "staging");
    this.releaseRoot = path.join(projectRoot, "deployment", "releases");
    this.backupRoot = path.join(projectRoot, "deployment", "backups");
  }

  async prepare(buildId) {
    const source = path.join(this.stagingRoot, buildId);
    await stat(path.join(source, "build-manifest.json"));
    await mkdir(this.releaseRoot, { recursive: true });
    const releaseId = `${buildId}-release`;
    const destination = path.join(this.releaseRoot, releaseId);
    await cp(source, destination, { recursive: true, errorOnExist: false });
    const manifest = JSON.parse(await readFile(path.join(destination, "build-manifest.json"), "utf8"));
    if ((manifest.issues || []).length) throw new Error(`Build has ${manifest.issues.length} unresolved validation issues`);

    const checksums = await this.checksumTree(destination);
    await writeFile(path.join(destination, "release-checksums.sha256"), checksums.map((row) => `${row.hash}  ${row.path}`).join("\n") + "\n");
    await writeFile(path.join(destination, "release.json"), JSON.stringify({
      releaseId,
      sourceBuildId: buildId,
      preparedAt: new Date().toISOString(),
      deployed: false,
      productionTarget: null,
      rollbackReady: false,
      fileCount: checksums.length
    }, null, 2));
    return { releaseId, destination, fileCount: checksums.length };
  }

  async checksumTree(root) {
    const rows = [];
    async function visit(directory) {
      for (const entry of await readdir(directory, { withFileTypes: true })) {
        const fullPath = path.join(directory, entry.name);
        if (entry.isDirectory()) await visit(fullPath);
        else if (entry.name !== "release-checksums.sha256" && entry.name !== "release.json") {
          const content = await readFile(fullPath);
          rows.push({
            path: path.relative(root, fullPath).split(path.sep).join("/"),
            hash: createHash("sha256").update(content).digest("hex")
          });
        }
      }
    }
    await visit(root);
    return rows.sort((left, right) => left.path.localeCompare(right.path));
  }

  async verifyRelease(releaseId) {
    const releaseRoot = path.join(this.releaseRoot, releaseId);
    const manifest = JSON.parse(await readFile(path.join(releaseRoot, "release.json"), "utf8"));
    const expected = (await readFile(path.join(releaseRoot, "release-checksums.sha256"), "utf8"))
      .trim().split(/\r?\n/).filter(Boolean).map((line) => line.match(/^([a-f0-9]{64})  (.+)$/)).filter(Boolean);
    const actual = await this.checksumTree(releaseRoot);
    if (actual.length !== expected.length) throw new Error(`Release checksum count differs: expected ${expected.length}, found ${actual.length}`);
    const actualHashes = new Map(actual.map((row) => [row.path, row.hash]));
    const mismatches = [];
    for (const [, hash, filePath] of expected.map((match) => match)) {
      if (actualHashes.get(filePath) !== hash) mismatches.push(filePath);
    }
    return { releaseId: manifest.releaseId, valid: mismatches.length === 0, fileCount: actual.length, mismatches };
  }

  async createBackup(label = "pre-production-backup") {
    await mkdir(this.backupRoot, { recursive: true });
    const legacyRoot = path.join(this.projectRoot, "Africa Safari");
    const backupId = `${new Date().toISOString().replace(/[:.]/g, "-")}-${label}`;
    const destination = path.join(this.backupRoot, backupId);
    await cp(legacyRoot, destination, { recursive: true, errorOnExist: false });
    const manifest = {
      backupId,
      createdAt: new Date().toISOString(),
      source: "Africa Safari",
      deployed: false
    };
    await writeFile(path.join(destination, "backup-manifest.json"), JSON.stringify(manifest, null, 2));
    return manifest;
  }

  async authorizeDeploy({ releaseId, authorizationToken }) {
    if (!process.env.CMS_PRODUCTION_DEPLOY_TOKEN || !authorizationToken) {
      throw new Error("Explicit production deployment authorization is required");
    }
    if (process.env.CMS_PRODUCTION_DEPLOY_TOKEN !== authorizationToken) {
      throw new Error("Production deployment authorization token is invalid");
    }
    throw new Error("Live deployment is intentionally disabled in Phase 4");
  }
}
