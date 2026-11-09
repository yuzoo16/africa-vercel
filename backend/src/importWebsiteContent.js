import "dotenv/config";
import pg from "pg";
import { readdir, readFile } from "node:fs/promises";
import path from "node:path";

if (!process.env.DATABASE_URL) throw new Error("DATABASE_URL is required");

const projectRoot = path.resolve(process.cwd(), "..");
const websiteRoot = path.join(projectRoot, "Africa Safari");
const languages = ["en", "de", "fr", "es", "it"];

async function htmlFiles(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const fullPath = path.join(directory, entry.name);
    if (entry.isDirectory()) files.push(...await htmlFiles(fullPath));
    else if (entry.isFile() && entry.name.toLowerCase().endsWith(".html")) files.push(fullPath);
  }
  return files;
}

function decodeEntities(value) {
  return value
    .replace(/&amp;/gi, "&")
    .replace(/&quot;/gi, '"')
    .replace(/&#39;|&apos;/gi, "'")
    .replace(/&lt;/gi, "<")
    .replace(/&gt;/gi, ">");
}

function tagText(html, tag) {
  const match = html.match(new RegExp(`<${tag}\\b[^>]*>([\u0000-\uffff]*?)</${tag}>`, "i"));
  return match ? decodeEntities(match[1].replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim()) : null;
}

function metaContent(html, attributeName, attributeValue) {
  const match = html.match(new RegExp(`<meta\\b[^>]*(?:name|property)=["']${attributeName}["'][^>]*content=["']([^"']*)["'][^>]*>`, "i"))
    || html.match(new RegExp(`<meta\\b[^>]*content=["']([^"']*)["'][^>]*(?:name|property)=["']${attributeName}["'][^>]*>`, "i"));
  if (match) return decodeEntities(match[1]);
  void attributeValue;
  return null;
}

function linkContent(html, rel, attribute) {
  const match = html.match(new RegExp(`<link\\b[^>]*rel=["']${rel}["'][^>]*${attribute}=["']([^"']+)["'][^>]*>`, "i"))
    || html.match(new RegExp(`<link\\b[^>]*${attribute}=["']([^"']+)["'][^>]*rel=["']${rel}["'][^>]*>`, "i"));
  return match?.[1] || null;
}

function mainContent(html) {
  const match = html.match(/<main\b[^>]*>([\u0000-\uffff]*?)<\/main>/i);
  return match?.[1] || null;
}

function routeFor(file) {
  const relative = path.relative(websiteRoot, file).split(path.sep).join("/");
  const directory = relative.endsWith("/index.html")
    ? relative.slice(0, -"/index.html".length)
    : relative.replace(/\.html$/, "");
  return "/" + directory.replace(/^\//, "") + (directory ? "/" : "");
}

function languageFor(relative) {
  const prefix = relative.split("/")[0];
  return languages.includes(prefix) && prefix !== "en" ? prefix : "en";
}

function typeFor(relative, route) {
  if (/^\/?blog(?:\/|$)/.test(route) && !route.includes("/category/")) return "blog";
  if (route.includes("/category/")) return "category";
  if (relative === "404.html") return "error";
  return "page";
}

const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });
const client = await pool.connect();
const files = await htmlFiles(websiteRoot);
const report = { discovered: files.length, imported: 0, updated: 0, failed: [] };

try {
  await client.query("BEGIN");
  for (const file of files) {
    const relative = path.relative(websiteRoot, file).split(path.sep).join("/");
    const language = languageFor(relative);
    try {
      const html = await readFile(file, "utf8");
      const route = routeFor(file);
      const content = mainContent(html);
      if (!content) throw new Error("No <main> content block found");
      const title = tagText(html, "title");
      const description = metaContent(html, "description");
      const h1 = tagText(html, "h1");
      const canonical = linkContent(html, "canonical", "href");
      const ogTitle = metaContent(html, "og:title");
      const ogDescription = metaContent(html, "og:description");
      const ogImage = metaContent(html, "og:image");
      const robots = metaContent(html, "robots");
      const featuredImage = content.match(/<img\b[^>]*\bsrc=["']([^"']+)["'][^>]*>/i)?.[1] || ogImage || null;
      const hreflang = [...html.matchAll(/<link\b[^>]*rel=["']alternate["'][^>]*hreflang=["']([^"']+)["'][^>]*href=["']([^"']+)["'][^>]*>/gi)]
        .reduce((result, match) => { result[match[1]] = match[2]; return result; }, {});
      const structuredData = [...html.matchAll(/<script\b[^>]*type=["']application\/ld\+json["'][^>]*>([\u0000-\uffff]*?)<\/script>/gi)]
        .map((match) => {
          try { return JSON.parse(match[1]); } catch { return null; }
        })
        .filter(Boolean);

      const languageResult = await client.query("SELECT id FROM languages WHERE code=$1", [language]);
      if (!languageResult.rows.length) throw new Error(`Missing language ${language}`);

      let page = await client.query(
        "SELECT id FROM pages WHERE legacy_source_path=$1 LIMIT 1",
        [relative],
      );
      let pageId;
      if (page.rows.length) pageId = page.rows[0].id;
      else {
        const inserted = await client.query(
          `INSERT INTO pages (page_type, template, legacy_source_path, created_at, updated_at)
           VALUES ($1,'standard',$2,NOW(),NOW()) RETURNING id`,
          [typeFor(relative, route), relative],
        );
        pageId = inserted.rows[0].id;
        report.imported++;
      }

      const result = await client.query(
        `INSERT INTO page_translations
          (page_id, language_id, slug, full_path, title, description, h1, status, content_html,
           featured_image, canonical_url, og_title, og_description, og_image, robots, hreflang, structured_data,
           created_at, updated_at)
         VALUES ($1,$2,$3,$4,$5,$6,$7,'published',$8,$9,$10,$11,$12,$13,$14,$15::jsonb,$16::jsonb,NOW(),NOW())
         ON CONFLICT (page_id, language_id) DO UPDATE SET
           slug=EXCLUDED.slug, full_path=EXCLUDED.full_path, title=EXCLUDED.title,
           description=EXCLUDED.description, h1=EXCLUDED.h1, content_html=EXCLUDED.content_html,
           featured_image=EXCLUDED.featured_image, canonical_url=EXCLUDED.canonical_url,
           og_title=EXCLUDED.og_title, og_description=EXCLUDED.og_description,
           og_image=EXCLUDED.og_image, robots=COALESCE(EXCLUDED.robots, page_translations.robots),
           hreflang=EXCLUDED.hreflang, structured_data=EXCLUDED.structured_data, updated_at=NOW()
         RETURNING (xmax = 0) AS inserted`,
        [pageId, languageResult.rows[0].id, route, route, title, description, h1, content,
          featuredImage, canonical, ogTitle, ogDescription, ogImage, robots || "index,follow",
          JSON.stringify(hreflang), JSON.stringify(structuredData)],
      );
      if (!result.rows[0].inserted) report.updated++;
    } catch (error) {
      report.failed.push({ sourcePath: relative, reason: error.message });
    }
  }
  await client.query("COMMIT");
  console.log(JSON.stringify(report, null, 2));
} catch (error) {
  await client.query("ROLLBACK");
  throw error;
} finally {
  client.release();
  await pool.end();
}
