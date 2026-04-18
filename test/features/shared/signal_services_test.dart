import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metarix/data/local_metarix_gateway.dart';
import 'package:metarix/features/shared/application/analytics_signal_service.dart';
import 'package:metarix/features/shared/application/listening_signal_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'analytics signal summary reads persisted report metrics and linked content units',
    () async {
      SharedPreferences.setMockInitialValues({});
      final gateway = await LocalMetarixGateway.bootstrap();
      final service = AnalyticsSignalService(gateway);

      final summary = service.signalForPeriod('period-april');

      expect(summary.engagement?.totalEngagements, 17900);
      expect(summary.engagement?.topChannelLabel, 'Instagram');
      expect(summary.topContentUnits.first.title, 'Trail tip reel');
      expect(summary.sentimentBucket?.label, 'Positive');
    },
  );

  test(
    'listening signal summary reads persisted mentions and watch records',
    () async {
      SharedPreferences.setMockInitialValues({});
      final gateway = await LocalMetarixGateway.bootstrap();
      final service = ListeningSignalService(gateway);

      final summary = service.signalForQuery('query-competitor');

      expect(summary.mentionWatch?.mentionCount, 1);
      expect(summary.mentionWatch?.spikeCount, 1);
      expect(summary.mentionWatch?.competitorWatchCount, 2);
      expect(summary.sentimentBucket?.label, 'Negative');
    },
  );
}
