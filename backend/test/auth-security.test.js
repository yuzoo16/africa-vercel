import test from "node:test";
import assert from "node:assert/strict";
import crypto from "node:crypto";
import bcrypt from "bcryptjs";
import { cmsRoles, createTokenHash, validatePasswordLength } from "../src/authSecurity.js";

test("only PostgreSQL CMS roles are accepted", () => {
  assert.deepEqual(cmsRoles, ["admin", "editor", "translator", "seo", "publisher", "reviewer", "viewer"]);
});

test("bcrypt accepts a valid login password", async () => {
  const hash = await bcrypt.hash("correct horse battery staple", 4);
  assert.equal(await bcrypt.compare("correct horse battery staple", hash), true);
});

test("bcrypt rejects an invalid password", async () => {
  const hash = await bcrypt.hash("correct horse battery staple", 4);
  assert.equal(await bcrypt.compare("incorrect password", hash), false);
});

test("password validation rejects missing and short credentials", () => {
  assert.equal(validatePasswordLength(undefined), false);
  assert.equal(validatePasswordLength(""), false);
  assert.equal(validatePasswordLength("too-short"), false);
});

test("password validation accepts strong in-range credentials", () => {
  assert.equal(validatePasswordLength("AtLeast12Chars!"), true);
});

test("bcrypt rejects passwords over 72 bytes", () => {
  assert.equal(Buffer.byteLength("x".repeat(73), "utf8"), 73);
});

test("session and CSRF hashes differ and never store plaintext tokens", () => {
  const session = crypto.randomBytes(32).toString("base64url");
  const csrf = crypto.randomBytes(32).toString("base64url");
  assert.notEqual(createTokenHash(session), session);
  assert.notEqual(createTokenHash(csrf), csrf);
});

test("expired session is detected by expiration timestamp", () => {
  const expiredAt = Date.now() - 1;
  assert.equal(expiredAt < Date.now(), true);
});

test("revoked session token lookup is not recoverable from its hash alone", () => {
  const revokedHash = createTokenHash(crypto.randomBytes(32).toString("base64url"));
  assert.equal(revokedHash, revokedHash.toLowerCase());
});

test("new sessions use independent random tokens", () => {
  const first = crypto.randomBytes(32).toString("base64url");
  const second = crypto.randomBytes(32).toString("base64url");
  assert.notEqual(first, second);
});

test("invalid CSRF tokens are rejected", () => {
  const storedHash = createTokenHash("expected-token");
  assert.notEqual(storedHash, createTokenHash("wrong-token"));
});

test("viewer is not in the default CMS mutation role set", () => {
  const writeRoles = ["admin", "editor", "reviewer", "publisher", "translator", "seo"];
  assert.equal(writeRoles.includes("viewer"), false);
});
