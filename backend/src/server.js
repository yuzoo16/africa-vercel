import "dotenv/config";
import express from "express";
import pg from "pg";
import multer from "multer";
import crypto from "node:crypto";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { localStore } from "./localStore.js";
import { PostgresStore } from "./postgresStore.js";
import { StaticPublisher } from "../../publisher/phase3-engine.js";
import { Phase4ReleaseManager } from "../../deployment/phase4-manager.js";
import bcrypt from "bcryptjs";
import cookieParser from "cookie-parser";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import { fileURLToPath } from "node:url";

const app = express();
const port = Number(process.env.CMS_PORT || 3001);

app.disable("x-powered-by");
const allowedOrigins = String(process.env.CMS_ALLOWED_ORIGINS || "")
  .split(",")
  .map((origin) => origin.trim())
  .filter(Boolean);
app.use((request, response, next) => {
  const origin = String(request.headers.origin || "");
  if (origin && allowedOrigins.includes(origin)) {
    response.setHeader("Access-Control-Allow-Origin", origin);
    response.setHeader("Access-Control-Allow-Credentials", "true");
    response.setHeader("Vary", "Origin");
  }
  if (request.method === "OPTIONS") {
    response.setHeader("Access-Control-Allow-Headers", "Content-Type, X-CSRF-Token");
    response.setHeader("Access-Control-Allow-Methods", "GET, POST, PATCH, DELETE, OPTIONS");
    return response.sendStatus(204);
  }
  next();
});
app.use(express.json({ limit: "1mb" }));
app.use(cookieParser());
app.use(helmet({ crossOriginResourcePolicy: { policy: "cross-origin" } }));
const serverDirectory = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(serverDirectory, "..", "..");
const websiteRoot = path.resolve(projectRoot, "Africa Safari");
const liveWebsiteRoot = path.resolve(projectRoot, "preview", "live");
app.use(express.static(liveWebsiteRoot, { extensions: ["html"], fallthrough: true }));
app.use("/Africa-Safari", express.static(liveWebsiteRoot, { extensions: ["html"], fallthrough: true }));
app.use(express.static(websiteRoot, { extensions: ["html"] }));
app.use("/Africa-Safari", express.static(websiteRoot, { extensions: ["html"] }));
app.use("/cms-media", express.static(path.resolve(projectRoot, "database", "runtime", "media")));
app.use((_, response, next) => {
  response.setHeader("X-Content-Type-Options", "nosniff");
  response.setHeader("X-Frame-Options", "DENY");
  next();
});

const usePostgres = Boolean(process.env.DATABASE_URL);
if (process.env.NODE_ENV === "production" && !usePostgres) throw new Error("DATABASE_URL is required in production");
const store = usePostgres ? new PostgresStore(process.env.DATABASE_URL) : await localStore();
if (usePostgres) {
  try {
    await store.verify();
    await store.cleanupExpiredSessions();
  } catch (error) {
    throw new Error(`PostgreSQL connection failed: ${error.message}`);
  }
}
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 10 * 1024 * 1024 } });
const sessions = new Map();
const publisher = new StaticPublisher({ projectRoot, store });
const releaseManager = new Phase4ReleaseManager({ projectRoot });
const sessionCookieOptions = {
  httpOnly: true,
  secure: process.env.NODE_ENV === "production",
  sameSite: "strict",
  path: "/",
  maxAge: 8 * 60 * 60 * 1000
};
if (usePostgres) {
  const cleanupInterval = setInterval(() => {
    store.cleanupExpiredSessions().catch((error) => console.error("Expired session cleanup failed:", error.message));
  }, 60 * 60 * 1000);
  cleanupInterval.unref();
}
const csrfCookieOptions = {
  httpOnly: false,
  secure: process.env.NODE_ENV === "production",
  sameSite: "strict",
  path: "/",
  maxAge: 8 * 60 * 60 * 1000
};

app.post("/api/publisher/build", protect, requireRoles("admin", "publisher"), verifyCsrf, async (request, response, next) => {
  try {
    const languages = Array.isArray(request.body?.languages)
      ? request.body.languages.filter((language) => ["en", "de", "fr", "es", "it"].includes(language))
      : ["en", "de", "fr", "es", "it"];
    if (!languages.length) return response.status(400).json({ error: "At least one supported language is required" });
    const result = await publisher.build({ languages, label: String(request.body?.label || "cms-build") });
    await publisher.publishLive(result.buildId);
    response.status(201).json({
      buildId: result.buildId,
      pageCount: result.pageCount,
      issueCount: result.issues.length,
      buildRoot: result.buildRoot,
      issueTypes: result.issues.reduce((counts, issue) => {
        counts[issue.type] = (counts[issue.type] || 0) + 1;
        return counts;
      }, {})
    });
  } catch (error) {
    next(error);
  }
});

