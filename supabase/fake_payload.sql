-- Fake telemetry payloads for quick UI/realtime verification.
-- Run in Supabase SQL Editor after schema.sql has been applied.

-- Ensure zone records exist (safe if they already do).
insert into sensors (zone_id, zone_name, status)
values
  (1, 'IT Department', 'active'),
  (2, 'CS Department', 'active'),
  (3, 'Engineering Department', 'active')
on conflict (zone_id) do nothing;

-- Sample single payload (Zone 1).
insert into data (zone_id, sensor_data)
values (
  1,
  '{
    "avg": 86.8,
    "peak": 31743,
    "min": 0,
    "rms": 1504.4,
    "temperature_c": 24.5
  }'::jsonb
);

-- Optional: 3 quick payloads to verify multiple cards update.
insert into data (zone_id, sensor_data)
values
(
  1,
  '{"avg": 80.2, "peak": 29010, "min": 0, "rms": 1402.1, "temperature_c": 24.3}'::jsonb
),
(
  2,
  '{"avg": 55.0, "peak": 18012, "min": 0, "rms": 620.5, "temperature_c": 23.8}'::jsonb
),
(
  3,
  '{"avg": 96.4, "peak": 32500, "min": 0, "rms": 1790.9, "temperature_c": 25.0}'::jsonb
);
