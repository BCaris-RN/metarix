import 'package:flutter_test/flutter_test.dart';

import 'package:metarix/features/reports/report_controller.dart';
import 'package:metarix/features/reports/report_section.dart';

void main() {
  test(
    'controller exposes ordered report sections and stubbed export messaging',
    () async {
      final controller = ReportController();

      expect(
        controller.assembly.sectionOrder.first,
        ReportSection.successSnapshot,
      );
      expect(
        controller.assembly.sectionOrder.last,
        ReportSection.futureStrategy,
      );

      await controller.exportReport(ReportExportFormat.ppt);

      expect(controller.exportStatus, contains('stubbed'));
      expect(controller.exportStatus, contains('PPT'));
    },
  );
}
