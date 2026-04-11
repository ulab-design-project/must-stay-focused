create table public.users
(
    id uuid primary key references auth.users(id) on delete cascade,
    name text not null,
    email text unique not null,
    created_at timestamp with time zone default now()
);