# Phase 1 Checklist

## Website inventory
- [x] Confirm project folders and page counts.
- [x] Create a read-only HTML inventory generator.
- [x] Run and review the complete inventory.
- [ ] Classify templates and reusable structures.
- [ ] Map translated page equivalences.
- [ ] Identify incomplete translations and missing routes.
- [ ] Inventory metadata, JSON-LD, images, redirects and internal links.

## Database and backend
- [x] Add PostgreSQL schema for pages, translations, blocks, SEO, media, menus, revisions and publishing.
- [x] Add the five-language seed registry.
- [x] Add an initial protected Node.js API shell and health endpoint.
- [ ] Add session authentication, authorization and CSRF protection.
- [ ] Add CRUD API validation and migrations tooling.
- [ ] Add revision and publishing audit APIs.

## Safety constraints
- Existing `Africa Safari` files are not used as build output.
- Existing production files are not modified.
- Live deployment is not performed.
- Destructive database operations require explicit approval.

## Phase 1 initial report
- Inventoried 1,458 HTML pages: EN 318, DE 285, FR 285, ES 285, IT 285.
- 1,457 pages have canonical metadata; the 404 page is the single expected exception.
- 1,425 pages contain extracted hreflang entries.
- The API dependencies install successfully and the server module passes syntax validation.
- PostgreSQL service and migrations were not run because no database service was configured in the project.
