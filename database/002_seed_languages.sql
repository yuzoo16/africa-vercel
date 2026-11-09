INSERT INTO languages (code, name, locale, is_default, sort_order) VALUES
  ('en', 'English', 'en-US', true, 1),
  ('de', 'Deutsch', 'de-DE', false, 2),
  ('fr', 'Français', 'fr-FR', false, 3),
  ('es', 'Español', 'es-ES', false, 4),
  ('it', 'Italiano', 'it-IT', false, 5)
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  locale = EXCLUDED.locale,
  is_default = EXCLUDED.is_default,
  sort_order = EXCLUDED.sort_order;
