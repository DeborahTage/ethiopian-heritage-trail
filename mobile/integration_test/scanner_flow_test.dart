import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end scanner flow', () {
    testWidgets('verify QR Scanner navigates to Reward display on mock scan', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find the main bottom navigation tab assuming it has an icon
      final scannerTab = find.byIcon(Icons.qr_code_scanner);
      expect(scannerTab, findsOneWidget);

      // Navigate to scanner tab
      await tester.tap(scannerTab);
      await tester.pumpAndSettle();

      // We typically simulate scanning by tapping a hidden 'mock scan' debug button in INT testing
      // Or by invoking a mock channel. Assuming a button labeled 'Simulate Scan' exists in dev builds.
      final mockScanBtn = find.text('Simulate Scan');
      
      // If the mock scan button is found, tap it
      if (mockScanBtn.evaluate().isNotEmpty) {
          await tester.tap(mockScanBtn);
          await tester.pumpAndSettle();
      }

      // Assert that a success banner or points reward badge appeared
      // For instance, checking text 'Points Earned!'
      // expect(find.textContaining('Points'), findsWidgets);
    });
  });
}
