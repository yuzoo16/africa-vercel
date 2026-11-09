import "dotenv/config";
import bcrypt from "bcryptjs";
import { PostgresStore } from "./postgresStore.js";
import readline from "node:readline/promises";
import { readHiddenPassword } from "./hiddenInput.js";

if (!process.env.DATABASE_URL) throw new Error("DATABASE_URL is required");

let email = String(process.env.CMS_BOOTSTRAP_USER_EMAIL || "").trim().toLowerCase();
if (!email && process.stdin.isTTY) {
  const input = readline.createInterface({ input: process.stdin, output: process.stdout });
  email = String(await input.question("Administrator email: ")).trim().toLowerCase();
  input.close();
}
if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
  throw new Error("CMS_BOOTSTRAP_USER_EMAIL must contain a valid administrator email");
}
const password = await readHiddenPassword(process.stdin, process.stdout, "Administrator password: ");
if (password.length < 12 || Buffer.byteLength(password, "utf8") > 72) {
  throw new Error("Administrator password must contain at least 12 characters and at most 72 UTF-8 bytes");
}
const passwordHash = await bcrypt.hash(password, 12);
const store = new PostgresStore(process.env.DATABASE_URL);
try {
  await store.verify();
  const result = await store.bootstrapAdministrator(email, passwordHash);
  if (result.created) {
    await store.recordAudit("administrator_bootstrap", "user", result.userId, {}, result.userId);
    console.log("Administrator bootstrap completed.");
  } else {
    console.log("Administrator bootstrap already complete.");
  }
} finally {
  await store.close();
}