app.post("/api/publisher/export", protect, requireRoles("admin", "publisher"), verifyCsrf, async (request, response, next) => {
  try {
    const buildId = String(request.body?.buildId || "");
    if (!buildId) return response.status(400).json({ error: "buildId is required" });
    const zipPath = await publisher.exportZip(buildId);
    response.download(zipPath, `${buildId}.zip`);
  } catch (error) {
    next(error);
  }
});

app.get("/api/publisher/builds", protect, requireRoles("admin", "publisher"), async (_request, response, next) => {
  try {
    response.json({ builds: await publisher.listBuilds() });
  } catch (error) {
    next(error);
  }
});

app.post("/api/deployment/releases", protect, requireRoles("admin", "publisher"), verifyCsrf, async (request, response, next) => {
  try {
    const buildId = String(request.body?.buildId || "");
    if (!buildId) return response.status(400).json({ error: "buildId is required" });
    const result = await releaseManager.prepare(buildId);
    response.status(201).json(result);
  } catch (error) {
    next(error);
  }
});

app.get("/api/deployment/releases/:releaseId/verify", protect, requireRoles("admin", "publisher"), async (request, response, next) => {
  try {
    response.json(await releaseManager.verifyRelease(String(request.params.releaseId)));
  } catch (error) {
    next(error);
  }
});

app.post("/api/deployment/authorize", protect, requireRoles("admin"), verifyCsrf, async (request, response, next) => {
  try {
    await releaseManager.authorizeDeploy({
      releaseId: String(request.body?.releaseId || ""),
      authorizationToken: String(request.body?.authorizationToken || "")
    });
  } catch (error) {
    next(error);
  }
});

app.get("/api/health", (_request, response) => {
  response.json({ ok: true, service: "adventure-safari-cms" });
});

const loginLimiter = rateLimit({ windowMs: 15 * 60 * 1000, limit: 10, standardHeaders: "draft-7", legacyHeaders: false });
app.get("/api/auth/csrf", async (request, response, next) => {
  const rawToken = request.cookies.cms_session || String(request.headers.authorization || "").replace(/^Bearer\s+/i, "");
  let token = null;
  if (usePostgres && rawToken) {
    const session = await store.findSession(crypto.createHash("sha256").update(rawToken).digest("hex"));
    if (session) token = request.cookies.cms_csrf || null;
  } else token = sessions.get(rawToken)?.csrfToken || null;
  if (!token) return response.status(401).json({ error: "Authentication required" });
  response.json({ csrfToken: token });
});

app.post("/api/auth/login", loginLimiter, async (request, response) => {
  if (!request.body || typeof request.body.password !== "string") return response.status(400).json({ error: "Password is required" });
  if (Buffer.byteLength(request.body.password, "utf8") > 72) return response.status(400).json({ error: "Password is too long" });
  const token = crypto.randomBytes(32).toString("base64url");
  const csrfToken = crypto.randomBytes(32).toString("base64url");
  let user;
  if (usePostgres) {
    const email = String(request.body.email || "").trim().toLowerCase();
    if (!email) return response.status(400).json({ error: "Email is required" });
    const databaseUser = await store.findUserForLogin(email);
    if (!databaseUser || !databaseUser.passwordHash || !await bcrypt.compare(request.body.password, databaseUser.passwordHash)) {
      await store.recordAudit("login_failed", "auth_session", null, { reason: "invalid_credentials" }, null, request.ip);
      return response.status(401).json({ error: "Invalid credentials" });
    }
    user = { id: databaseUser.id, name: databaseUser.displayName || databaseUser.email, role: databaseUser.role };
    const expiresAt = new Date(Date.now() + 8 * 60 * 60 * 1000);
    await store.deleteUserSessions(databaseUser.id);
    await store.createSession(user.id, crypto.createHash("sha256").update(token).digest("hex"), crypto.createHash("sha256").update(csrfToken).digest("hex"), expiresAt);
    await store.recordAudit("login_success", "auth_session", user.id, {}, user.id, request.ip);
  } else {
    const passwordHash = process.env.CMS_BOOTSTRAP_PASSWORD_HASH;
    if (!passwordHash) return response.status(503).json({ error: "CMS_BOOTSTRAP_PASSWORD_HASH is not configured" });
    if (!await bcrypt.compare(request.body.password, passwordHash)) return response.status(401).json({ error: "Invalid credentials" });
    user = { id: "administrator", name: "Administrator", role: "admin" };
    sessions.set(token, { user, csrfToken, expiresAt: Date.now() + 8 * 60 * 60 * 1000 });
  }
  response.cookie("cms_session", token, sessionCookieOptions);
  response.cookie("cms_csrf", csrfToken, csrfCookieOptions);
  response.json({ user, csrfToken });
});

