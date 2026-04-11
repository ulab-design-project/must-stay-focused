create table users (
  id uuid primary key,
  name text not null,
  email text not null,
  created_at timestamp default now()
);