import "dotenv/config";
import pg from "pg";
import { readdir, readFile } from "node:fs/promises";
import path from "node:path";

if (!process.env.DATABASE_URL) throw new Error("DATABASE_URL is required");

const databaseDirectory = path.resolve(process.cwd(), "..", "database");
const migrations = (await readdir(databaseDirectory))
  .filter((file) => /^\d{3}_.+\.sql$/.test(file))
  .sort();

const client = new pg.Client({ connectionString: process.env.DATABASE_URL });
await client.connect();

try {
  await client.query("BEGIN");
  await client.query("CREATE TABLE IF NOT EXISTS schema_migrations (name text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now())");
  const applied = await client.query("SELECT name FROM schema_migrations");
  const completed = new Set(applied.rows.map((row) => row.name));

  for (const migration of migrations) {
    if (completed.has(migration)) continue;
    await client.query(await readFile(path.join(databaseDirectory, migration), "utf8"));
    await client.query("INSERT INTO schema_migrations (name) VALUES ($1)", [migration]);
    console.log(`Applied ${migration}`);
  }
  await client.query("COMMIT");
} catch (error) {
  await client.query("ROLLBACK");
  throw error;
} finally {
  await client.end();
}
