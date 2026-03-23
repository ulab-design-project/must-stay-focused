-- migrations/002_create_tasks_table.sql
-- Create table for tasks (local models will serialize here if needed)
CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    due_date TIMESTAMP,
    time TIMESTAMP,
    priority TEXT NOT NULL,
    category TEXT NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE
);