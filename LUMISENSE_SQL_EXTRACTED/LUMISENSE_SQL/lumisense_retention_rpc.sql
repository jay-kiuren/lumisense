create table if not exists daily_logs (
  id              bigint generated always as identity primary key,
  zone_id         int not null references zones(id),
  log_date        date not null,
  avg_rms         float default 0,
  peak_rms        float default 0,
  avg_temperature float default 0,
  max_temperature float default 0,
  min_temperature float default 0,
  total_readings  int default 0,
  noisy_events    int default 0,
  critical_events int default 0,
  am_noisy_count  int default 0,
  pm_noisy_count  int default 0,
  created_at      timestamptz default now()
);

create unique index if not exists idx_daily_logs_zone_date
  on daily_logs(zone_id, log_date);

create index if not exists idx_daily_logs_date
  on daily_logs(log_date desc);

alter table daily_logs enable row level security;

drop policy if exists "allow_all_daily_logs" on daily_logs;
create policy "allow_all_daily_logs"
  on daily_logs for all
  to anon, authenticated
  using (true)
  with check (true);


-- ============================================================
-- FUNCTION 1: summarize_yesterday()
-- Calculates daily averages and stores in daily_logs
-- Called by run_daily_cleanup()
-- ============================================================
create or replace function summarize_yesterday()
returns void
language plpgsql
security definer
as $$
declare
  target_date date := (now() - interval '1 day')::date;
begin
  insert into daily_logs (
    zone_id,
    log_date,
    avg_rms,
    peak_rms,
    avg_temperature,
    max_temperature,
    min_temperature,
    total_readings,
    noisy_events,
    critical_events,
    am_noisy_count,
    pm_noisy_count
  )
  select
    sr.zone_id,
    target_date,
    round(avg(sr.rms)::numeric, 2),
    round(max(sr.rms)::numeric, 2),
    round(avg(sr.temperature_c)::numeric, 2),
    round(max(sr.temperature_c)::numeric, 2),
    round(min(sr.temperature_c)::numeric, 2),
    count(*),
    coalesce((
      select count(*) from noise_events ne
      where ne.zone_id = sr.zone_id
        and ne.created_at::date = target_date
    ), 0),
    coalesce((
      select count(*) from noise_events ne
      where ne.zone_id = sr.zone_id
        and ne.severity = 'critical'
        and ne.created_at::date = target_date
    ), 0),
    coalesce((
      select count(*) from noise_events ne
      where ne.zone_id = sr.zone_id
        and extract(hour from ne.created_at) < 12
        and ne.created_at::date = target_date
    ), 0),
    coalesce((
      select count(*) from noise_events ne
      where ne.zone_id = sr.zone_id
        and extract(hour from ne.created_at) >= 12
        and ne.created_at::date = target_date
    ), 0)
  from sensor_readings sr
  where sr.created_at::date = target_date
  group by sr.zone_id
  on conflict (zone_id, log_date) do update set
    avg_rms         = excluded.avg_rms,
    peak_rms        = excluded.peak_rms,
    avg_temperature = excluded.avg_temperature,
    max_temperature = excluded.max_temperature,
    min_temperature = excluded.min_temperature,
    total_readings  = excluded.total_readings,
    noisy_events    = excluded.noisy_events,
    critical_events = excluded.critical_events,
    am_noisy_count  = excluded.am_noisy_count,
    pm_noisy_count  = excluded.pm_noisy_count;
end;
$$;


-- ============================================================
-- FUNCTION 2: delete_old_readings()
-- Deletes sensor_readings older than 24 hours
-- Called by run_daily_cleanup()
-- ============================================================
create or replace function delete_old_readings()
returns int
language plpgsql
security definer
as $$
declare
  deleted_count int;
begin
  delete from sensor_readings
  where created_at < now() - interval '24 hours';

  get diagnostics deleted_count = row_count;
  return deleted_count;
end;
$$;


-- ============================================================
-- FUNCTION 3: run_daily_cleanup()
-- Master function — app calls this once per day
-- Summarizes yesterday THEN deletes old raw data
-- Safe to call multiple times (idempotent)
-- ============================================================
create or replace function run_daily_cleanup()
returns json
language plpgsql
security definer
as $$
declare
  deleted_count int;
  result        json;
begin
  -- Step 1: Summarize yesterday into daily_logs
  perform summarize_yesterday();

  -- Step 2: Delete old raw sensor readings
  select delete_old_readings() into deleted_count;

  -- Return summary of what was done
  result := json_build_object(
    'status',          'success',
    'deleted_readings', deleted_count,
    'summarized_date',  (now() - interval '1 day')::date,
    'ran_at',           now()
  );

  return result;
end;
$$;


-- ============================================================
-- FUNCTION 4: check_cleanup_needed()
-- App calls this on startup to see if cleanup is due
-- Returns true if last cleanup was more than 20 hours ago
-- ============================================================
create or replace function check_cleanup_needed()
returns boolean
language plpgsql
security definer
as $$
declare
  last_log_date date;
begin
  select max(log_date) into last_log_date from daily_logs;

  -- If no logs yet or last log was yesterday or earlier → cleanup needed
  if last_log_date is null or last_log_date < current_date then
    return true;
  end if;

  return false;
end;
$$;


-- ============================================================
-- HOW THE FLUTTER APP USES THESE:
--
-- On app startup:
--   final needed = await supabase.rpc('check_cleanup_needed');
--   if (needed) {
--     await supabase.rpc('run_daily_cleanup');
--   }
--
-- This means cleanup runs automatically once per day
-- the first time any admin opens the app after midnight
-- No cron needed, works on free plan
-- ============================================================
