import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metarix/app/metarix_app.dart';
import 'package:metarix/core/app_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shell renders strategy workspace', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final services = await AppServices.bootstrap();
    final reportSnapshot = services.reportController.snapshot;
    final analyticsSignal = reportSnapshot.signalSummaryFor(
      reportSnapshot.activePeriodId,
    );
    final listeningSignal =
        services.listeningController.snapshot.workspaceSignalSummary;
    final engagementSummary =
        '${analyticsSignal.engagement!.totalEngagements} engagements across ${analyticsSignal.engagement!.topChannelLabel}';
    final mentionWatch =
        '${listeningSignal.mentionWatch!.mentionCount} mentions / ${listeningSignal.mentionWatch!.spikeCount} spikes';

    await tester.pumpWidget(MetarixApp(services: services));
    await tester.pumpAndSettle();

    expect(find.text('MetaRix'), findsOneWidget);
    expect(find.text('Strategy Workspace'), findsOneWidget);
    expect(find.text('Workspace signal'), findsOneWidget);
    expect(find.text(engagementSummary), findsOneWidget);
    expect(find.text(reportSnapshot.topPostPlaceholder), findsOneWidget);
    expect(find.text(mentionWatch), findsOneWidget);
    expect(find.text('Planning'), findsWidgets);
    expect(find.text('Activity'), findsWidgets);
  });
}
