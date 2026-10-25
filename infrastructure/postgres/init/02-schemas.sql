-- Schema-per-service
CREATE SCHEMA IF NOT EXISTS auth_schema;
CREATE SCHEMA IF NOT EXISTS product_schema;
CREATE SCHEMA IF NOT EXISTS log_schema;
CREATE SCHEMA IF NOT EXISTS notification_schema;
CREATE SCHEMA IF NOT EXISTS scraper_schema;
CREATE SCHEMA IF NOT EXISTS taxonomy_schema;

COMMENT ON SCHEMA auth_schema IS 'Felhasznalok, role-ok, session-ok';
COMMENT ON SCHEMA product_schema IS 'Termekek, kategoriak';
COMMENT ON SCHEMA log_schema IS 'Audit trail, activity log';
COMMENT ON SCHEMA notification_schema IS 'Ertesitesek, email naplo';
COMMENT ON SCHEMA scraper_schema IS 'Scraper es spider adatok';
COMMENT ON SCHEMA taxonomy_schema IS 'Taxonomy-k (groups, labels, categories)';
