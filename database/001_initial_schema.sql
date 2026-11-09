CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TYPE publication_status AS ENUM ('draft', 'in_review', 'approved', 'published', 'archived');
CREATE TYPE user_role AS ENUM ('admin', 'editor', 'translator', 'seo', 'publisher', 'viewer');
CREATE TYPE revision_action AS ENUM ('create', 'update', 'submit', 'approve', 'publish', 'restore', 'archive');

CREATE TABLE languages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  locale text NOT NULL,
  is_default boolean NOT NULL DEFAULT false,
  is_enabled boolean NOT NULL DEFAULT true,
  sort_order integer NOT NULL DEFAULT 0
);

CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL UNIQUE,
  password_hash text NOT NULL,
  display_name text NOT NULL,
  role user_role NOT NULL DEFAULT 'viewer',
  is_active boolean NOT NULL DEFAULT true,
  last_login_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE pages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_type text NOT NULL,
  template text NOT NULL,
  legacy_source_path text,
  created_by uuid REFERENCES users(id),
  updated_by uuid REFERENCES users(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE page_translations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id uuid NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
  language_id uuid NOT NULL REFERENCES languages(id),
  slug text NOT NULL,
  full_path text NOT NULL,
  title text,
  description text,
  h1 text,
  status publication_status NOT NULL DEFAULT 'draft',
  source_translation_id uuid REFERENCES page_translations(id),
  source_updated_at timestamptz,
  published_at timestamptz,
  published_revision_id uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (language_id, full_path),
  UNIQUE (page_id, language_id)
);

CREATE TABLE content_blocks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id uuid NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
  block_type text NOT NULL,
  position integer NOT NULL DEFAULT 0,
  is_hidden boolean NOT NULL DEFAULT false,
  settings jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE block_translations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  block_id uuid NOT NULL REFERENCES content_blocks(id) ON DELETE CASCADE,
  language_id uuid NOT NULL REFERENCES languages(id),
  content jsonb NOT NULL DEFAULT '{}',
  status publication_status NOT NULL DEFAULT 'draft',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (block_id, language_id)
);

CREATE TABLE seo_metadata (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_translation_id uuid NOT NULL REFERENCES page_translations(id) ON DELETE CASCADE,
  seo_title text,
  meta_description text,
  canonical_url text,
  og_title text,
  og_description text,
  social_image_id uuid,
  robots text NOT NULL DEFAULT 'index,follow',
  structured_data jsonb NOT NULL DEFAULT '{}',
  hreflang jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (page_translation_id)
);

CREATE TABLE media_assets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  storage_key text NOT NULL UNIQUE,
  file_name text NOT NULL,
  mime_type text NOT NULL,
  byte_size bigint NOT NULL,
  width integer,
  height integer,
  folder text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE media_asset_translations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  media_asset_id uuid NOT NULL REFERENCES media_assets(id) ON DELETE CASCADE,
  language_id uuid NOT NULL REFERENCES languages(id),
  alt_text text NOT NULL DEFAULT '',
  title text NOT NULL DEFAULT '',
  caption text NOT NULL DEFAULT '',
  UNIQUE (media_asset_id, language_id)
);

CREATE TABLE redirects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_path text NOT NULL,
  destination_path text NOT NULL,
  status_code integer NOT NULL DEFAULT 301,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (source_path)
);

CREATE TABLE navigation_menus (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL,
  language_id uuid NOT NULL REFERENCES languages(id),
  UNIQUE (code, language_id)
);

CREATE TABLE navigation_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  menu_id uuid NOT NULL REFERENCES navigation_menus(id) ON DELETE CASCADE,
  parent_id uuid REFERENCES navigation_items(id),
  page_id uuid REFERENCES pages(id),
  label text NOT NULL,
  external_url text,
  position integer NOT NULL DEFAULT 0,
  is_visible boolean NOT NULL DEFAULT true
);

CREATE TABLE revisions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_translation_id uuid NOT NULL REFERENCES page_translations(id) ON DELETE CASCADE,
  user_id uuid REFERENCES users(id),
  action revision_action NOT NULL,
  snapshot jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE publishing_jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  requested_by uuid REFERENCES users(id),
  approved_by uuid REFERENCES users(id),
  status text NOT NULL,
  build_manifest jsonb NOT NULL DEFAULT '{}',
  report jsonb NOT NULL DEFAULT '{}',
  preview_url text,
  created_at timestamptz NOT NULL DEFAULT now(),
  started_at timestamptz,
  completed_at timestamptz
);

CREATE INDEX content_blocks_page_position_idx ON content_blocks(page_id, position);
CREATE INDEX page_translations_status_idx ON page_translations(status);
CREATE INDEX revisions_page_translation_created_idx ON revisions(page_translation_id, created_at DESC);
