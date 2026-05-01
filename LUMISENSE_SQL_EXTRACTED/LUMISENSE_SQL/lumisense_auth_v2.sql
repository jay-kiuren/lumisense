-- ============================================================
-- LUMISENSE · User Auth & Profiles
-- SAFE TO RUN MULTIPLE TIMES — drops everything first
-- ============================================================

-- ============================================================
-- STEP 1: Drop existing policies first (profiles)
-- ============================================================
drop policy if exists "users can view own profile"       on profiles;
drop policy if exists "users can update own profile"     on profiles;
drop policy if exists "service role can insert profiles" on profiles;
drop policy if exists "allow insert on signup"           on profiles;

-- ============================================================
-- STEP 2: Drop existing storage policies
-- ============================================================
drop policy if exists "authenticated users can upload avatar" on storage.objects;
drop policy if exists "avatars are publicly readable"         on storage.objects;
drop policy if exists "users can update own avatar"           on storage.objects;
drop policy if exists "users can delete own avatar"           on storage.objects;

-- ============================================================
-- STEP 3: Drop trigger and function
-- ============================================================
drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_user();

-- ============================================================
-- STEP 4: Drop old user_roles table if still exists
-- ============================================================
drop table if exists user_roles;

-- ============================================================
-- STEP 5: Create profiles table
-- ============================================================
create table if not exists profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  full_name  text not null default '',
  avatar_url text default '',
  role       text not null default 'admin',
  created_at timestamptz default now()
);

-- ============================================================
-- STEP 6: Enable RLS + create policies
-- ============================================================
alter table profiles enable row level security;

create policy "users can view own profile"
  on profiles for select
  to authenticated
  using (auth.uid() = id);

create policy "users can update own profile"
  on profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "service role can insert profiles"
  on profiles for insert
  to service_role
  with check (true);

create policy "allow insert on signup"
  on profiles for insert
  to authenticated, anon
  with check (true);

-- ============================================================
-- STEP 7: Create trigger function
-- ============================================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, avatar_url, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'avatar_url', ''),
    'admin'
  );
  return new;
end;
$$;

-- ============================================================
-- STEP 8: Attach trigger
-- ============================================================
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ============================================================
-- STEP 9: Storage bucket
-- ============================================================
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- ============================================================
-- STEP 10: Storage policies
-- ============================================================
create policy "authenticated users can upload avatar"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'avatars');

create policy "avatars are publicly readable"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'avatars');

create policy "users can update own avatar"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'avatars');

create policy "users can delete own avatar"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'avatars');
