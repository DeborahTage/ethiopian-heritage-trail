/// App configuration — reads from compile-time env or defaults to dev.
class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // Default to host LAN address so physical devices on same network can reach backend.
    // Replace with your machine IP if different.
    defaultValue: 'http://192.168.137.197:8080/api/v1',
  );

  // On a physical Android device, set the backend host explicitly.
  // Example:
  // flutter run -d <device-id> --dart-define=API_BASE_URL=http://192.168.137.197:8080/api/v1
  // or, after adb reverse tcp:8080 tcp:8080:
  // flutter run -d <device-id> --dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1
  static const String mapsApiKey = String.fromEnvironment('MAPS_API_KEY', defaultValue: '');

  // GPS geofence radius shown to user (server enforces its own per-landmark)
  static const double defaultProximityRadius = 500.0;

  // Retry config for Dio
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
}
