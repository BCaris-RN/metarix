import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metarix/data/local_metarix_gateway.dart';
import 'package:metarix/services/signal_summary_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'analytics signal summary reads persisted report metrics and linked content units',
    () async {
      SharedPreferences.setMockInitialValues({});
      final gateway = await LocalMetarixGateway.bootstrap();
      const service = SignalSummaryService();

      final summary = service.buildReportSignalSummaries(
        gateway.snapshot,
      )['period-april']!;

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
      const service = SignalSummaryService();

      final summary = service.buildListeningSignalSummary(
        gateway.snapshot,
        queryId: 'query-competitor',
      );

      expect(summary.mentionWatch?.mentionCount, 1);
      expect(summary.mentionWatch?.spikeCount, 1);
      expect(summary.mentionWatch?.competitorWatchCount, 2);
      expect(summary.sentimentBucket?.label, 'Negative');
    },
  );

  test(
    'repository snapshots reuse the shared signal summary service',
    () async {
      SharedPreferences.setMockInitialValues({});
      final gateway = await LocalMetarixGateway.bootstrap();
      const service = SignalSummaryService();

      final reportSnapshot = await gateway.loadReportData();
      final reportSignals = service.buildReportSignalSummaries(
        gateway.snapshot,
      );
      final listeningSnapshot = await gateway.loadListeningSnapshot();
      final listeningSignals = service.buildListeningSignalSummaries(
        gateway.snapshot,
      );

      expect(
        reportSnapshot
            .signalSummaryFor('period-april')
            .engagement
            ?.totalEngagements,
        reportSignals['period-april']?.engagement?.totalEngagements,
      );
      expect(
        reportSnapshot.topPostPlaceholder,
        reportSignals['period-april']?.topContentUnits.first.title,
      );
      expect(
        listeningSnapshot.workspaceSignalSummary.mentionWatch?.mentionCount,
        listeningSignals.workspaceSignalSummary.mentionWatch?.mentionCount,
      );
      expect(
        listeningSnapshot
            .signalSummaryFor('query-competitor')
            .mentionWatch
            ?.actionQueueCount,
        listeningSignals
            .querySignalSummaries['query-competitor']
            ?.mentionWatch
            ?.actionQueueCount,
      );
    },
  );
}
