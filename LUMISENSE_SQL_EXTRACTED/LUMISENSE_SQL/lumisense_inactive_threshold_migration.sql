-- ============================================================
-- LUMISENSE · SQL Migration
-- Supports: Inactive Zone Logging + Threshold Breach Logging
-- Run this in your Supabase SQL Editor
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 1.  Add 'inactive_zone' as an explicit event_type to audit_logs
--     No schema change needed — the 'event' text column already
--     holds free-form descriptions.
--     But we add an index on 'severity' for fast filtering.
-- ─────────────────────────────────────────────────────────────
create index if not exists idx_audit_logs_severity
  on audit_logs(severity, created_at desc);


-- ─────────────────────────────────────────────────────────────
-- 2.  Add 'event_type' column to audit_logs
--     Allows the app to filter rows by type:
--       'noise'        — AI-classified noise breach
--       'threshold'    — sound or temperature threshold crossed
--       'inactive'     — zone stopped sending data for 10+ min
--       'buzzer'       — manual buzzer override fired
--       'system'       — general info / reconnects
-- ─────────────────────────────────────────────────────────────
alter table audit_logs
  add column if not exists event_type text not null default 'system';

-- Index for filtering by event type
create index if not exists idx_audit_logs_event_type
  on audit_logs(event_type, created_at desc);


-- ─────────────────────────────────────────────────────────────
-- 3.  Add 'last_seen_at' column to zones
--     Updated by the Flutter app whenever a new sensor reading
--     arrives for that zone.  Lets us quickly query stale zones.
-- ─────────────────────────────────────────────────────────────
alter table zones
  add column if not exists last_seen_at timestamptz;

-- Back-fill with the newest sensor reading per zone
update zones z
set last_seen_at = (
  select max(created_at)
  from sensor_readings sr
  where sr.zone_id = z.id
);


-- ─────────────────────────────────────────────────────────────
-- 4.  Helper view: inactive_zones
--     Returns any zone whose last sensor reading is older than
--     10 minutes (or has never sent data).
--     Useful for a future "offline devices" panel.
-- ─────────────────────────────────────────────────────────────
create or replace view inactive_zones as
select
  z.id          as zone_id,
  z.zone_name,
  z.status,
  z.last_seen_at,
  extract(epoch from (now() - z.last_seen_at)) / 60 as minutes_since_last_data
from zones z
where
  z.last_seen_at is null
  or z.last_seen_at < now() - interval '10 minutes';


-- ─────────────────────────────────────────────────────────────
-- 5.  Helper view: recent_threshold_breaches
--     Quick audit of the last 24 h of threshold / inactive logs
-- ─────────────────────────────────────────────────────────────
create or replace view recent_threshold_breaches as
select
  al.id,
  al.created_at,
  al.department,
  al.event_type,
  al.event,
  al.severity,
  z.zone_name
from audit_logs al
left join zones z on z.id = al.zone_id
where
  al.event_type in ('threshold', 'inactive', 'noise')
  and al.created_at >= now() - interval '24 hours'
order by al.created_at desc;


-- ─────────────────────────────────────────────────────────────
-- 6.  Sample rows so Statistics page has test data
-- ─────────────────────────────────────────────────────────────
insert into audit_logs (zone_id, department, event_type, event, severity) values
  (1, 'IT',          'threshold', 'Sound threshold exceeded: 58.3 dB (max 55 dB)',                          'warning'),
  (2, 'CS',          'threshold', 'Temperature out of range: 29.5°C (above max 28°C)',                     'warning'),
  (3, 'Engineering', 'inactive',  'Zone marked INACTIVE — no data received for 12 minutes (last seen: ...)', 'warning'),
  (1, 'IT',          'noise',     'Shouting detected at 63.1 dB',                                           'critical'),
  (2, 'CS',          'buzzer',    'Manual buzzer override triggered by operator',                            'info'),
  (3, 'Engineering', 'threshold', 'Sound threshold exceeded: 57.0 dB (max 55 dB)',                          'warning');


-- ─────────────────────────────────────────────────────────────
-- Done.
-- New columns / views are additive — existing app logic is
-- unaffected until you start using them.
-- ─────────────────────────────────────────────────────────────