app.post("/api/auth/logout", protect, verifyCsrf, async (request, response, next) => {
  response.clearCookie("cms_session", { ...sessionCookieOptions, maxAge: undefined });
  response.clearCookie("cms_csrf", { ...csrfCookieOptions, maxAge: undefined });
  const token = request.cookies.cms_session || String(request.headers.authorization || "").replace(/^Bearer\s+/i, "");
  if (usePostgres) await store.deleteSession(crypto.createHash("sha256").update(token).digest("hex"));
  else sessions.delete(token);
  if (usePostgres) {
    await store.recordAudit("logout", "auth_session", request.cmsUser?.id || null, {}, request.cmsUser?.id || null, request.ip);
  }
  response.status(204).end();
});

app.get("/api/auth/me", protect, (request, response) => {
  response.json({ user: request.cmsUser });
});

app.post("/api/auth/password", protect, verifyCsrf, async (request, response, next) => {
  try {
    if (!usePostgres) return response.status(503).json({ error: "Database-backed password changes are required" });
    const currentPassword = String(request.body?.currentPassword || "");
    const newPassword = String(request.body?.newPassword || "");
    if (!currentPassword || !newPassword) return response.status(400).json({ error: "Current and new passwords are required" });
    if (newPassword.length < 12 || Buffer.byteLength(newPassword, "utf8") > 72) {
      return response.status(400).json({ error: "New password must contain at least 12 characters and at most 72 UTF-8 bytes" });
    }
    const currentUser = await store.getUserPasswordById(request.cmsUser.id);
    if (!currentUser || !await bcrypt.compare(currentPassword, currentUser.passwordHash)) {
      return response.status(401).json({ error: "Current password is incorrect" });
    }
    const passwordHash = await bcrypt.hash(newPassword, 12);
    await store.updatePassword(request.cmsUser.id, passwordHash);
    await store.recordAudit("password_change", "user", request.cmsUser.id, {}, request.cmsUser.id, request.ip);
    response.clearCookie("cms_session", { ...sessionCookieOptions, maxAge: undefined });
    response.clearCookie("cms_csrf", { ...csrfCookieOptions, maxAge: undefined });
    response.status(204).end();
  } catch (error) {
    next(error);
  }
});

async function verifyCsrf(request, response, next) {
  if (!["POST", "PUT", "PATCH", "DELETE"].includes(request.method)) return next();
  const token = request.cookies.cms_session || String(request.headers.authorization || "").replace(/^Bearer\s+/i, "");
  const session = usePostgres ? await store.findSession(crypto.createHash("sha256").update(token).digest("hex")) : sessions.get(token);
  if (!session) return response.status(401).json({ error: "Authentication required" });
  const supplied = String(request.headers["x-csrf-token"] || "");
  const valid = usePostgres
    ? session.csrfTokenHash === crypto.createHash("sha256").update(supplied).digest("hex")
    : supplied === session.csrfToken;
  if (!valid) return response.status(403).json({ error: "Invalid CSRF token" });
  next();
}

async function protect(request, response, next) {
  const token = request.cookies.cms_session || String(request.headers.authorization || "").replace(/^Bearer\s+/i, "");
  const session = usePostgres ? await store.findSession(crypto.createHash("sha256").update(token).digest("hex")) : sessions.get(token);
  if (!session || session.expiresAt < Date.now()) return response.status(401).json({ error: "Authentication required" });
  request.cmsUser = session.user;
  next();
}

function requireRoles(...roles) {
  return (request, response, next) => {
    if (!roles.includes(request.cmsUser?.role)) return response.status(403).json({ error: "Insufficient permissions" });
    next();
  };
}

