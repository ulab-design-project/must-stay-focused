create table if not exists public.community_templates
(
    id uuid primary key default gen_random_uuid(),
    type text not null check (type in ('tasklist', 'flashcard')),
    title text not null,
    author_name text not null,
    description text not null default '',
    tags text[] not null default '{}',
    downloads integer not null default 0,
    json_payload jsonb not null default '{}'::jsonb,
    created_at timestamp with time zone not null default now()
);

alter table public.community_templates disable row level security;

grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on table public.community_templates to anon, authenticated;

notify pgrst, 'reload schema';

create index if not exists community_templates_type_created_at_idx
    on public.community_templates(type, created_at desc);

create index if not exists community_templates_type_downloads_idx
    on public.community_templates(type, downloads desc);
