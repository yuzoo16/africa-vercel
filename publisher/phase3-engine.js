import { cp, mkdir, readFile, readdir, rm, stat, writeFile } from "node:fs/promises";
import path from "node:path";
import crypto from "node:crypto";
import { createWriteStream } from "node:fs";
import archiver from "archiver";

export class StaticPublisher {
  constructor({ projectRoot = path.resolve(process.cwd(), ".."), now = () => new Date(), store = null } = {}) {
    this.projectRoot = projectRoot;
    this.now = now;
    this.websiteRoot = path.join(projectRoot, "Africa Safari");
    this.stagingRoot = path.join(projectRoot, "preview", "staging");
    this.inventoryFile = path.join(projectRoot, "documentation", "inventory", "website-inventory.json");
    this.store = store;
  }

  async build({ languages = ["en", "de", "fr", "es", "it"], label = "full-site" } = {}) {
    const buildId = `${this.now().toISOString().replace(/[:.]/g, "-")}-${crypto.randomBytes(3).toString("hex")}`;
    const buildRoot = path.join(this.stagingRoot, buildId);
    await rm(buildRoot, { recursive: true, force: true });
    await mkdir(buildRoot, { recursive: true });
    await cp(this.websiteRoot, buildRoot, { recursive: true, errorOnExist: false });
    if (this.store) await this.applyPublishedContent(buildRoot);

    const inventory = JSON.parse(await readFile(this.inventoryFile, "utf8"));
    const selected = inventory.pages.filter((page) => languages.includes(page.language));
    const issues = await this.validatePages(selected, buildRoot);
    const sitemaps = await this.writeSitemaps(selected, buildRoot);
    await writeFile(path.join(buildRoot, "sitemap.xml"), sitemaps.index);
    await writeFile(path.join(buildRoot, "build-manifest.json"), JSON.stringify({
      buildId,
      label,
      createdAt: this.now().toISOString(),
      languages,
      pageCount: selected.length,
      selectedPages: selected.map((page) => page.route),
      issues
    }, null, 2));
    return { buildId, buildRoot, pageCount: selected.length, issues, sitemaps };
  }

  async applyPublishedContent(buildRoot) {
    const pages = await this.store.publishedWebsitePages();
    for (const page of pages) {
      const source = path.join(buildRoot, page.sourcePath);
      if (!page.sourcePath) continue;
      if (page.status !== "published") {
        continue;
      }
      let html = await readFile(source, "utf8");
      html = this.replaceHead(html, page);
      html = html.replace(/<main\b([^>]*)>[\u0000-\uffff]*<\/main>/i, (_match, attributes) => `<main${attributes}>${page.contentHtml || ""}</main>`);
      await writeFile(source, html);
    }
  }

  async publishLive(buildId) {
    const source = path.join(this.stagingRoot, buildId);
    const liveRoot = path.join(this.projectRoot, "preview", "live");
    await stat(source).catch(() => { throw new Error("Build does not exist"); });
    await rm(liveRoot, { recursive: true, force: true });
    await mkdir(liveRoot, { recursive: true });
    await cp(source, liveRoot, { recursive: true, errorOnExist: false });
    return liveRoot;
  }

  async exportZip(buildId) {
    const source = path.join(this.stagingRoot, buildId);
    await stat(path.join(source, "build-manifest.json"));
    const exportRoot = path.join(this.projectRoot, "exports");
    await mkdir(exportRoot, { recursive: true });
    const zipPath = path.join(exportRoot, `${buildId}.zip`);
    await new Promise((resolve, reject) => {
      const output = createWriteStream(zipPath);
      const archive = archiver("zip", { zlib: { level: 9 } });
      output.on("close", resolve);
      output.on("error", reject);
      archive.on("error", reject);
      archive.pipe(output);
      archive.directory(source, false);
      archive.finalize();
    });
    return zipPath;
  }

