
create table if not exists settings (
  id                       int primary key default 1,
  noise_warning_threshold  float default 60.0,
  noise_critical_threshold float default 72.0,
  temp_threshold           float default 26.0,
  alarm_pattern            text  default 'short_burst',
  alarm_duration_sec       float default 5.0,
  alarm_cooldown_sec       float default 30.0,
  updated_at               timestamptz default now()
);


-- ── 2. Seed default row if it doesn't exist ─────────────────
insert into settings (id)
values (1)
on conflict (id) do nothing;


alter table settings enable row level security;

drop policy if exists "allow_all_settings" on settings;
create policy "allow_all_settings"
  on settings for all
  to anon, authenticated
  using (true)
  with check (true);

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and tablename = 'settings'
  ) then
    alter publication supabase_realtime add table settings;
  end if;
end $$;


-- ── 5. Verify — you should see 1 row with your defaults ─────
select * from settings;
