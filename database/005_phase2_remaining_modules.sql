CREATE TABLE IF NOT EXISTS safari_experiences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id uuid REFERENCES pages(id) ON DELETE SET NULL,
  experience_type text NOT NULL,
  overview jsonb NOT NULL DEFAULT '{}',
  status publication_status NOT NULL DEFAULT 'draft',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS accommodation (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id uuid REFERENCES pages(id) ON DELETE SET NULL,
  property_type text,
  destination text,
  overview jsonb NOT NULL DEFAULT '{}',
  amenities jsonb NOT NULL DEFAULT '[]',
  status publication_status NOT NULL DEFAULT 'draft',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS travel_guides (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id uuid REFERENCES pages(id) ON DELETE SET NULL,
  guide_type text,
  overview jsonb NOT NULL DEFAULT '{}',
  status publication_status NOT NULL DEFAULT 'draft',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS blogs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id uuid REFERENCES pages(id) ON DELETE SET NULL,
  author text,
  category text,
  tags text[] NOT NULL DEFAULT '{}',
  publication_date timestamptz,
  status publication_status NOT NULL DEFAULT 'draft',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS content_entity_translations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type text NOT NULL,
  entity_id uuid NOT NULL,
  language_id uuid NOT NULL REFERENCES languages(id),
  content jsonb NOT NULL DEFAULT '{}',
  translation_status text NOT NULL DEFAULT 'not_started',
  source_updated_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (entity_type, entity_id, language_id)
);

CREATE INDEX IF NOT EXISTS content_entity_translations_lookup_idx
  ON content_entity_translations(entity_type, entity_id, language_id);
