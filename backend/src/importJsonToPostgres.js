import "dotenv/config";
import pg from "pg";
import { copyFile, readFile, mkdir } from "node:fs/promises";
import path from "node:path";
import crypto from "node:crypto";

if (!process.env.DATABASE_URL) throw new Error("DATABASE_URL is required");

const projectRoot = path.resolve(process.cwd(), "..");
const source = path.join(projectRoot, "database", "runtime", "cms.json");
const backupDirectory = path.join(projectRoot, "database", "runtime", "backups");
await mkdir(backupDirectory, { recursive: true });
const stamp = new Date().toISOString().replace(/[:.]/g, "-");
const backup = path.join(backupDirectory, `cms-${stamp}.json`);
await copyFile(source, backup);
const data = JSON.parse(await readFile(source, "utf8"));
const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });
const client = await pool.connect();
const counts = {};

try {
  await client.query("BEGIN");

  for (const [index, page] of (data.pages || []).entries()) {
    const pageId = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(page.id || "")
      ? page.id : crypto.randomUUID();
    await client.query(`INSERT INTO pages (id, page_type, template, legacy_source_path, created_at, updated_at)
      VALUES ($1,$2,$3,$4,$5,NOW())
      ON CONFLICT (id) DO UPDATE SET page_type=EXCLUDED.page_type, template=EXCLUDED.template,
      legacy_source_path=EXCLUDED.legacy_source_path, updated_at=NOW()`,
      [pageId, page.category || "page", "standard", page.sourcePath || null, page.createdAt || new Date().toISOString()]);

    const language = await client.query("SELECT id FROM languages WHERE code=$1", [page.language || "en"]);
    if (!language.rows.length) throw new Error(`Missing language row for ${page.language}`);
    await client.query(`INSERT INTO page_translations
      (page_id, language_id, slug, full_path, title, description, h1, status, created_at, updated_at)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8::publication_status,$9,NOW())
      ON CONFLICT (page_id, language_id) DO UPDATE SET slug=EXCLUDED.slug, full_path=EXCLUDED.full_path,
      title=EXCLUDED.title, description=EXCLUDED.description, h1=EXCLUDED.h1, status=EXCLUDED.status, updated_at=NOW()`,
      [pageId, language.rows[0].id, page.slug || page.fullPath || "", page.fullPath || page.slug || "", page.title || null,
        page.description || null, page.h1 || null, ["draft", "in_review", "approved", "published", "archived"].includes(page.status) ? page.status : "published",
        page.createdAt || page.updatedAt || new Date().toISOString()]);
  }
  counts.pages = data.pages?.length || 0;

  const moduleTables = {
    packages: "safari_packages",
    destinations: "destinations",
    parks: "national_parks",
    experiences: "safari_experiences",
    accommodation: "accommodation",
    guides: "travel_guides",
    blogs: "blogs"
  };
  for (const [collection, table] of Object.entries(moduleTables)) {
    let imported = 0;
    for (const row of data[collection] || []) {
      if (!Object.keys(row).some((key) => key !== "id")) continue;
      const columns = ["overview", "attractions", "wildlife", "activities", "amenities", "itinerary", "included_services", "excluded_services", "location", "ecosystems"];
      const values = [];
      const assignments = [];
      for (const [key, value] of Object.entries(row)) {
        if (["id", "createdAt", "updatedAt"].includes(key)) continue;
        const column = key.replace(/[A-Z]/g, (letter) => `_${letter.toLowerCase()}`);
        if (!["page_id", "status", "duration_days", "starting_price", "category", "country", "overview", "attractions",
          "wildlife", "activities", "amenities", "itinerary", "included_services", "excluded_services", "location",
          "ecosystems", "experience_type", "property_type", "destination", "guide_type", "author", "tags",
          "publication_date"].includes(column)) continue;
        assignments.push(`"${column}"`);
        values.push(column === "status" ? String(value) : typeof value === "object" ? JSON.stringify(value) : value);
      }
      assignments.push("created_at");
      assignments.push("updated_at");
      values.push(row.createdAt || new Date().toISOString(), row.updatedAt || new Date().toISOString());
      await client.query(`INSERT INTO ${table} (${assignments.join(", ")}) VALUES (${values.map((_, index) => `$${index + 1}`).join(", ")})`,
        values);
      imported++;
    }
    counts[collection] = imported;
  }
  await client.query("COMMIT");
  console.log(JSON.stringify({ backup, counts }, null, 2));
} catch (error) {
  await client.query("ROLLBACK");
  throw error;
} finally {
  client.release();
  await pool.end();
}
