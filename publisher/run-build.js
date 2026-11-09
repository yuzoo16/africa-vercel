import { StaticPublisher } from "./phase3-engine.js";

const languages = process.argv.includes("--languages")
  ? process.argv[process.argv.indexOf("--languages") + 1].split(",")
  : ["en", "de", "fr", "es", "it"];

const publisher = new StaticPublisher();
const result = await publisher.build({ languages });
console.log(JSON.stringify({ buildId: result.buildId, pageCount: result.pageCount, issueCount: result.issues.length }, null, 2));
