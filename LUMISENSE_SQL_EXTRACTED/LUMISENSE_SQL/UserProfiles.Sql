-- ── 1. Profiles table ───────────────────────────────────────
create table if not exists profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  display_name text default '',
  avatar_url   text default '',
  updated_at   timestamptz default now()
);

-- ── 2. RLS — users can only read/update their own row ───────
alter table profiles enable row level security;

create policy "users_read_own_profile"
  on profiles for select
  to authenticated
  using (auth.uid() = id);

create policy "users_update_own_profile"
  on profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- ── 3. Auto-create profile row when auth user is created ────
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, display_name, avatar_url)
  values (new.id, '', '');
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ── 4. Avatars storage bucket ───────────────────────────────
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

create policy "avatar_upload"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'avatars');

create policy "avatar_update"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'avatars');

create policy "avatar_read"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'avatars');