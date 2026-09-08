-- ============================================================
-- LUMISENSE · AI Source Detection + Custom Model Upload
-- Run this AFTER lumisense_schema.sql and lumisense_schema_additions.sql
-- ============================================================


-- ============================================================
-- TABLE: noise_source_predictions
-- One row written per fused-inference cycle (whenever fresh
-- readings from all 3 zones are available at once). Powers the
-- "Noise Detected / Likely Source / Confidence" dashboard card.
-- ============================================================
create table if not exists noise_source_predictions (
  id             bigint generated always as identity primary key,
  noise_detected boolean not null,
  likely_source  text,                 -- zone_name, or null when noise_detected = false
  confidence     float not null,       -- 0.0 - 1.0
  cs_rms         float,                -- snapshot of each zone's RMS at prediction time
  eng_rms        float,                -- (kept for audit / debugging, not required by the UI)
  it_rms         float,
  created_at     timestamptz default now()
);

create index if not exists idx_noise_source_predictions_time
  on noise_source_predictions(created_at desc);

alter table noise_source_predictions enable row level security;
create policy "allow_all_noise_source_predictions"
  on noise_source_predictions for all
  to anon, authenticated
  using (true)
  with check (true);

-- Enable Realtime so the Dashboard card updates live
alter publication supabase_realtime add table noise_source_predictions;


-- ============================================================
-- TABLE: ml_model_versions
-- One row per model type, pointing at whichever file is
-- currently "live" in the ml-models Storage bucket. Uploading a
-- new model (Settings > AI Model Management) upserts this row;
-- the app checks it on startup and downloads the new file if the
-- version_tag has changed, without needing a rebuild.
-- ============================================================
create table if not exists ml_model_versions (
  model_type   text primary key,     -- 'sound_type' | 'noise_source'
  storage_path text not null,        -- path to the .tflite file inside the bucket
  labels_path  text not null,
  scaler_path  text not null,
  version_tag  text not null,        -- unique per upload, shown in the Settings UI
  uploaded_by  text,                 -- username, for the audit trail
  updated_at   timestamptz default now()
);

alter table ml_model_versions enable row level security;
create policy "allow_all_ml_model_versions"
  on ml_model_versions for all
  to anon, authenticated
  using (true)
  with check (true);

alter publication supabase_realtime add table ml_model_versions;


-- ============================================================
-- MANUAL STEP — run once via the Supabase Dashboard
-- (Storage buckets can't be created from plain SQL)
-- ============================================================
-- 1. Go to Storage in the Supabase Dashboard.
-- 2. Create a new bucket named exactly:  ml-models
-- 3. It can be Private — the app already authenticates before
--    calling Storage, same as the existing "avatars" bucket.
