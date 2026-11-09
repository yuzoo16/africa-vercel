import { readFile, readdir, stat, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

export class Phase5Audit {
  constructor({ projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..") } = {}) {
    this.projectRoot = projectRoot;
    this.websiteRoot = path.join(projectRoot, "Africa Safari");
  }

  async run() {
    const files = await this.findHtml(this.websiteRoot);
    const pages = [];
    const issues = [];
    const fileSet = new Set(await this.findAllFiles(this.websiteRoot));
    const normalizedFileSet = new Set([...fileSet].map((file) => decodeURI(file).toLowerCase()));

    for (const absolutePath of files) {
      const html = await readFile(absolutePath, "utf8");
      const relative = path.relative(this.websiteRoot, absolutePath).split(path.sep).join("/");
      const route = this.routeFromFile(relative);
      const pageIssues = [];
      const isNotFoundPage = route === "/404/";

      if (!isNotFoundPage && !/<meta\b[^>]*name=["']description["'][^>]*content=["'][^"']+/i.test(html)) pageIssues.push("missing-description");
      if (!isNotFoundPage && !/<link\b[^>]*rel=["']canonical["'][^>]*href=["'][^"']+/i.test(html)) pageIssues.push("missing-canonical");
      if (!/<html\b[^>]*lang=["'][^"']+["']/i.test(html)) pageIssues.push("missing-html-lang");
      if (!/<title\b[^>]*>[^<]+<\/title>/i.test(html)) pageIssues.push("missing-title");
      const h1Count = [...html.matchAll(/<h1\b[^>]*>/gi)].length;
      if (h1Count === 0) pageIssues.push("missing-h1");
      if (h1Count > 1) pageIssues.push("multiple-h1");
      const hreflangs = [...html.matchAll(/hreflang=["']([^"']+)["']/gi)].map((match) => match[1]);
      if (!isNotFoundPage && hreflangs.length > 0) {
        const required = ["en", "de", "fr", "es", "it", "x-default"];
        const missing = required.filter((language) => !hreflangs.includes(language));
        if (missing.length) pageIssues.push(`missing-hreflang:${missing.join(",")}`);
      } else if (!isNotFoundPage) {
        pageIssues.push("missing-hreflang");
      }
      if (!isNotFoundPage && !/type=["']application\/ld\+json["']/i.test(html)) pageIssues.push("missing-structured-data");
      if (!isNotFoundPage && !/<meta\b[^>]*property=["']og:title["']/i.test(html)) pageIssues.push("missing-open-graph");

      const imagesWithoutAlt = [...html.matchAll(/<img\b[^>]*>/gi)]
        .filter((match) => !/\balt=["'][^"']*["']/i.test(match[0])).length;
      if (imagesWithoutAlt) pageIssues.push(`images-without-alt:${imagesWithoutAlt}`);
      const missingAssets = [...html.matchAll(/(?:src|href)=["'](\/[^"'?#]+)["']/gi)]
        .map((match) => match[1])
        .filter((value) => this.isLocalAsset(value))
        .filter((value) => !normalizedFileSet.has(decodeURI(this.normalizeSitePath(value)).toLowerCase()))
        .filter((value, index, values) => values.indexOf(value) === index);
      if (missingAssets.length) pageIssues.push(`missing-assets:${missingAssets.join(",")}`);

      pages.push({
        route,
        h1Count,
        hreflangCount: hreflangs.length,
        structuredData: /type=["']application\/ld\+json["']/i.test(html),
        issueCount: pageIssues.length
      });
      for (const issue of pageIssues) issues.push({ route, type: issue });
    }

    let robots = "";
    try {
      robots = await readFile(path.join(this.websiteRoot, "robots.txt"), "utf8");
    } catch {
      issues.push({ route: "/robots.txt", type: "missing-robots" });
    }
    if (robots && !/^Sitemap:/im.test(robots)) issues.push({ route: "/robots.txt", type: "missing-sitemap-declaration" });
    try {
      await stat(path.join(this.websiteRoot, "sitemap.xml"));
    } catch {
      issues.push({ route: "/sitemap.xml", type: "missing-sitemap" });
    }

    const issueTypes = {};
    for (const issue of issues) issueTypes[issue.type] = (issueTypes[issue.type] || 0) + 1;
    return {
      auditedAt: new Date().toISOString(),
      pageCount: pages.length,
      pages,
      issues,
      issueTypes,
      summary: {
        pagesWithIssues: pages.filter((page) => page.issueCount > 0).length,
        issueCount: issues.length
      }
    };
  }

  async findHtml(directory) {
    const files = [];
    for (const entry of await readdir(directory, { withFileTypes: true })) {
      const absolutePath = path.join(directory, entry.name);
      if (entry.isDirectory()) files.push(...await this.findHtml(absolutePath));
      else if (entry.name.toLowerCase().endsWith(".html")) files.push(absolutePath);
    }
    return files;
  }

  async findAllFiles(directory, prefix = "") {
    const files = [];
    for (const entry of await readdir(directory, { withFileTypes: true })) {
      const relative = prefix ? `${prefix}/${entry.name}` : entry.name;
      const absolutePath = path.join(directory, entry.name);
      if (entry.isDirectory()) files.push(...await this.findAllFiles(absolutePath, relative));
      else files.push(relative);
    }
    return files;
  }

  routeFromFile(relative) {
    if (relative.toLowerCase() === "404.html") return "/404/";
    return relative === "index.html" ? "/" : `/${relative.replace(/\/index\.html$/i, "")}/`;
  }

  normalizeSitePath(value) {
    return value.replace(/^\/+/, "").replace(/\/+$/, "");
  }

  isLocalAsset(value) {
    return /^\/(?:assets|images|img|fonts|css|js)(?:\/|$)/i.test(value) || /\.[a-z0-9]{2,5}$/i.test(value);
  }

  async writeReport(destination) {
    const report = await this.run();
    await writeFile(destination, JSON.stringify(report, null, 2));
    return report;
  }
}
