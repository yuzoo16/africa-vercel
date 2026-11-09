import { Phase4ReleaseManager } from "./phase4-manager.js";

const buildId = process.argv[2];
if (!buildId) throw new Error("Usage: node prepare-release.js <build-id>");
const manager = new Phase4ReleaseManager();
const result = await manager.prepare(buildId);
console.log(JSON.stringify(result, null, 2));
