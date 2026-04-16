import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metarix/data/local_metarix_gateway.dart';
import 'package:metarix/features/planning/application/planning_controller.dart';
import 'package:metarix/features/planning/domain/planning_models.dart';
import 'package:metarix/features/shared/domain/core_models.dart';
import 'package:metarix/features/workflow/domain/workflow_models.dart';
import 'package:metarix/runtime/activity/activity_event_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('campaigns and drafts keep real linkage', () async {
    SharedPreferences.setMockInitialValues({});
    final gateway = await LocalMetarixGateway.bootstrap();
    final controller = PlanningController(gateway, gateway, gateway);

    final campaign = Campaign(
      id: gateway.createId('campaign'),
      brandId: gateway.brand.id,
      name: 'Retail push',
      summary: 'A linked campaign',
      startDate: DateTime(2026, 4, 20),
      endDate: DateTime(2026, 5, 1),
      channels: const [SocialChannel.linkedin],
      contentPillarId: gateway.snapshot.contentPillars.first.id,
    );
    await controller.saveCampaign(campaign);

    final draft = PostDraft(
      id: gateway.createId('draft'),
      campaignId: campaign.id,
      title: 'Linked draft',
      targetNetwork: SocialChannel.linkedin,
      contentPillarId: gateway.snapshot.contentPillars.first.id,
      copy: 'Real linkage',
      assetRefs: const [],
      plannedPublishAt: DateTime(2026, 4, 22, 9),
      currentState: ContentState.draft,
      requiredApproval: ApprovalRequirement.managerRequired,
      evidenceCodes: const ['draft_snapshot'],
    );
    await controller.saveDraft(draft);

    expect(controller.campaigns.any((entry) => entry.id == campaign.id), isTrue);
    expect(controller.drafts.any((entry) => entry.campaignId == campaign.id), isTrue);
    expect(
      gateway.viewActivityEvents(
        workspaceId: gateway.workspace.id,
        objectType: ActivityObjectType.campaign,
        objectId: campaign.id,
      ).any((event) => event.eventType == ActivityEventType.created),
      isTrue,
    );
    expect(
      gateway.viewActivityEvents(
        workspaceId: gateway.workspace.id,
        objectType: ActivityObjectType.draft,
        objectId: draft.id,
      ).any((event) => event.eventType == ActivityEventType.created),
      isTrue,
    );
  });
}
