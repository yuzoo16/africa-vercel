import { readFile, writeFile, mkdir } from "node:fs/promises";
import path from "node:path";
import crypto from "node:crypto";

const storeDirectory = path.resolve(process.cwd(), "..", "database", "runtime");
const storeFile = path.join(storeDirectory, "cms.json");

function id() {
  return crypto.randomUUID();
}

export async function localStore() {
  await mkdir(storeDirectory, { recursive: true });
  let data;
  try {
    data = JSON.parse(await readFile(storeFile, "utf8"));
  } catch {
    const inventoryFile = path.resolve(storeDirectory, "..", "..", "documentation", "inventory", "website-inventory.json");
    let inventory = { pages: [], counts: {} };
    try {
      inventory = JSON.parse(await readFile(inventoryFile, "utf8"));
    } catch {}

    data = {
      pages: inventory.pages.map((page, index) => ({
        id: id(),
        legacyId: index + 1,
        title: page.title,
        slug: page.route,
        fullPath: page.route,
        language: page.language,
        category: page.sourcePath.split("/")[0] || "page",
        status: "published",
        sourcePath: page.sourcePath,
        updatedAt: new Date().toISOString()
      })),
      packages: [],
      destinations: [],
      parks: [],
      experiences: [],
      accommodation: [],
      guides: [],
      blogs: [],
      media: [],
      navigation: [],
      revisions: [],
      publishing: [],
      translations: [],
      blocks: [],
      users: []
    };
    await writeFile(storeFile, JSON.stringify(data, null, 2));
  }
  return {
    async read() {
      return JSON.parse(await readFile(storeFile, "utf8"));
    },
    async write(nextData) {
      await writeFile(storeFile, JSON.stringify(nextData, null, 2));
    },
    async list(collection, query = {}) {
      const data = await this.read();
      let rows = [...(data[collection] || [])];
      const search = String(query.search || "").trim().toLowerCase();
      const language = String(query.language || "");
      const status = String(query.status || "");
      const category = String(query.category || "");
      if (search) rows = rows.filter((row) => Object.values(row).join(" ").toLowerCase().includes(search));
      if (language) rows = rows.filter((row) => row.language === language);
      if (status) rows = rows.filter((row) => row.status === status);
      if (category) rows = rows.filter((row) => row.category === category);
      const page = Math.max(1, Number(query.page || 1));
      const limit = Math.min(100, Math.max(1, Number(query.limit || 25)));
      const total = rows.length;
      return { rows: rows.slice((page - 1) * limit, page * limit), total, page, limit };
    },
    async create(collection, input) {
      const data = await this.read();
      const now = new Date().toISOString();
      const row = { id: id(), ...input, createdAt: now, updatedAt: now };
      data[collection] = [...(data[collection] || []), row];
      await this.write(data);
      return row;
    },
    async update(collection, rowId, input) {
      const data = await this.read();
      const index = (data[collection] || []).findIndex((row) => row.id === rowId);
      if (index === -1) return null;
      const previous = data[collection][index];
      const row = { ...previous, ...input, id: previous.id, updatedAt: new Date().toISOString() };
      data[collection][index] = row;
      data.revisions.unshift({
        id: id(),
        collection,
        recordId: rowId,
        action: "update",
        previous: { ...previous },
        snapshot: { ...row },
        createdAt: new Date().toISOString()
      });
      await this.write(data);
      return row;
    },
    async remove(collection, rowId) {
      const data = await this.read();
      const before = (data[collection] || []).length;
      data[collection] = (data[collection] || []).filter((row) => row.id !== rowId);
      await this.write(data);
      return data[collection].length < before;
    }
  };
}
