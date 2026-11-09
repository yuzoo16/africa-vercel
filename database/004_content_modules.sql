CREATE TABLE IF NOT EXISTS safari_packages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id uuid REFERENCES pages(id) ON DELETE SET NULL,
  duration_days integer,
  starting_price numeric(12,2),
  category text,
  itinerary jsonb NOT NULL DEFAULT '[]',
  included_services jsonb NOT NULL DEFAULT '[]',
  excluded_services jsonb NOT NULL DEFAULT '[]',
  status publication_status NOT NULL DEFAULT 'draft',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS destinations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id uuid REFERENCES pages(id) ON DELETE SET NULL,
  country text,
  overview text,
  attractions jsonb NOT NULL DEFAULT '[]',
  wildlife jsonb NOT NULL DEFAULT '[]',
  activities jsonb NOT NULL DEFAULT '[]',
  status publication_status NOT NULL DEFAULT 'draft',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS national_parks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id uuid REFERENCES pages(id) ON DELETE SET NULL,
  country text,
  location jsonb NOT NULL DEFAULT '{}',
  overview text,
  wildlife jsonb NOT NULL DEFAULT '[]',
  ecosystems jsonb NOT NULL DEFAULT '[]',
  activities jsonb NOT NULL DEFAULT '[]',
  status publication_status NOT NULL DEFAULT 'draft',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
