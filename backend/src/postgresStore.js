import pg from "pg";

const tableMap = {
  packages: "safari_packages",
  destinations: "destinations",
  parks: "national_parks",
  experiences: "safari_experiences",
  accommodation: "accommodation",
  guides: "travel_guides",
  blogs: "blogs",
  navigation: "navigation_menus",
  publishing: "publishing_jobs"
};

const columnMap = {
  fullPath: "full_path",
  sourcePath: "legacy_source_path",
  languageId: "language_id",
  pageId: "page_id",
  fileName: "file_name",
  mimeType: "mime_type",
  byteSize: "byte_size",
  storageKey: "storage_key",
  altText: "alt_text",
  displayName: "display_name",
  passwordHash: "password_hash",
  recordId: "record_id",
  createdAt: "created_at",
  updatedAt: "updated_at",
  sourcePath: "source_path",
  destinationPath: "destination_path",
  statusCode: "status_code",
  isVisible: "is_visible",
  isActive: "is_active",
  isHidden: "is_hidden",
  blockType: "block_type",
  publicationDate: "publication_date"
};

function toSnake(value) {
  return columnMap[value] || value.replace(/[A-Z]/g, (letter) => `_${letter.toLowerCase()}`);
}

function databaseRow(row) {
  const result = {};
  for (const [key, value] of Object.entries(row || {})) {
    const camel = key.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
    result[camel] = value;
  }
  return result;
}

export class PostgresStore {
  constructor(connectionString) {
    this.pool = new pg.Pool({
      connectionString,
      max: Number(process.env.CMS_DB_POOL_MAX || 10),
      idleTimeoutMillis: Number(process.env.CMS_DB_IDLE_TIMEOUT_MS || 30000),
      connectionTimeoutMillis: Number(process.env.CMS_DB_CONNECT_TIMEOUT_MS || 5000)
    });
  }

  async verify() {
    const result = await this.pool.query("SELECT 1 AS ok, current_database() AS database");
    return result.rows[0];
  }

  async close() {
    await this.pool.end();
  }

  async findUserForLogin(email) {
    const result = await this.pool.query("SELECT * FROM users WHERE email=$1 AND is_active=true", [email]);
    return result.rows.length ? databaseRow(result.rows[0]) : null;
  }

  async getUserPasswordById(userId) {
    const result = await this.pool.query("SELECT id, password_hash FROM users WHERE id=$1 AND is_active=true", [userId]);
    return result.rows.length ? databaseRow(result.rows[0]) : null;
  }

  async createSession(userId, tokenHash, csrfTokenHash, expiresAt) {
    await this.pool.query(`INSERT INTO user_sessions (user_id, token_hash, csrf_token_hash, expires_at)
      VALUES ($1,$2,$3,$4)`, [userId, tokenHash, csrfTokenHash, expiresAt]);
  }

  async findSession(tokenHash) {
    const result = await this.pool.query(`SELECT s.user_id, s.csrf_token_hash, s.expires_at, s.token_hash,
      u.id, u.email, u.display_name, u.role
      FROM user_sessions s JOIN users u ON u.id=s.user_id
      WHERE s.token_hash=$1 AND s.expires_at > NOW() AND u.is_active=true`, [tokenHash]);
    if (!result.rows.length) return null;
    await this.pool.query("UPDATE user_sessions SET last_used_at=NOW() WHERE token_hash=$1", [tokenHash]);
    const row = result.rows[0];
    return {
      user: { id: row.id, email: row.email, name: row.display_name, role: row.role },
      csrfTokenHash: row.csrf_token_hash,
      expiresAt: new Date(row.expires_at).getTime(),
      tokenHash: row.token_hash
    };
  }

  async deleteSession(tokenHash) {
    await this.pool.query("DELETE FROM user_sessions WHERE token_hash=$1", [tokenHash]);
  }

  async deleteUserSessions(userId) {
    await this.pool.query("DELETE FROM user_sessions WHERE user_id=$1", [userId]);
  }

  async deleteOtherUserSessions(userId, tokenHash) {
    await this.pool.query("DELETE FROM user_sessions WHERE user_id=$1 AND token_hash<>$2", [userId, tokenHash]);
  }

  async cleanupExpiredSessions() {
    const result = await this.pool.query("DELETE FROM user_sessions WHERE expires_at <= NOW()");
    return result.rowCount;
  }

