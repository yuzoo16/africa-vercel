import { readFile, readdir, stat, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

export class Phase6Acceptance {
  constructor({ projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..") } = {}) {
    this.projectRoot = projectRoot;
  }

  expectedPageCount(inventory) {
    return Object.values(inventory.counts).reduce((sum, count) => sum + Number(count), 0);
  }

  async run() {
    const checks = [];
    const check = (id, condition, detail) => checks.push({ id, passed: Boolean(condition), detail });

    const inventory = JSON.parse(await readFile(path.join(this.projectRoot, "documentation", "inventory", "website-inventory.json"), "utf8"));
    check("inventory-total", this.expectedPageCount(inventory) === 1458 && inventory.total === 1458, `${inventory.total} inventory pages`);

    for (const language of ["en", "de", "fr", "es", "it"]) {
      check(`inventory-${language}`, Number(inventory.counts[language]) > 0, `${inventory.counts[language]} pages`);
    }

    const dashboardDist = path.join(this.projectRoot, "dashboard", "dist", "index.html");
    check("dashboard-build", await this.exists(dashboardDist), "dashboard production output exists");
    check("publisher-manifest", await this.exists(path.join(this.projectRoot, "preview", "staging")), "staging publisher output exists");
    check("phase5-report", await this.exists(path.join(this.projectRoot, "documentation", "seo", "phase5-audit.json")), "SEO audit report exists");
    check("phase4-release", await this.exists(path.join(this.projectRoot, "deployment", "releases")), "release output exists");
    check("legacy-not-deployed", !(await this.exists(path.join(this.projectRoot, "deployment", "production-live"))), "no production-live marker exists");

    const backendSyntax = spawnSync(process.execPath, ["--check", path.join(this.projectRoot, "backend", "src", "server.js")], { encoding: "utf8" });
    check("backend-syntax", backendSyntax.status === 0, backendSyntax.status === 0 ? "server.js syntax valid" : backendSyntax.stderr.trim());

    const passed = checks.filter((item) => item.passed).length;
    return {
      auditedAt: new Date().toISOString(),
      totalChecks: checks.length,
      passed,
      failed: checks.length - passed,
      status: passed === checks.length ? "ready-with-gates" : "blocked",
      checks
    };
  }

  async exists(target) {
    try {
      await stat(target);
      return true;
    } catch {
      return false;
    }
  }

  async writeReport(destination) {
    const report = await this.run();
    await writeFile(destination, JSON.stringify(report, null, 2));
    return report;
  }
}
