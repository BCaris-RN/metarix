import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metarix/data/local_metarix_gateway.dart';
import 'package:metarix/features/activity/application/activity_controller.dart';
import 'package:metarix/runtime/activity/activity_event_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('timeline filters by object type and date range', () async {
    SharedPreferences.setMockInitialValues({});
    final gateway = await LocalMetarixGateway.bootstrap();
    final controller = ActivityController(gateway);

    final campaignEvents = controller.workspaceEvents(
      objectType: ActivityObjectType.campaign,
    );
    final recentEvents = controller.workspaceEvents(
      from: DateTime(2026, 4, 15),
      to: DateTime(2026, 4, 30, 23, 59),
    );

    expect(campaignEvents, isNotEmpty);
    expect(campaignEvents.every((event) => event.objectType == ActivityObjectType.campaign), isTrue);
    expect(recentEvents.any((event) => event.objectId == 'period-april'), isTrue);
    expect(recentEvents.any((event) => event.objectId == 'mention-1'), isFalse);
  });
}
