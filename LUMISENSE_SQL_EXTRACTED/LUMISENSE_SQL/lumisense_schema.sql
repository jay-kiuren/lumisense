-- ============================================================
-- LUMISENSE · Supabase Schema
-- Smart Library Noise Monitoring System
-- ============================================================
-- HOW TO USE:
-- 1. Go to your Supabase dashboard → SQL Editor
-- 2. Paste this entire file and click Run
-- ============================================================


-- ============================================================
-- TABLE 1: zones
-- Registers each ESP32 zone/department
-- ============================================================
create table if not exists zones (
  id          serial primary key,
  zone_name   text not null,           -- e.g. 'CS Department', 'IT Department'
  status      text default 'active'    -- 'active' | 'inactive'
);

-- Seed: your initial zones (match your ESP32 zone IDs)
insert into zones (zone_name, status) values
  ('CS Department',  'active'),
  ('IT Department',  'active'),
  ('Engineering Department', 'active');


-- ============================================================
-- TABLE 2: sensor_readings
-- Raw data sent by each ESP32 every ~1 second
-- The app reads this to run AI classification
-- ============================================================
create table if not exists sensor_readings (
  id            bigint generated always as identity primary key,
  zone_id       int not null references zones(id),
  avg           float not null,         -- average amplitude
  peak          float not null,         -- peak amplitude
  min           float not null,         -- minimum amplitude
  rms           float not null,         -- RMS value
  temperature_c float default 25.0,     -- DHT11 temperature in Celsius
  created_at    timestamptz default now()
);

-- Index for fast per-zone time-range queries
create index if not exists idx_sensor_readings_zone_time
  on sensor_readings(zone_id, created_at desc);

-- Enable Realtime so Flutter gets live updates
alter publication supabase_realtime add table sensor_readings;


-- ============================================================
-- TABLE 3: zone_status
-- Written by the Flutter app after AI classification
-- ESP32 polls this to know: LED color + buzzer behavior
-- One row per zone (upserted, not appended)
-- ============================================================
create table if not exists zone_status (
  zone_id       int primary key references zones(id),
  noise_label   text default 'quiet',   -- e.g. 'quiet', 'shouting', 'furniture_dragging'
  noise_level   text default 'quiet',   -- 'quiet' | 'normal' | 'warning' | 'critical'
  led_color     text default 'green',   -- 'green' | 'blue' | 'red'
  buzzer_active boolean default false,  -- should buzzer fire right now?
  updated_at    timestamptz default now()
);

-- Seed one row per zone (ESP32 polls these)
insert into zone_status (zone_id, noise_label, noise_level, led_color, buzzer_active)
values (1, 'quiet', 'quiet', 'green', false),
       (2, 'quiet', 'quiet', 'green', false),
       (3, 'quiet', 'quiet', 'green', false)
on conflict (zone_id) do nothing;

-- Enable Realtime so ESP32 gets instant LED/buzzer commands
alter publication supabase_realtime add table zone_status;


-- ============================================================
-- TABLE 4: buzzer_control
-- Written by the Flutter app (manual override toggle)
-- ESP32 checks this before firing the buzzer
-- One row per zone
-- ============================================================
create table if not exists buzzer_control (
  zone_id           int primary key references zones(id),
  mode              text default 'auto',   -- 'auto' | 'manual'
  manual_state      boolean default false, -- only used when mode = 'manual'
                                           -- true = force ON, false = force OFF
  updated_at        timestamptz default now()
);

-- Seed
insert into buzzer_control (zone_id, mode, manual_state)
values (1, 'auto', false),
       (2, 'auto', false),
       (3, 'auto', false)
on conflict (zone_id) do nothing;

-- Enable Realtime so ESP32 reacts instantly to override changes
alter publication supabase_realtime add table buzzer_control;


-- ============================================================
-- TABLE 5: noise_events
-- Historical log of each detected noise event
-- Written by Flutter app after classification
-- Used for analytics, AM/PM counts, reports
-- ============================================================
create table if not exists noise_events (
  id            bigint generated always as identity primary key,
  zone_id       int not null references zones(id),
  noise_label   text not null,           -- 'shouting', 'clapping', etc.
  noise_level   text not null,           -- 'quiet' | 'normal' | 'warning' | 'critical'
  rms           float,                   -- snapshot of rms at time of event
  temperature_c float,                   -- snapshot of temp at time of event
  created_at    timestamptz default now()
);

-- Index for analytics queries (per zone, per time range)
create index if not exists idx_noise_events_zone_time
  on noise_events(zone_id, created_at desc);


-- ============================================================
-- TABLE 6: settings
-- App-controlled thresholds and alarm config
-- Saved by the Settings page, read by app AI logic
-- ============================================================
create table if not exists settings (
  id                      int primary key default 1,  -- single row
  noise_warning_threshold float default 60.0,         -- dB threshold for 'warning'
  noise_critical_threshold float default 72.0,        -- dB threshold for 'critical'
  temp_threshold          float default 26.0,         -- °C alert threshold
  alarm_pattern           text default 'short_burst', -- 'continuous'|'pulsing'|'escalating'|'short_burst'
  alarm_duration_sec      float default 5.0,          -- how long buzzer fires
  alarm_cooldown_sec      float default 30.0,         -- min gap between triggers
  updated_at              timestamptz default now()
);

-- Seed default settings
insert into settings (id) values (1)
on conflict (id) do nothing;


-- ============================================================
-- RLS (Row Level Security) — DISABLE for ESP32 tables
-- ESP32 uses the publishable key which is anon role.
-- These tables need open read/write for the hardware to work.
-- ============================================================

-- sensor_readings: ESP32 inserts, app reads
alter table sensor_readings enable row level security;
create policy "allow_all_sensor_readings"
  on sensor_readings for all
  to anon, authenticated
  using (true)
  with check (true);

-- zone_status: app writes, ESP32 reads
alter table zone_status enable row level security;
create policy "allow_all_zone_status"
  on zone_status for all
  to anon, authenticated
  using (true)
  with check (true);

-- buzzer_control: app writes, ESP32 reads
alter table buzzer_control enable row level security;
create policy "allow_all_buzzer_control"
  on buzzer_control for all
  to anon, authenticated
  using (true)
  with check (true);

-- zones: read only for everyone
alter table zones enable row level security;
create policy "allow_read_zones"
  on zones for select
  to anon, authenticated
  using (true);

-- noise_events: app inserts and reads
alter table noise_events enable row level security;
create policy "allow_all_noise_events"
  on noise_events for all
  to anon, authenticated
  using (true)
  with check (true);

-- settings: app reads and writes
alter table settings enable row level security;
create policy "allow_all_settings"
  on settings for all
  to anon, authenticated
  using (true)
  with check (true);
