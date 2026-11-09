import path from "node:path";
import { mkdir } from "node:fs/promises";
import { Phase6Acceptance } from "./phase6-acceptance.js";

const outputDirectory = path.resolve(process.argv[2] || "../documentation/qa");
await mkdir(outputDirectory, { recursive: true });
const report = await new Phase6Acceptance().writeReport(path.join(outputDirectory, "phase6-acceptance.json"));
console.log(JSON.stringify({
  status: report.status,
  passed: report.passed,
  failed: report.failed,
  totalChecks: report.totalChecks,
  output: path.join(outputDirectory, "phase6-acceptance.json")
}, null, 2));
