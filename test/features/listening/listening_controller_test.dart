import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metarix/data/local_metarix_gateway.dart';
import 'package:metarix/features/listening/application/listening_controller.dart';
import 'package:metarix/features/listening/domain/listening_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'controller snapshot tracks listening signal summary from persisted mentions',
    () async {
      SharedPreferences.setMockInitialValues({});
      final gateway = await LocalMetarixGateway.bootstrap();
      final controller = ListeningController(gateway, gateway);
      final mention = gateway.snapshot.mentions.firstWhere(
        (entry) => entry.id == 'mention-1',
      );

      expect(
        controller.snapshot
            .signalSummaryFor('query-competitor')
            .mentionWatch
            ?.actionQueueCount,
        1,
      );

      await controller.routeMention(mention, InsightAction.observe);

      expect(
        controller.snapshot
            .signalSummaryFor('query-competitor')
            .mentionWatch
            ?.actionQueueCount,
        0,
      );
    },
  );
}
