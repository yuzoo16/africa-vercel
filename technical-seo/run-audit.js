import path from "node:path";
import { mkdir } from "node:fs/promises";
import { Phase5Audit } from "./phase5-audit.js";

const outputDirectory = path.resolve(process.argv[2] || "../documentation/seo");
await mkdir(outputDirectory, { recursive: true });
const report = await new Phase5Audit().writeReport(path.join(outputDirectory, "phase5-audit.json"));
console.log(JSON.stringify({
  pageCount: report.pageCount,
  pagesWithIssues: report.summary.pagesWithIssues,
  issueCount: report.summary.issueCount,
  issueTypes: report.issueTypes,
  output: path.join(outputDirectory, "phase5-audit.json")
}, null, 2));
