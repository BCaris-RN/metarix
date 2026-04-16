import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metarix/app/metarix_app.dart';
import 'package:metarix/core/app_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shell renders strategy workspace', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final services = await AppServices.bootstrap();

    await tester.pumpWidget(MetarixApp(services: services));
    await tester.pumpAndSettle();

    expect(find.text('MetaRix'), findsOneWidget);
    expect(find.text('Strategy Workspace'), findsOneWidget);
    expect(find.text('Planning'), findsWidgets);
    expect(find.text('Activity'), findsWidgets);
  });
}
