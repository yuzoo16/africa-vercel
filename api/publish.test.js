import test from "node:test";
import assert from "node:assert/strict";
import { createPublishHandler } from "./publish.js";

function responseMock() {
  return {
    headers: {},
    setHeader(name, value) {
      this.headers[name] = value;
    },
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(body) {
      this.body = body;
      return this;
    }
  };
}

test("publishing endpoint rejects non-POST requests", async () => {
  const response = responseMock();
  await createPublishHandler()({ method: "GET" }, response);
  assert.equal(response.statusCode, 405);
  assert.equal(response.headers.Allow, "POST");
});

test("publishing endpoint requires its server-side token", async () => {
  const response = responseMock();
  const handler = createPublishHandler({ env: { PUBLISH_API_TOKEN: "secret" } });
  await handler({ method: "POST", headers: {} }, response);
  assert.equal(response.statusCode, 401);
});

test("publishing endpoint builds and uploads the ZIP to Supabase", async () => {
  const calls = [];
  const response = responseMock();
  const handler = createPublishHandler({
    env: {
      PUBLISH_API_TOKEN: "publish-secret",
      SUPABASE_URL: "https://example.supabase.co",
      SUPABASE_SERVICE_ROLE_KEY: "service-role"
    },
    createSupabaseClient(url, key) {
      assert.equal(url, "https://example.supabase.co");
      assert.equal(key, "service-role");
      return {
        from(table) {
          assert.equal(table, "website_pages");
          return {
            select(columns) {
              assert.equal(columns, "*");
              return {
                async eq(column, value) {
                  assert.equal(column, "status");
                  assert.equal(value, "published");
                  return {
                    data: [{ source_path: "Tanzania/index.html", content_html: "<h1>Published</h1>" }],
                    error: null
                  };
                }
              };
            }
          };
        },
        storage: {
          from(bucket) {
            assert.equal(bucket, "safari-archives");
            return {
              async upload(filePath, buffer, options) {
                calls.push({ filePath, buffer, options });
                return { data: { path: filePath }, error: null };
              }
            };
          }
        }
      };
    },
    Publisher: class {
      constructor(options) {
        this.options = options;
      }

      async build(options) {
        assert.deepEqual(options.languages, ["en", "de", "fr", "es", "it"]);
        const pages = await this.options.store.publishedWebsitePages();
        assert.equal(pages[0].sourcePath, "Tanzania/index.html");
        assert.equal(pages[0].contentHtml, "<h1>Published</h1>");
        return { buildId: "test-build", pageCount: 2, issues: [] };
      }

      async exportZip(buildId) {
        assert.equal(buildId, "test-build");
        return "test.zip";
      }
    },
    filesystem: {
      async mkdtemp() {
        return "temporary-output";
      },
      async readFile(filePath) {
        assert.equal(filePath, "test.zip");
        return Buffer.from("zip-data");
      },
      async rm(directory, options) {
        assert.equal(directory, "temporary-output");
        assert.equal(options.recursive, true);
      }
    },
    tempDirectory: "temporary"
  });

  await handler({
    method: "POST",
    headers: { authorization: "Bearer publish-secret" },
    body: {}
  }, response);

  assert.equal(response.statusCode, 200);
  assert.deepEqual(response.body, {
    buildId: "test-build",
    pageCount: 2,
    issues: [],
    storagePath: "builds/test-build.zip"
  });
  assert.equal(calls.length, 1);
  assert.equal(calls[0].filePath, "builds/test-build.zip");
  assert.equal(calls[0].options.contentType, "application/zip");
});
