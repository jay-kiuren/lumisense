# Smart Library Monitoring (Desktop Skeleton)

Flutter desktop skeleton for the **Smart Library Monitoring System** with:

- Zone monitoring (`IT`, `CS`, `Engineering`)
- Real-time telemetry stream (mock for now)
- Alerts and analytics placeholders
- ML-ready contracts for future sound classification integration

## Run

```bash
flutter pub get
flutter run -d linux
```

## Project Structure

- `lib/app` app shell, navigation, and theme
- `lib/core/domain` entities and repository contracts
- `lib/core/services/mock` mock real-time telemetry source
- `lib/features/*` feature pages for dashboard/zones/alerts/analytics/settings

## ML-Ready Notes

The app already includes a `MlInferenceRepository` contract so you can later add:

- Edge Impulse metadata sync
- Supported sound classes retrieval
- Future inference history and confidence-based UI
