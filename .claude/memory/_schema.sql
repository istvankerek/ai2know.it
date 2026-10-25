-- Memory v2 (RAD) SQLite schema
-- Everengine v6.5 – Retrieval Augmented Distillation
-- Letrehozas: sqlite3 observations.db < _schema.sql

CREATE TABLE IF NOT EXISTS observations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    type TEXT CHECK(type IN ('bugfix','discovery','decision','gotcha','pattern','trade-off','how-it-works')),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    tags TEXT,
    related_files TEXT,
    related_observations TEXT
);

CREATE INDEX IF NOT EXISTS idx_obs_type ON observations(type);
CREATE INDEX IF NOT EXISTS idx_obs_tags ON observations(tags);
CREATE INDEX IF NOT EXISTS idx_obs_timestamp ON observations(timestamp);
