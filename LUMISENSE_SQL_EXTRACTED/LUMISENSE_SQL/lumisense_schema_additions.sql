-- ============================================================
-- LUMISENSE · Supabase Schema ADDITIONS
-- Run this AFTER lumisense_schema.sql is already applied
-- ============================================================


-- ============================================================
-- FIX: Add missing columns to noise_events
-- The Statistics Report page needs event_description + severity
-- ============================================================
alter table noise_events
  add column if not exists event_description text default '',
  add column if not exists severity text default 'info';
-- severity values: 'info' | 'warning' | 'critical'


-- ============================================================
-- NEW TABLE: audit_logs
-- For the Statistics Report page
-- Written by the Flutter app whenever a notable event happens
-- Columns match exactly what the page shows:
--   Log ID | Timestamp | Department | Event | Severity
-- Super Admin can delete rows, Admin cannot
-- ============================================================
create table if not exists audit_logs (
  id            bigint generated always as identity primary key,
  zone_id       int references zones(id),              -- which zone (null = system-wide)
  department    text not null default '',              -- 'CS' | 'IT' | 'Engineering'
  event         text not null,                         -- human-readable description
  severity      text not null default 'info',          -- 'info' | 'warning' | 'critical'
  created_at    timestamptz default now()
);

-- Index for fast time-range queries
create index if not exists idx_audit_logs_time
  on audit_logs(created_at desc);

-- Index for per-zone queries
create index if not exists idx_audit_logs_zone
  on audit_logs(zone_id, created_at desc);

-- RLS: anyone can insert/read, but delete is controlled in app logic by role
alter table audit_logs enable row level security;
create policy "allow_all_audit_logs"
  on audit_logs for all
  to anon, authenticated
  using (true)
  with check (true);

-- Enable Realtime (so Statistics page updates live)
alter publication supabase_realtime add table audit_logs;


-- ============================================================
-- NEW TABLE: user_roles
-- Needed for Statistics Report page (Admin vs Super Admin)
-- Super Admin can delete audit_log rows, Admin cannot
-- ============================================================
create table if not exists user_roles (
  id       serial primary key,
  username text not null unique,
  role     text not null default 'admin'   -- 'admin' | 'super_admin'
);

-- Seed: default super admin account
insert into user_roles (username, role) values
  ('admin', 'super_admin')
on conflict (username) do nothing;

-- RLS: open for app authentication
alter table user_roles enable row level security;
create policy "allow_all_user_roles"
  on user_roles for all
  to anon, authenticated
  using (true)
  with check (true);


-- ============================================================
-- VIEWS: Pre-calculated data for the Summary Panel
-- The app reads these views directly instead of doing
-- heavy math client-side
-- ============================================================

-- View 1: summary_stats
-- Calculates all the values shown in the Summary Panel
-- Based on the last 3 hours of data (adjustable)
create or replace view summary_stats as
select
  -- Sound
  round(avg(rms)::numeric, 1)                        as avg_sound_rms,
  round(max(rms)::numeric, 1)                        as highest_sound_rms,
  -- Temperature
  round(avg(temperature_c)::numeric, 1)              as avg_temperature,
  round(max(temperature_c)::numeric, 1)              as highest_temperature,
  -- Total records
  count(*)                                           as total_records,
  -- Time range used
  min(created_at)                                    as from_time,
  max(created_at)                                    as to_time
from sensor_readings
where created_at >= now() - interval '3 hours';


-- View 2: noise_event_stats
-- Calculates Most Common Noise, Red Trigger Count,
-- Most Noisy Department, AM/PM breakdown
create or replace view noise_event_stats as
select
  -- Most noisy zone (by critical event count)
  (
    select z.zone_name
    from noise_events ne
    join zones z on z.id = ne.zone_id
    where ne.severity = 'critical'
      and ne.created_at >= now() - interval '3 hours'
    group by z.zone_name
    order by count(*) desc
    limit 1
  ) as most_noisy_department,

  -- Most common noise label
  (
    select noise_label
    from noise_events
    where created_at >= now() - interval '3 hours'
    group by noise_label
    order by count(*) desc
    limit 1
  ) as most_common_noise,

  -- Total critical (red) triggers
  (
    select count(*)
    from noise_events
    where severity = 'critical'
      and created_at >= now() - interval '3 hours'
  ) as red_trigger_count,

  -- AM noisier or PM noisier?
  (
    select case
      when sum(case when extract(hour from created_at) < 12 then 1 else 0 end)
         > sum(case when extract(hour from created_at) >= 12 then 1 else 0 end)
      then 'AM' else 'PM' end
    from noise_events
    where severity in ('warning', 'critical')
      and created_at >= now() - interval '3 hours'
  ) as most_noisy_period;


-- View 3: zone_am_pm_counts
-- For the Department page AM Count / PM Count display
create or replace view zone_am_pm_counts as
select
  ne.zone_id,
  z.zone_name,
  count(case when extract(hour from ne.created_at) < 12
             and ne.severity in ('warning','critical') then 1 end) as am_count,
  count(case when extract(hour from ne.created_at) >= 12
             and ne.severity in ('warning','critical') then 1 end) as pm_count
from noise_events ne
join zones z on z.id = ne.zone_id
where ne.created_at >= now() - interval '24 hours'
group by ne.zone_id, z.zone_name;


-- ============================================================
-- SAMPLE audit_log entries (for testing the Statistics page)
-- ============================================================
insert into audit_logs (zone_id, department, event, severity) values
  (1, 'CS',          'Noise level exceeded 72 dB (Critical)',       'critical'),
  (2, 'IT',          'Temperature spike: 29.1°C',                   'warning'),
  (1, 'CS',          'Buzzer triggered — shouting detected',        'critical'),
  (3, 'Engineering', 'Sensor reconnected after 3s dropout',         'info'),
  (2, 'IT',          'Sound classification: furniture_dragging',    'warning'),
  (1, 'CS',          'Environmental summary exported',              'info');
