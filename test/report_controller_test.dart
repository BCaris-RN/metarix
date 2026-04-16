import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metarix/data/local_metarix_gateway.dart';
import 'package:metarix/features/reports/application/report_controller.dart';
import 'package:metarix/runtime/activity/activity_event_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('report generation creates a report timeline event', () async {
    SharedPreferences.setMockInitialValues({});
    final gateway = await LocalMetarixGateway.bootstrap();
    final controller = ReportController(gateway, gateway);
    final periodId = gateway.snapshot.reportPeriods.first.id;

    await controller.generateReport(periodId);

    final events = gateway.viewActivityEvents(
      workspaceId: gateway.workspace.id,
      objectType: ActivityObjectType.report,
      objectId: periodId,
    );
    expect(
      events.any((event) => event.eventType == ActivityEventType.reportGenerated),
      isTrue,
    );
  });
}
