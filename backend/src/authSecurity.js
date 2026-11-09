import crypto from "node:crypto";

export const cmsRoles = ["admin", "editor", "translator", "seo", "publisher", "reviewer", "viewer"];

export function validatePasswordLength(password) {
  return typeof password === "string"
    && password.length >= 12
    && Buffer.byteLength(password, "utf8") <= 72;
}

export function createTokenHash(token) {
  return crypto.createHash("sha256").update(token).digest("hex");
}
