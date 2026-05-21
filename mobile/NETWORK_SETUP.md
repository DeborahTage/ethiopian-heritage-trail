# Network Setup for Ethiopian Heritage Trail Mobile

- Computer IP address used: `192.168.137.197`
- Working baseUrl value: `http://192.168.137.197:8080/api/v1`
- Device type tested: physical Android device on same WiFi (intended)
- Cleartext enabled: `android:usesCleartextTraffic="true"` is present in `android/app/src/main/AndroidManifest.xml`
- Firewall rules applied: not modified in this session
- CORS origins added: backend already allows all origin patterns via `CorsConfiguration.setAllowedOriginPatterns(List.of("*"))`
- Date tested: 2026-05-18

## Notes
- The backend exposes the actuator health endpoint at `http://<COMPUTER_IP>:8080/actuator/health`, not `http://<COMPUTER_IP>:8080/api/actuator/health`.
- If using a physical device, ensure the phone and computer are on the same WiFi network and the device can reach `http://192.168.137.197:8080`.
- If the device cannot connect, verify the computer firewall and that the backend is listening on the LAN interface.
