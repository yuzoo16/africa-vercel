import { createClient } from "@supabase/supabase-js";
import { timingSafeEqual } from "node:crypto";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { StaticPublisher } from "../publisher/phase3-engine.js";

const supportedLanguages = new Set(["en", "de", "fr", "es", "it"]);

function isAuthorized(request, expectedToken) {
  const authorization = request.headers?.authorization || "";
  const match = /^Bearer\s+(.+)$/i.exec(authorization);
  if (!match) return false;
  const provided = Buffer.from(match[1]);
  const expected = Buffer.from(expectedToken);
  return provided.length === expected.length && timingSafeEqual(provided, expected);
}

function toPublisherPage(row) {
  const page = Object.fromEntries(
    Object.entries(row).map(([key, value]) => [
      key.replace(/_([a-z])/g, (_match, letter) => letter.toUpperCase()),
      value
    ])
  );
  return {
    ...page,
    sourcePath: page.sourcePath || page.legacySourcePath,
    canonicalUrl: page.canonicalUrl || page.canonical,
    contentHtml: page.contentHtml || page.html || ""
  };
}

export function createPublishHandler({
  env = process.env,
  createSupabaseClient = createClient,
  Publisher = StaticPublisher,
  filesystem = { mkdtemp, readFile, rm },
  tempDirectory = os.tmpdir()
} = {}) {
  return async function publish(request, response) {
    if (request.method !== "POST") {
      response.setHeader("Allow", "POST");
      return response.status(405).json({ error: "Method not allowed" });
    }

    if (!env.PUBLISH_API_TOKEN) {
      return response.status(500).json({ error: "Publishing is not configured" });
    }
    if (!isAuthorized(request, env.PUBLISH_API_TOKEN)) {
      return response.status(401).json({ error: "Authentication required" });
    }

    const supabaseUrl = env.SUPABASE_URL;
    const serviceRoleKey = env.SUPABASE_SERVICE_ROLE_KEY;
    if (!supabaseUrl || !serviceRoleKey) {
      return response.status(500).json({ error: "Publishing is not configured" });
    }

    const requestedLanguages = request.body?.languages ?? [...supportedLanguages];
    if (
      !Array.isArray(requestedLanguages) ||
      requestedLanguages.length === 0 ||
      requestedLanguages.some((language) => !supportedLanguages.has(language))
    ) {
      return response.status(400).json({ error: "Invalid languages" });
    }

    let outputRoot;
    try {
      outputRoot = await filesystem.mkdtemp(path.join(tempDirectory, "safari-publish-"));
      const supabase = createSupabaseClient(supabaseUrl, serviceRoleKey, {
        auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false }
      });
      const store = {
        async publishedWebsitePages() {
          const { data, error } = await supabase
            .from("website_pages")
            .select("*")
            .eq("status", "published");
          if (error) throw error;
          return (data || []).map(toPublisherPage);
        }
      };

      const publisher = new Publisher({
        projectRoot: process.cwd(),
        outputRoot,
        store
      });
      const build = await publisher.build({
        languages: [...new Set(requestedLanguages)],
        label: "vercel"
      });
      const zipPath = await publisher.exportZip(build.buildId);
      const fileBuffer = await filesystem.readFile(zipPath);
      const storagePath = `builds/${build.buildId}.zip`;
      const { data, error } = await supabase.storage
        .from("safari-archives")
        .upload(storagePath, fileBuffer, {
          contentType: "application/zip",
          upsert: true
        });
      if (error) throw error;

      return response.status(200).json({
        buildId: build.buildId,
        pageCount: build.pageCount,
        issues: build.issues,
        storagePath: data?.path || storagePath
      });
    } catch (error) {
      console.error("Vercel publish failed:", error);
      return response.status(500).json({ error: "Website publishing failed" });
    } finally {
      if (outputRoot) await filesystem.rm(outputRoot, { recursive: true, force: true });
    }
  };
}

export default createPublishHandler();
