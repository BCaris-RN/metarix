import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metarix/data/local_metarix_gateway.dart';
import 'package:metarix/features/reports/report_controller.dart';
import 'package:metarix/features/reports/report_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'legacy report assembly reads the authoritative report snapshot',
    () async {
      SharedPreferences.setMockInitialValues({});
      final gateway = await LocalMetarixGateway.bootstrap();
      final snapshot = gateway.loadReportDataSync();
      final controller = ReportController(snapshot: snapshot);
      final signalSummary = snapshot.signalSummaryFor(snapshot.activePeriodId);

      expect(
        controller.assembly.sectionOrder.first,
        ReportSection.successSnapshot,
      );
      expect(
        controller.assembly.sectionOrder.last,
        ReportSection.futureStrategy,
      );
      expect(
        controller.assembly.successSnapshot.totalEngagements,
        signalSummary.engagement?.totalEngagements,
      );
      expect(
        controller.assembly.platformSummaries.first.topContent?.contentId,
        signalSummary.topContentUnits.first.title,
      );

      await controller.exportReport(ReportExportFormat.ppt);

      expect(controller.exportStatus, contains('stubbed'));
      expect(controller.exportStatus, contains('PPT'));
    },
  );
}
