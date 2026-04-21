import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metarix/app/metarix_scope.dart';
import 'package:metarix/core/app_services.dart';
import 'package:metarix/features/admin/presentation/admin_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LinkedIn shows not configured when env vars are absent', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final services = await AppServices.bootstrap();

    await tester.pumpWidget(
      MaterialApp(
        home: MetarixScope(
          services: services,
          child: const Scaffold(body: AdminScreen()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Connector status'), findsOneWidget);
    expect(find.text('LinkedIn'), findsOneWidget);
    expect(find.text('Not configured'), findsOneWidget);
    expect(find.text('Client ID missing'), findsOneWidget);
    expect(find.text('Redirect URI missing'), findsOneWidget);
    expect(find.text('Connected'), findsNothing);
    final startButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Start LinkedIn Connect'),
    );
    expect(startButton.onPressed, isNull);

    services.dispose();
  });
}
