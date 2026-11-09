import { readdir, readFile, writeFile, mkdir } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(scriptDirectory, "..");
const websiteRoot = path.join(projectRoot, "Africa Safari");
const outputDirectory = path.join(projectRoot, "documentation", "inventory");
const outputFile = path.join(outputDirectory, "website-inventory.json");
const languages = ["en", "de", "fr", "es", "it"];

async function listHtmlFiles(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const fullPath = path.join(directory, entry.name);
    if (entry.isDirectory()) files.push(...await listHtmlFiles(fullPath));
    else if (entry.isFile() && entry.name.endsWith(".html")) files.push(fullPath);
  }
  return files;
}

function attribute(html, name) {
  const match = html.match(new RegExp(`<${name}\\b[^>]*>`, "i"));
  return match?.[0] || null;
}

function tagValue(html, selector) {
  const match = html.match(new RegExp(`<${selector}\\b[^>]*>([^<]*)</${selector}>`, "i"));
  return match ? match[1].trim().replace(/\s+/g, " ") : null;
}

function metaContent(html, name) {
  const match = html.match(new RegExp(`<meta\\s+[^>]*\\bname=["']${name}["'][^>]*\\bcontent=["']([^"']+)["'][^>]*>`, "i"));
  return match?.[1] || null;
}

function routeFor(file) {
  const relative = path.relative(websiteRoot, file).split(path.sep).join("/");
  const directory = relative.endsWith("/index.html")
    ? relative.slice(0, -"/index.html".length)
    : relative.replace(/\.html$/, "");
  return "/" + directory.replace(/^\//, "") + (directory ? "/" : "");
}

const allHtmlFiles = await listHtmlFiles(websiteRoot);
const pages = [];

for (const file of allHtmlFiles) {
  const html = await readFile(file, "utf8");
  const relative = path.relative(websiteRoot, file).split(path.sep).join("/");
  const language = languages.find((code) => code !== "en" && relative.startsWith(`${code}/`)) || "en";
  const canonical = html.match(/<link\s+[^>]*rel=["']canonical["'][^>]*href=["']([^"']+)["']/i)?.[1] || null;
  const hreflangs = [...html.matchAll(/<link\s+[^>]*rel=["']alternate["'][^>]*hreflang=["']([^"']+)["'][^>]*href=["']([^"']+)["']/gi)]
    .map((match) => ({ language: match[1], url: match[2] }));

  pages.push({
    sourcePath: relative,
    route: routeFor(file),
    language,
    title: tagValue(html, "title"),
    description: metaContent(html, "description"),
    canonical,
    h1: tagValue(html, "h1"),
    hreflangs,
    htmlLanguage: attribute(html.replace(/\n/g, " "), "html")?.match(/\blang=["']([^"']+)/i)?.[1] || null
  });
}

const counts = Object.fromEntries(languages.map((language) => [
  language,
  pages.filter((page) => page.language === language).length
]));

await mkdir(outputDirectory, { recursive: true });
await writeFile(outputFile, JSON.stringify({
  generatedAt: new Date().toISOString(),
  websiteRoot,
  counts,
  total: pages.length,
  pages
}, null, 2));

console.log(`Inventoried ${pages.length} HTML pages: ${JSON.stringify(counts)}`);
