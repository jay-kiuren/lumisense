# Safe Parallel Tasks While TensorFlow Installs

This checklist helps you keep moving without touching the active Python install flow.

## Do now (safe)

1. Keep Flutter healthy:
   - Run `flutter analyze`
   - Fix only Dart/UI issues
2. Validate Supabase UI flow:
   - Open `supabase/fake_payload.sql`
   - Run it in Supabase SQL Editor
   - Confirm zone cards/action widgets update in the app
3. Prepare AI handoff:
   - Keep `ai_training/training_data.csv` ready for real sensor rows
   - Do not edit the active `venv` while install is running

## Avoid until install completes

- `ai_training/venv/` contents
- `pip install` commands in the same environment
- interrupting terminals currently doing package downloads

## After install succeeds

1. Activate env: `cd ai_training && source venv/bin/activate`
2. Confirm TensorFlow: `pip show tensorflow`
3. Train model: `python train_sound_model.py`
4. Copy outputs to `assets/models/`:
   - `sound_classifier.tflite`
   - `class_labels.txt`
   - `scaler_params.txt`
5. Run `flutter run` and verify live classification labels appear.