  async updatePassword(userId, passwordHash) {
    await this.pool.query(
      "UPDATE users SET password_hash=$1, password_changed_at=NOW(), updated_at=NOW(), must_change_password=false WHERE id=$2",
      [passwordHash, userId],
    );
    await this.deleteUserSessions(userId);
  }

  async resetUserPassword(userId, passwordHash) {
    const result = await this.pool.query(
      "UPDATE users SET password_hash=$1, password_changed_at=NOW(), updated_at=NOW(), must_change_password=true WHERE id=$2 RETURNING id",
      [passwordHash, userId],
    );
    if (!result.rows.length) return false;
    await this.deleteUserSessions(userId);
    return true;
  }

  async setUserActive(userId, isActive) {
    const result = await this.pool.query(
      "UPDATE users SET is_active=$2, deactivated_at=CASE WHEN $2 THEN NULL ELSE NOW() END, updated_at=NOW() WHERE id=$1 RETURNING id",
      [userId, isActive],
    );
    if (!isActive) await this.deleteUserSessions(userId);
    return result.rows.length > 0;
  }

  async recordAudit(action, entityType, entityId, metadata = {}, userId = null, ipAddress = null) {
    await this.pool.query(
      `INSERT INTO audit_logs (user_id, action, entity_type, entity_id, metadata, ip_address)
       VALUES ($1,$2,$3,$4,$5::jsonb,$6)`,
      [userId, action, entityType, entityId, JSON.stringify(metadata), ipAddress],
    );
  }

