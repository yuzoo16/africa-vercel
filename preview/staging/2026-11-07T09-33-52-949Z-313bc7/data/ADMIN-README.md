# Admin & Content Workflow (non-developer guide)

## 1. Enquiries: real API submission (no mailto)
`assets/site.js` - SITE_CONFIG.formEndpoint accepts an email address (uses FormSubmit ajax: `https://formsubmit.co/ajax/YOUREMAIL`) or any `https://` endpoint (Formspree, Netlify Forms function, custom API). Validation + honeypot + localStorage backup + conversion tracking built in.
FIRST-RUN ACTIVATION: FormSubmit sends an activation email to the inbox on the first submission - open it and click activate once, otherwise leads queue silently.
## 2. Change WhatsApp / Calendly / analytics - one place
Edit `assets/site.js` → `window.SITE_CONFIG`:
- `whatsappNumber`: e.g. `"255712345678"` (country code + number, no `+`). All `data-wa` buttons site-wide update automatically. Package pages auto-include package name in the message.
- `calendlyUrl`: paste embed URL → `/safari-consultation/` shows live booking calendar.
- `contactEmail` + `formEndpoint`: point the proposal form at Formspree/Netlify/your API. Without an endpoint, submissions show confirmation + store locally (demo).
- `gaId`, `gtmId`, `metaPixelId`: analytics load only when set (see `assets/analytics.js`).

## Reviews, team, charity (all editable data))
- `data/reviews.json`: genuine reviews ONLY (name, country, trip, date, source, rating, text) + aggregate (leave `reviewCountText` EMPTY until you have a verified total - never invent numbers) + platform profile URLs.
- `data/team.json`: director profile (Leandry Diamay), per-country experts (placeholders clearly marked - replace, never present as verified staff), Shujaa wa Upendo content, MAF Foundation percent (currently 10 of profit - configurable factual field).
- `data/languages.json`: language registry (en/it/fr/de/es) - add Portuguese, Dutch etc. by appending entries; switcher shows flags.
## Add/edit content
- **New package**: copy any `*-day-*.html` in the country folder, edit copy, add card to `<country>/packages.html`, add row to `data/content.json` → `packages`, add URL to `sitemap.xml`.
- **New destination**: copy `tanzania-safari/index.html` structure; new folder = new silo (`/new-safari/` + `/new-safari/packages/`). Add to the Destinations nav in `assets/partials.js` + footer + `sitemap.xml`.
- **New park/activity/guide/post**: copy nearest sibling page; link parent ↔ siblings ↔ related packages (silo rule: every page has parent, sibling, child/related links + breadcrumb).
- **SEO per page**: edit `<title>`, meta description, canonical, OG tags, hreflang in `<head>`; JSON-LD blocks for FAQ/TouristTrip/Article where genuine. Never duplicate titles/descriptions.
- **Images**: Unsplash hotlinks are placeholders — replace with compressed WebP/AVIF in `/assets/`, keep descriptive alt text (no keyword stuffing), add width/height to prevent CLS.
- **Translations**: see `data/i18n-README.md`.

## Publish checklist (pre-launch audit)
SEO · mobile/desktop nav · breadcrumbs · canonicals · hreflang · schema validity (Rich Results Test) · metadata uniqueness · forms (success/error/spam) · WhatsApp links · Calendly embed · search · filters (no indexable URLs) · page speed (LCP/INP/CLS) · accessibility (labels, focus, contrast, alt) · broken links · 404 · redirects · sitemap/robots · no fake reviews/prices in schema.

## Multilingual system (EN master + IT/FR/DE/ES parity)
- English is the master. Every EN page in data/i18n-urlmap.json has 1:1 localized equivalents with localized slugs, metadata, hreflang (6-way), self canonicals, localized internal links/breadcrumbs/schema/CTAs, same images, same section structure, 9 FAQs where EN has them.
- Dictionaries: data/i18n/{it,fr,de,es}-{base,tpl,content,hubs,globals,acts,guides,accomm,mig,kili,blog,misc}.json (all UTF-8). NEVER put non-ASCII text inside .ps1 files (Windows PowerShell reads scripts as ANSI and will corrupt output).
- Generators: tools/gen-i18n-*.ps1 (packages, hubs, cats, parks/activities, guides/accomm/migration, kili, months, calc, blog, misc pages, remainder). URL map: tools/i18n-urlmap.ps1 -> data/i18n-urlmap.json.
- Nav: assets/partials-{it,fr,de,es}.js (translated nav/footers) + assets/i18n-map.js (equivalent-page switcher). Localized pages load both; EN pages use partials.js (map-driven switcher).
- Adding Spanish/Portuguese/Dutch: add language to LANGS + dictionaries + slug maps, extend generators, rerun. Add rows to data/languages.json.
- Translation status: data/i18n-status.json (per entity per language: Published/Missing + word counts). Regenerate: tools/i18n-audit.ps1. Gaps: tools/i18n-pad.ps1 (FAQ padding), tools/linkboost.ps1 (related cards).
- PowerShell gotcha (documented from real bugs): variable names are case-INsensitive, so $hub destroys $HUB, $fq destroys $FQ, $d destroys $D in the same scope. Always use distinct names. Also @(@(...)) with a SINGLE nested array unwraps it - guard by checking whether the first element is a string.
