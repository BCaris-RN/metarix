import 'package:flutter_test/flutter_test.dart';

import 'package:metarix/features/admin/domain/admin_models.dart';
import 'package:metarix/features/workflow/domain/workflow_models.dart';
import 'package:metarix/services/access_control_service.dart';

void main() {
  const service = AccessControlService();

  test('editor cannot approve content when approver role is required', () {
    final decision = service.canPerform(
      UserRole.editor,
      RuntimeAction.approveContent,
      approvalRequirement: ApprovalRequirement.marketingLeadRequired,
    );

    expect(decision.allowed, isFalse);
  });

  test('analyst can generate reports but cannot modify approval state', () {
    final reportDecision = service.canPerform(
      UserRole.analyst,
      RuntimeAction.generateReport,
    );
    final approvalDecision = service.canPerform(
      UserRole.analyst,
      RuntimeAction.approveContent,
      approvalRequirement: ApprovalRequirement.managerRequired,
    );

    expect(reportDecision.allowed, isTrue);
    expect(approvalDecision.allowed, isFalse);
  });

  test('owner and admin can manage members', () {
    expect(
      service.canPerform(UserRole.owner, RuntimeAction.manageMembers).allowed,
      isTrue,
    );
    expect(
      service.canPerform(UserRole.admin, RuntimeAction.manageMembers).allowed,
      isTrue,
    );
  });
}
