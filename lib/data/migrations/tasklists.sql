create table public.task_lists
(
    id uuid primary key default gen_random_uuid(),
    name text not null,
    author_id uuid not null references public.users(id) on delete cascade,
    json_payload jsonb default '{}'::jsonb,
    created_at timestamp with time zone default now()
);