function requireCollectionAccess(readRoles, writeRoles) {
  return (request, response, next) => {
    const role = request.cmsUser?.role;
    const roles = ["GET", "HEAD"].includes(request.method) ? readRoles : writeRoles;
    if (!roles.includes(role)) return response.status(403).json({ error: "Insufficient permissions" });
    next();
  };
}

app.use("/api", verifyCsrf);

const contentRoles = ["admin", "editor", "translator", "reviewer", "publisher", "seo", "viewer"];
app.use("/api/pages", protect, requireCollectionAccess(contentRoles, ["admin", "editor"]));
app.use("/api/packages", protect, requireCollectionAccess(contentRoles, ["admin", "editor"]));
app.use("/api/destinations", protect, requireCollectionAccess(contentRoles, ["admin", "editor"]));
app.use("/api/parks", protect, requireCollectionAccess(contentRoles, ["admin", "editor"]));
app.use("/api/experiences", protect, requireCollectionAccess(contentRoles, ["admin", "editor"]));
app.use("/api/accommodation", protect, requireCollectionAccess(contentRoles, ["admin", "editor"]));
app.use("/api/guides", protect, requireCollectionAccess(contentRoles, ["admin", "editor"]));
app.use("/api/blogs", protect, requireCollectionAccess(contentRoles, ["admin", "editor"]));
app.use("/api/media", protect, requireCollectionAccess(["admin", "editor", "seo", "reviewer", "publisher", "viewer"], ["admin", "editor", "seo"]));
app.use("/api/navigation", protect, requireCollectionAccess(["admin", "editor", "seo", "reviewer", "publisher", "viewer"], ["admin", "editor", "seo"]));
app.use("/api/revisions", protect, requireCollectionAccess(["admin", "editor", "reviewer", "publisher", "viewer"], ["admin", "editor", "reviewer"]));
app.use("/api/publishing", protect, requireCollectionAccess(["admin", "publisher", "viewer"], ["admin", "publisher"]));
app.use("/api/translations", protect, requireCollectionAccess(["admin", "editor", "translator", "reviewer", "viewer"], ["admin", "editor", "translator"]));
app.use("/api/blocks", protect, requireCollectionAccess(contentRoles, ["admin", "editor"]));
app.use("/api/users", protect, requireRoles("admin"));

app.get("/api/languages", async (_request, response, next) => {
  if (!process.env.DATABASE_URL) {
    response.status(503).json({ error: "DATABASE_URL is not configured" });
    return;
  }

  try {
    const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });
    const result = await pool.query(
      "SELECT code, name, locale, is_default, is_enabled, sort_order FROM languages WHERE is_enabled = true ORDER BY sort_order"
    );
    await pool.end();
    response.json({ languages: result.rows });
  } catch (error) {
    next(error);
  }
});

const collections = ["pages", "packages", "destinations", "parks", "experiences", "accommodation", "guides", "blogs", "media", "navigation", "revisions", "publishing", "translations", "blocks", "users"];

const cmsRoles = ["admin", "editor", "translator", "seo", "publisher", "reviewer", "viewer"];

app.post("/api/users", protect, requireRoles("admin"), verifyCsrf, async (request, response, next) => {
  try {
    const email = String(request.body?.email || "").trim().toLowerCase();
    const password = String(request.body?.password || "");
    const role = String(request.body?.role || "viewer");
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return response.status(400).json({ error: "A valid email is required" });
    if (!cmsRoles.includes(role)) return response.status(400).json({ error: "Invalid CMS role" });
    if (password.length < 12 || Buffer.byteLength(password, "utf8") > 72) {
      return response.status(400).json({ error: "Password must contain at least 12 characters and at most 72 UTF-8 bytes" });
    }
    const passwordHash = await bcrypt.hash(password, 12);
    response.status(201).json(await store.createUser({
      email,
      passwordHash,
      displayName: String(request.body?.displayName || email),
      role
    }));
  } catch (error) {
    next(error);
  }
});

app.post("/api/users/:id/password", protect, requireRoles("admin"), verifyCsrf, async (request, response, next) => {
  try {
    const password = String(request.body?.password || "");
    if (password.length < 12 || Buffer.byteLength(password, "utf8") > 72) {
      return response.status(400).json({ error: "Password must contain at least 12 characters and at most 72 UTF-8 bytes" });
    }
    const passwordHash = await bcrypt.hash(password, 12);
    const updated = await store.resetUserPassword(request.params.id, passwordHash);
    if (!updated) return response.status(404).json({ error: "Record not found" });
    await store.recordAudit("password_reset", "user", request.params.id, {}, request.cmsUser.id, request.ip);
    response.status(204).end();
  } catch (error) {
    next(error);
  }
});

