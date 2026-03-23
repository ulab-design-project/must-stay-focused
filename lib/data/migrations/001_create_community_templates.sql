-- migrations/001_create_community_templates.sql
-- Create table for community templates
CREATE TABLE IF NOT EXISTS community_templates (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    author_name TEXT NOT NULL,
    downloads INT DEFAULT 0,
    star_rating FLOAT DEFAULT 0,
    json_payload JSONB NOT NULL
);