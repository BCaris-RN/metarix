import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metarix/data/local_metarix_gateway.dart';
import 'package:metarix/features/publish/application/publish_state_transition_service.dart';
import 'package:metarix/features/publish/domain/publish_models.dart';
import 'package:metarix/features/workflow/application/workflow_controller.dart';
import 'package:metarix/runtime/activity/activity_event_type.dart';
import 'package:metarix/services/access_control_service.dart';
import 'package:metarix/services/caris_policy_service.dart';
import 'package:metarix/services/workflow_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('publish denial creates a denial timeline event', () async {
    SharedPreferences.setMockInitialValues({});
    final gateway = await LocalMetarixGateway.bootstrap();
    final policies = await const CarisPolicyService().load();
    final controller = WorkflowController(
      gateway,
      gateway,
      gateway,
      gateway,
      gateway,
      const AccessControlService(),
      PublishPostureEvaluator(
        policies,
        ApprovalEvaluator(policies),
        ScheduleValidator(policies),
      ),
      const PublishStateTransitionService(),
    );

    final draft = gateway.snapshot.drafts.firstWhere(
      (entry) => entry.id == 'draft-community-post',
    );
    await controller.scheduleDraft(draft, DateTime(2026, 4, 20, 10));

    final events = gateway.viewActivityEvents(
      workspaceId: gateway.workspace.id,
      objectType: ActivityObjectType.draft,
      objectId: draft.id,
    );
    expect(
      events.any((event) => event.eventType == ActivityEventType.denied),
      isTrue,
    );
    expect(
      gateway.snapshot.scheduledPosts
          .firstWhere((entry) => entry.draftId == draft.id)
          .status,
      PublishRecordStatus.blocked,
    );
  });
}
