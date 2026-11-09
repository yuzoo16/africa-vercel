# Multilingual SEO structure (EN default at root + /it/ /fr/ /de/)

## URL architecture (chosen: English at root — cleanest for an EN-first brand)
- English (default, `hreflang="en"` + `x-default`): `/tanzania-safari/`
- Italian: `/it/tanzania-safari/` · French: `/fr/tanzania-safari/` · German: `/de/tanzania-safari/`
- Localized slugs per language (NOT query params, NOT same-URL translation).

## Live proof pages
- `/it/`, `/fr/`, `/de/` homepages (translated hero + metadata, `lang` attributes)
- `/it/tanzania-safari/`, `/fr/tanzania-safari/`, `/de/tanzania-safari/` hubs with bidirectional hreflang ↔ EN

## Rules for every new translation
1. New file under `/{lang}/{localized-slug}/index.html` with `html lang="{lang}"`.
2. Fully translated `<title>`, meta description, H1–H3, alt text, OG tags.
3. Canonical = self (localized URL). Hreflang cluster on EVERY variant: en + it + fr + de + x-default.
4. Add reverse hreflang on the EN page (EN pages already carry it/fr/de alternates for Tanzania; extend pattern).
5. Language switcher links (`EN/IT/FR/DE` in header/footer) must point to the equivalent page, not just home.
6. Slug registry per language lives in `data/content.json` → `destinations[].i18n`.
7. Never machine-translate-and-publish: draft → native review → publish. No auto-redirect by IP (kills indexability); use a passive language banner instead.

## Slug map (extend as you translate)
| EN | IT | FR | DE |
|---|---|---|---|
| /tanzania-safari/ | /it/tanzania-safari/ | /fr/tanzania-safari/ | /de/tanzania-safari/ |
| /kenya-safari/ | /it/kenya-safari/ | /fr/kenya-safari/ | /de/kenya-safari/ |
| /uganda-safari/ | /it/uganda-safari/ | /fr/uganda-safari/ | /de/uganda-safari/ |


## Spanish (live) + adding more languages
Spanish home /es/ and hub /es/tanzania-safari/ are live with full hreflang clusters (EN page carries the ES alternate). Add Portuguese, Dutch and others by appending to data/languages.json (code, label, flag, home path, Tanzania path), then creating /{code}/ home + /{code}/{localized-slug}/ hub. Switcher shows flags for EN/IT/FR/DE/ES.

| EN | IT | FR | DE | ES |
|---|---|---|---|---|
| /tanzania-safari/ | /it/tanzania-safari/ | /fr/tanzania-safari/ | /de/tanzania-safari/ | /es/tanzania-safari/ |