  async bootstrapAdministrator(email, passwordHash) {
    const result = await this.pool.query(
      "SELECT id FROM users WHERE role='admin' LIMIT 1",
    );
    if (result.rows.length) return { created: false, reason: "administrator_exists" };

    const client = await this.pool.connect();
    try {
      await client.query("BEGIN");
      await client.query("SELECT pg_advisory_xact_lock(hashtext('cms-administrator-bootstrap'))");
      const administrator = await client.query("SELECT id FROM users WHERE role='admin' LIMIT 1");
      if (administrator.rows.length) {
        await client.query("COMMIT");
        return { created: false, reason: "administrator_exists" };
      }
      const existing = await client.query("SELECT id, role FROM users WHERE lower(email)=lower($1)", [email]);
      if (existing.rows.length) {
        if (existing.rows[0].role !== "admin") {
          throw Object.assign(new Error("The bootstrap email belongs to an existing non-administrator user"), { status: 409 });
        }
        await client.query("COMMIT");
        return { created: false, reason: "administrator_exists" };
      }
      const inserted = await client.query(
        `INSERT INTO users (email, password_hash, display_name, role, must_change_password)
         VALUES ($1,$2,$3,'admin'::user_role,false) RETURNING id`,
        [email, passwordHash, "Administrator"],
      );
      await client.query("COMMIT");
      return { created: true, userId: inserted.rows[0].id };
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  }

  async read() {
    const [pages, modules, publishing, revisions] = await Promise.all([
      this.list("pages", {}),
      Promise.all(["packages", "destinations", "parks", "experiences", "accommodation", "guides", "blogs"].map((name) => this.list(name, {}))),
      this.list("publishing", {}),
      this.list("revisions", {})
    ]);
    return {
      pages: pages.rows,
      packages: modules[0].rows,
      destinations: modules[1].rows,
      parks: modules[2].rows,
      experiences: modules[3].rows,
      accommodation: modules[4].rows,
      guides: modules[5].rows,
      blogs: modules[6].rows,
      publishing: publishing.rows,
      revisions: revisions.rows,
      media: (await this.list("media", {})).rows,
      navigation: (await this.list("navigation", {})).rows,
      translations: (await this.list("translations", {})).rows,
      blocks: (await this.list("blocks", {})).rows,
      users: (await this.list("users", {})).rows
    };
  }

  async dashboardSummary() {
    const [pages, publishing] = await Promise.all([
      this.pool.query(`SELECT l.code AS language, pt.status::text AS status, pt.title,
        pt.description, pt.full_path, pt.updated_at, pt.id
        FROM page_translations pt
        JOIN languages l ON l.id = pt.language_id`),
      this.pool.query(`SELECT id, COALESCE(report->>'label', status) AS label, status, created_at
        FROM publishing_jobs
        ORDER BY created_at DESC
        LIMIT 6`),
    ]);
    return {
      pages: pages.rows.map(databaseRow),
      publishing: publishing.rows.map(databaseRow),
    };
  }

  async publishedWebsitePages() {
    const result = await this.pool.query(`SELECT l.code AS language, p.legacy_source_path AS source_path,
      pt.full_path, pt.title, pt.description, pt.h1, pt.content_html, pt.featured_image,
      pt.canonical_url, pt.og_title, pt.og_description, pt.og_image, pt.robots,
      pt.hreflang, pt.structured_data, pt.status::text AS status
      FROM page_translations pt
      JOIN pages p ON p.id=pt.page_id
      JOIN languages l ON l.id=pt.language_id`);
    return result.rows.map(databaseRow);
  }

  async list(collection, query = {}) {
    if (collection === "pages") return this.listPages(query);
    if (collection === "translations") return this.listRows("page_translations", query, ["title", "slug", "full_path", "h1"]);
    if (collection === "blocks") return this.listRows("content_blocks", query, ["block_type"]);
    if (collection === "media") return this.listRows("media_assets", query, ["file_name", "folder"]);
    if (collection === "revisions") return this.listRows("revisions", query, ["action"]);
    if (collection === "users") {
      const result = await this.listRows("users", query, ["email", "display_name", "role"]);
      return {
        ...result,
        rows: result.rows.map(({ passwordHash, ...user }) => user),
      };
    }
    if (collection === "navigation") return this.listRows("navigation_menus", query, ["code"]);
    const table = tableMap[collection];
    if (!table) throw new Error(`Unsupported CMS collection: ${collection}`);
    return this.listRows(table, query, ["name", "title", "category", "country", "experience_type"]);
  }

  async listPages(query) {
    const offset = (Math.max(1, Number(query.page || 1)) - 1) * Math.min(2000, Math.max(1, Number(query.limit || 25)));
    const limit = Math.min(2000, Math.max(1, Number(query.limit || 25)));
    const where = [];
    const values = [];
    if (query.search) {
      values.push(`%${String(query.search)}%`);
      where.push(`(pt.title ILIKE $${values.length} OR pt.full_path ILIKE $${values.length})`);
    }
    if (query.language) {
      values.push(String(query.language));
      where.push(`l.code = $${values.length}`);
    }
    if (query.status) {
      values.push(String(query.status));
      where.push(`pt.status::text = $${values.length}`);
    }
    if (query.type) {
      values.push(String(query.type));
      where.push(`p.page_type = $${values.length}`);
    }
    const whereSql = where.length ? `WHERE ${where.join(" AND ")}` : "";
    values.push(limit, offset);
    const sql = `SELECT pt.id, p.id AS page_id, p.page_type, p.template, p.legacy_source_path AS source_path,
      l.code AS language, pt.slug, pt.full_path, pt.title, pt.description, pt.h1, pt.status,
      pt.content_html, pt.featured_image, pt.canonical_url, pt.og_title, pt.og_description,
      pt.og_image, pt.robots, pt.hreflang, pt.structured_data,
      pt.updated_at
      FROM page_translations pt
      JOIN pages p ON p.id = pt.page_id
      JOIN languages l ON l.id = pt.language_id
      ${whereSql}
      ORDER BY pt.updated_at DESC LIMIT $${values.length - 1} OFFSET $${values.length}`;
    const count = await this.pool.query(`SELECT COUNT(*)::integer AS total FROM page_translations pt JOIN pages p ON p.id=pt.page_id JOIN languages l ON l.id=pt.language_id ${whereSql}`, values.slice(0, -2));
    const result = await this.pool.query(sql, values);
    return { rows: result.rows.map(databaseRow), total: count.rows[0].total, page: Math.max(1, Number(query.page || 1)), limit };
  }

  async listRows(table, query, searchableColumns) {
    const page = Math.max(1, Number(query.page || 1));
    const limit = Math.min(100, Math.max(1, Number(query.limit || 25)));
    const columns = await this.pool.query(
      "SELECT column_name FROM information_schema.columns WHERE table_schema='public' AND table_name=$1",
      [table],
    );
    const tableColumns = new Set(columns.rows.map((row) => row.column_name));
    const orderColumn = tableColumns.has("updated_at") ? "updated_at" : "created_at";
    const values = [];
    const where = [];
    if (query.search) {
      const terms = searchableColumns.filter((column) => ["name", "title", "category", "country", "experience_type", "file_name", "folder", "email", "display_name", "role", "action", "slug", "full_path", "h1", "block_type"].includes(column));
      if (terms.length) {
        values.push(`%${String(query.search)}%`);
        where.push(`(${terms.map((column) => `${column}::text ILIKE $${values.length}`).join(" OR ")})`);
      }
    }
    if (query.status && table !== "users") {
      values.push(String(query.status));
      where.push(`status::text = $${values.length}`);
    }
    const whereSql = where.length ? `WHERE ${where.join(" AND ")}` : "";
    values.push(limit, (page - 1) * limit);
    const orderSql = tableColumns.has(orderColumn) ? `ORDER BY ${orderColumn} DESC` : "";
    const result = await this.pool.query(`SELECT * FROM ${table} ${whereSql} ${orderSql} LIMIT $${values.length - 1} OFFSET $${values.length}`, values);
    const count = await this.pool.query(`SELECT COUNT(*)::integer AS total FROM ${table} ${whereSql}`, values.slice(0, -2));
    return { rows: result.rows.map(databaseRow), total: count.rows[0].total, page, limit };
  }

  async create(collection, input) {
    if (collection === "pages") return this.createPage(input);
    if (collection === "translations") return this.createTranslation(input);
    if (collection === "blocks") return this.createGeneric("content_blocks", input, ["page_id"]);
    if (collection === "media") return this.createGeneric("media_assets", input, ["storage_key", "file_name", "mime_type", "byte_size"]);
    if (collection === "revisions") return this.createGeneric("revisions", input, ["page_translation_id", "action", "snapshot"]);
    if (collection === "users") return this.createUser(input);
    if (collection === "publishing") return this.createGeneric("publishing_jobs", input, ["status"]);
    const table = tableMap[collection];
    if (!table) throw new Error(`Unsupported CMS collection: ${collection}`);
    return this.createGeneric(table, input, []);
  }

  async createPage(input) {
    const client = await this.pool.connect();
    try {
      await client.query("BEGIN");
      const page = await client.query(`INSERT INTO pages (page_type, template, legacy_source_path, created_at, updated_at)
        VALUES ($1,$2,$3,NOW(),NOW()) RETURNING *`,
        [input.pageType || input.category || "page", input.template || "standard", input.sourcePath || null]);
      const language = await client.query("SELECT id FROM languages WHERE code=$1", [input.language || "en"]);
      if (!language.rows.length) throw new Error(`Unknown language: ${input.language || "en"}`);
      const translation = await client.query(`INSERT INTO page_translations
        (page_id, language_id, slug, full_path, title, description, h1, status, updated_at)
        VALUES ($1,$2,$3,$4,$5,$6,$7,$8::publication_status,NOW())
        RETURNING *`,
        [page.rows[0].id, language.rows[0].id, input.slug || input.fullPath || "", input.fullPath || input.slug || "",
          input.title || null, input.description || null, input.h1 || null, input.status || "draft"]);
      await client.query("COMMIT");
      return databaseRow({
        id: translation.rows[0].id,
        page_id: page.rows[0].id,
        full_path: translation.rows[0].full_path,
        slug: translation.rows[0].slug,
        title: translation.rows[0].title,
        description: translation.rows[0].description,
        h1: translation.rows[0].h1,
        status: translation.rows[0].status,
        language: input.language || "en",
        updated_at: translation.rows[0].updated_at
      });
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  }

  async createTranslation(input) {
    const values = [input.pageId, input.language || "en", input.slug || "", input.fullPath || input.slug || "", input.title || null, input.description || null, input.h1 || null, input.status || "draft"];
    const result = await this.pool.query(`INSERT INTO page_translations (page_id, language_id, slug, full_path, title, description, h1, status)
      SELECT $1, id, $3, $4, $5, $6, $7, $8::publication_status FROM languages WHERE code=$2 RETURNING *`, values);
    if (!result.rows.length) throw new Error(`Unknown language: ${input.language}`);
    return databaseRow(result.rows[0]);
  }

  async createGeneric(table, input, required) {
    for (const key of required) if (input[key] == null && input[toSnake(key)] == null) throw Object.assign(new Error(`${key} is required`), { status: 400 });
    const entries = Object.entries(input).filter(([key]) => !["id", "passwordHash"].includes(key));
    if (!entries.length) throw Object.assign(new Error("At least one field is required"), { status: 400 });
    const columns = await this.pool.query(
      "SELECT column_name FROM information_schema.columns WHERE table_schema='public' AND table_name=$1",
      [table],
    );
    const tableColumns = new Set(columns.rows.map((row) => row.column_name));
    const inputColumns = entries.map(([key]) => toSnake(key));
    const values = entries.map(([, value]) => typeof value === "undefined" ? null : value);
    const generatedColumns = ["created_at", "updated_at"].filter((column) => tableColumns.has(column));
    const insertColumns = [...inputColumns, ...generatedColumns.filter((column) => !inputColumns.includes(column))];
    const insertExpressions = [
      ...values.map((_, index) => `$${index + 1}`),
      ...generatedColumns.map(() => "NOW()"),
    ];
    const result = await this.pool.query(`INSERT INTO ${table} (${insertColumns.join(", ")}) VALUES (${insertExpressions.join(", ")}) RETURNING *`, values);
    return databaseRow(result.rows[0]);
  }

  async createUser(input) {
    if (!input.email || !input.passwordHash) throw Object.assign(new Error("email and passwordHash are required"), { status: 400 });
    const result = await this.pool.query(`INSERT INTO users (email, password_hash, display_name, role)
      VALUES ($1,$2,$3,$4::user_role) RETURNING *`,
      [input.email, input.passwordHash, input.displayName || input.email, input.role || "viewer"]);
    const { passwordHash: _passwordHash, ...user } = databaseRow(result.rows[0]);
    return user;
  }

  async update(collection, rowId, input) {
    const table = collection === "pages" ? "page_translations" : collection === "translations" ? "page_translations"
      : collection === "blocks" ? "content_blocks" : collection === "media" ? "media_assets"
      : collection === "users" ? "users" : collection === "publishing" ? "publishing_jobs" : tableMap[collection];
    if (!table) throw new Error(`Unsupported CMS collection: ${collection}`);
    const entries = Object.entries(input).filter(([key]) => !["id", "passwordHash", "language"].includes(key));
    if (!entries.length) return this.getById(collection, rowId);
    const columns = entries.map(([key]) => toSnake(key));
    const values = entries.map(([, value]) => value);
    const schemaColumns = await this.pool.query(
      "SELECT column_name FROM information_schema.columns WHERE table_schema='public' AND table_name=$1",
      [table],
    );
    const tableColumns = new Set(schemaColumns.rows.map((row) => row.column_name));
    const assignments = columns.map((column, index) => `${column}=$${index + 1}`);
    if (tableColumns.has("updated_at")) {
      values.push(new Date());
      assignments.push(`updated_at=$${values.length}`);
    }
    values.push(rowId);
    const result = await this.pool.query(`UPDATE ${table} SET ${assignments.join(", ")} WHERE id=$${values.length} RETURNING *`, values);
    if (!result.rows.length) return null;
    const row = databaseRow(result.rows[0]);
    if (collection === "users") {
      const { passwordHash: _passwordHash, ...user } = row;
      return user;
    }
    return row;
  }

  async remove(collection, rowId) {
    const table = collection === "pages" || collection === "translations" ? "page_translations"
      : collection === "blocks" ? "content_blocks" : collection === "media" ? "media_assets"
      : collection === "users" ? "users" : collection === "publishing" ? "publishing_jobs" : tableMap[collection];
    if (!table) throw new Error(`Unsupported CMS collection: ${collection}`);
    const result = await this.pool.query(`DELETE FROM ${table} WHERE id=$1 RETURNING id`, [rowId]);
    return result.rows.length > 0;
  }

  async getById(collection, rowId) {
    const table = collection === "pages" || collection === "translations" ? "page_translations"
      : collection === "blocks" ? "content_blocks" : collection === "media" ? "media_assets"
      : collection === "users" ? "users" : collection === "publishing" ? "publishing_jobs" : tableMap[collection];
    const result = await this.pool.query(`SELECT * FROM ${table} WHERE id=$1`, [rowId]);
    return result.rows.length ? databaseRow(result.rows[0]) : null;
  }
}