app.get("/api/dashboard/summary", protect, async (_request, response, next) => {
  try {
    const data = await store.dashboardSummary();
    const languageNames = { en: "English", de: "German", fr: "French", es: "Spanish", it: "Italian" };
    const languages = Object.entries(languageNames).map(([code, name]) => {
      const rows = data.pages.filter((page) => page.language === code);
      return {
        code,
        name,
        published: rows.filter((page) => page.status === "published").length,
        drafts: rows.filter((page) => page.status === "draft").length,
        missing: Math.max(0, 285 - rows.length)
      };
    });

    const statusCount = (status) => data.pages.filter((page) => page.status === status).length;
    response.json({
      pages: { total: data.pages.length, published: statusCount("published"), draft: statusCount("draft"), inReview: statusCount("in_review") },
      languages,
      missingTranslations: languages.reduce((total, language) => total + language.missing, 0),
      outdatedTranslations: 0,
      seoIssues: data.pages.filter((page) => !page.title || !page.description || !page.fullPath).length,
      recentEdits: [...data.pages].sort((a, b) => String(b.updatedAt).localeCompare(String(a.updatedAt))).slice(0, 6),
      recentPublishing: [...data.publishing].slice(0, 6)
    });
  } catch (error) {
    next(error);
  }
});

for (const collection of collections) {
  app.get(`/api/${collection}`, async (request, response, next) => {
    try {
      response.json(await store.list(collection, request.query));
    } catch (error) {
      next(error);
    }
  });

  app.post(`/api/${collection}`, async (request, response, next) => {
    try {
      response.status(201).json(await store.create(collection, validateBody(request.body)));
    } catch (error) {
      next(error);
    }
  });

  app.patch(`/api/${collection}/:id`, async (request, response, next) => {
    try {
      if (collection === "users" && request.params.id === request.cmsUser?.id && request.body && Object.hasOwn(request.body, "role")) {
        return response.status(403).json({ error: "Users cannot change their own role" });
      }
      if (collection === "users" && request.body?.role && !cmsRoles.includes(request.body.role)) {
        return response.status(400).json({ error: "Invalid CMS role" });
      }
      const row = await store.update(collection, request.params.id, validateBody(request.body));
      if (!row) return response.status(404).json({ error: "Record not found" });
      response.json(row);
    } catch (error) {
      next(error);
    }
  });

  app.delete(`/api/${collection}/:id`, async (request, response, next) => {
    try {
      if (collection === "users" && request.params.id === request.cmsUser?.id) {
        return response.status(403).json({ error: "Users cannot delete their own account" });
      }
      if (!await store.remove(collection, request.params.id)) return response.status(404).json({ error: "Record not found" });
      response.status(204).end();
    } catch (error) {
      next(error);
    }
  });
}

function validateBody(body) {
  if (!body || typeof body !== "object" || Array.isArray(body)) throw Object.assign(new Error("A JSON object is required"), { status: 400 });
  return Object.fromEntries(Object.entries(body).filter(([key]) => key !== "id" && key !== "passwordHash"));
}

app.post("/api/media/upload", protect, requireRoles("admin", "editor", "seo"), verifyCsrf, upload.single("file"), async (request, response, next) => {
  try {
    if (!request.file) return response.status(400).json({ error: "A file is required" });
    const media = await store.create("media", {
      fileName: request.file.originalname,
      mimeType: request.file.mimetype,
      byteSize: request.file.size,
      storageKey: crypto.randomUUID(),
      folder: String(request.body.folder || "uploads"),
      altText: String(request.body.altText || ""),
      status: "uploaded"
    });
    const mediaDirectory = path.resolve(process.cwd(), "..", "database", "runtime", "media");
    await mkdir(mediaDirectory, { recursive: true });
    await writeFile(path.join(mediaDirectory, media.storageKey), request.file.buffer);
    response.status(201).json(media);
  } catch (error) {
    next(error);
  }
});

app.use((error, _request, response, _next) => {
  console.error(error);
  const status = error.statusCode && error.statusCode >= 400 && error.statusCode < 500
    ? error.statusCode
    : 500;
  response.status(status).json({ error: status === 500 ? "Internal server error" : error.message || "Request failed" });
});

app.listen(port, () => {
  console.log(`CMS API listening on http://localhost:${port}`);
});