  replaceHead(html, page) {
    const replacements = [
      [/\<title\b[^>]*>[\u0000-\uffff]*?<\/title>/i, `<title>${this.escapeHtml(page.title || "")}</title>`],
      [/\<meta\b[^>]*name=["']description["'][^>]*>/i, page.description ? `<meta name="description" content="${this.escapeHtml(page.description)}">` : ""],
      [/\<link\b[^>]*rel=["']canonical["'][^>]*>/i, page.canonicalUrl ? `<link rel="canonical" href="${this.escapeHtml(page.canonicalUrl)}">` : ""],
    ];
    for (const [pattern, replacement] of replacements) html = html.replace(pattern, replacement);
    if (page.ogTitle) html = html.replace(/<meta\b[^>]*property=["']og:title["'][^>]*>/i, `<meta property="og:title" content="${this.escapeHtml(page.ogTitle)}">`);
    if (page.ogDescription) html = html.replace(/<meta\b[^>]*property=["']og:description["'][^>]*>/i, `<meta property="og:description" content="${this.escapeHtml(page.ogDescription)}">`);
    if (page.ogImage) html = html.replace(/<meta\b[^>]*property=["']og:image["'][^>]*>/i, `<meta property="og:image" content="${this.escapeHtml(page.ogImage)}">`);
    return html;
  }

  escapeHtml(value) {
    return String(value).replaceAll("&", "&amp;").replaceAll("\"", "&quot;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");
  }

  async validatePages(pages, buildRoot) {
    const issues = [];
    const routes = new Set(pages.map((page) => page.route));
    for (const page of pages) {
      const source = path.join(this.websiteRoot, page.sourcePath);
      let html;
      try {
        html = await readFile(source, "utf8");
      } catch {
        issues.push({ type: "missing-source", route: page.route, sourcePath: page.sourcePath });
        continue;
      }
      const output = path.join(buildRoot, page.sourcePath);
      await mkdir(path.dirname(output), { recursive: true });
      await writeFile(output, html);

      const missing = [...html.matchAll(/(?:href|src)=["']([^"'#?]+)["']/gi)]
        .map((match) => match[1])
        .filter((value) => value.startsWith("/") && !this.isAsset(value) && !["/", "/index/", "/404/"].includes(this.normalizeRoute(value)) && !routes.has(this.normalizeRoute(value)));
      if (missing.length) issues.push({ type: "internal-link", route: page.route, targets: [...new Set(missing)] });
      if (!/<html\b[^>]*\blang=["'][^"']+["']/i.test(html)) issues.push({ type: "html-lang", route: page.route });
      if (!/<title\b[^>]*>[^<]+<\/title>/i.test(html)) issues.push({ type: "title", route: page.route });
      if (!html.match(/<link\b[^>]*rel=["']canonical["'][^>]*href=["'][^"']+["']/i)) {
        if (page.route !== "/404/") issues.push({ type: "canonical", route: page.route });
      }
    }
    return issues;
  }

  normalizeRoute(value) {
    const route = value.split("#")[0].split("?")[0];
    return route.endsWith("/") || route.startsWith("/asset") || route === "/" ? route : `${route}/`;
  }

  isAsset(value) {
    return /\/(?:assets|images|img|fonts|css|js)(?:\/|$)/i.test(value) || /\.[a-z0-9]{2,5}$/i.test(value);
  }

  async writeSitemaps(pages, buildRoot) {
    const languagePages = Object.groupBy ? Object.groupBy(pages, (page) => page.language) : {};
    if (!Object.groupBy) {
      for (const page of pages) (languagePages[page.language] ||= []).push(page);
    }
    const entries = [];
    const indexEntries = [];
    const sitemapRoot = path.join(this.stagingRoot, "sitemaps");
    await mkdir(sitemapRoot, { recursive: true });
    for (const [language, rows] of Object.entries(languagePages)) {
      const urls = rows.map((page) => page.canonical || `https://www.adventuresafariafrica.com${page.route}`).filter(Boolean);
      const uniqueUrls = [...new Set(urls)];
      const filename = `sitemap-${language}.xml`;
      const xml = this.sitemapXml(uniqueUrls.map((url) => ({ url })));
      await writeFile(path.join(sitemapRoot, filename), xml);
      await writeFile(path.join(buildRoot, filename), xml);
      entries.push({ language, filename });
      indexEntries.push(`  <sitemap><loc>https://www.adventuresafariafrica.com/${filename}</loc></sitemap>`);
    }
    return {
      entries,
      index: `<?xml version="1.0" encoding="UTF-8"?>\n<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${indexEntries.join("\n")}\n</sitemapindex>\n`
    };
  }

  sitemapXml(rows) {
    const urls = rows.map(({ url }) => `  <url><loc>${this.escapeXml(url)}</loc></url>`).join("\n");
    return `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${urls}\n</urlset>\n`;
  }

  escapeXml(value) {
    return value.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");
  }

  async listBuilds() {
    try {
      const buildIds = (await readdir(this.stagingRoot, { withFileTypes: true }))
        .filter((entry) => entry.isDirectory())
        .map((entry) => entry.name)
        .sort()
        .reverse();
      const records = [];
      for (const buildId of buildIds) {
        try {
          const manifest = JSON.parse(await readFile(path.join(this.stagingRoot, buildId, "build-manifest.json"), "utf8"));
          records.push({ ...manifest, issueCount: manifest.issues?.length || 0 });
        } catch {
          records.push({ buildId, incompleteManifest: true, issueCount: 0 });
        }
      }
      return records;
    } catch {
      return [];
    }
  }
}
