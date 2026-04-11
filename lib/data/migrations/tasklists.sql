create table tasklists (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  author_id uuid not null,
  json_payload jsonb not null,
  created_at timestamp default now()
);