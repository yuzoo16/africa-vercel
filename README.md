# africa-vercel

## Vercel publishing API

The `POST /api/publish` endpoint builds the static site and uploads the ZIP to the
Supabase Storage bucket `safari-archives`. Configure these Vercel environment
variables on the server only:

- Set the Vercel project Root Directory to the repository root.
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `PUBLISH_API_TOKEN` (a long random secret sent as `Authorization: Bearer <token>`)

The Supabase `website_pages` table must contain the publisher fields, including
`status`, `source_path` (or `legacy_source_path`), and `content_html`. The Storage
bucket must exist and allow uploads using the service-role key. Never expose the
service-role key or publishing token in browser code.