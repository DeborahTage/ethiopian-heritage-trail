# Mobile Architecture (Flutter)

## State Management
We utilize **Riverpod / BLoC** (transitioning towards isolated BLoC) for reactive State Management. 
Hive provides the persistent Offline-First capabilities so heritage content is readable even deep in natural reserves without internet.

## Code Layout
- `/lib/core`: Defines API contracts, offline Hive boxes, layout shell.
- `/lib/features/scanner`: Uses `mobile_scanner` capturing code chunks.
- `/lib/features/reward`: Multimedia unlock logic handling the Post-Scan API response.

## Integration Testing
Located inside `/integration_test/scanner_flow_test.dart`.
Run with: `flutter test integration_test` or utilizing firebase test lab natively. Ensure it is piped to mock-driven states unless targeting staging servers.
