import 'package:flutter_test/flutter_test.dart';

import 'package:metarix/features/admin/domain/admin_models.dart';
import 'package:metarix/features/schedule/domain/schedule_models.dart';
import 'package:metarix/features/shared/domain/core_models.dart';
import 'package:metarix/features/workflow/domain/workflow_models.dart';
import 'package:metarix/services/caris_policy_service.dart';
import 'package:metarix/services/workflow_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PublishPostureEvaluator evaluator;
  late CarisPolicyBundle policies;

  setUpAll(() async {
    policies = await const CarisPolicyService().load();
    evaluator = PublishPostureEvaluator(
      policies,
      ApprovalEvaluator(policies),
      ScheduleValidator(policies),
    );
  });

  test('scheduled but not approved becomes publish_denied', () {
    final draft = _buildDraft(
      currentState: ContentState.scheduled,
      channel: SocialChannel.linkedin,
      evidenceCodes: policies.evidenceFor('publish_eligibility'),
    );
    final schedule = _buildSchedule();

    final result = evaluator.evaluate(
      draft: draft,
      approvals: const [],
      schedule: schedule,
    );

    expect(result.posture, PublishPosture.publishDenied);
    expect(result.denialReasons.any((entry) => entry.code == 'approval_missing'), isTrue);
  });

  test('approved but missing evidence becomes publish_denied', () {
    final draft = _buildDraft(
      currentState: ContentState.scheduled,
      channel: SocialChannel.linkedin,
      evidenceCodes: const ['draft_snapshot', 'approval_record'],
    );
    final schedule = _buildSchedule();
    final approval = ApprovalRecord(
      id: 'approval-1',
      draftId: draft.id,
      requirement: ApprovalRequirement.marketingLeadRequired,
      reviewerRole: UserRole.approver.name,
      approved: true,
      note: 'Approved',
      decidedAt: DateTime(2026, 4, 13),
    );

    final result = evaluator.evaluate(
      draft: draft,
      approvals: [approval],
      schedule: schedule,
    );

    expect(result.posture, PublishPosture.publishDenied);
    expect(
      result.denialReasons.any((entry) => entry.code.startsWith('evidence_')),
      isTrue,
    );
  });

  test('approved with required evidence and supported channel becomes publish_eligible', () {
    final draft = _buildDraft(
      currentState: ContentState.scheduled,
      channel: SocialChannel.linkedin,
      evidenceCodes: policies.evidenceFor('publish_eligibility'),
    );
    final schedule = _buildSchedule();
    final approval = ApprovalRecord(
      id: 'approval-2',
      draftId: draft.id,
      requirement: ApprovalRequirement.marketingLeadRequired,
      reviewerRole: UserRole.approver.name,
      approved: true,
      note: 'Approved',
      decidedAt: DateTime(2026, 4, 13),
    );

    final result = evaluator.evaluate(
      draft: draft,
      approvals: [approval],
      schedule: schedule,
    );

    expect(result.posture, PublishPosture.publishEligible);
    expect(result.denialReasons, isEmpty);
  });
}

PostDraft _buildDraft({
  required ContentState currentState,
  required SocialChannel channel,
  required List<String> evidenceCodes,
}) {
  return PostDraft(
    id: 'draft-1',
    campaignId: 'campaign-1',
    title: 'Draft',
    targetNetwork: channel,
    contentPillarId: 'pillar-1',
    copy: 'Sample copy',
    assetRefs: const [],
    plannedPublishAt: DateTime(2026, 4, 14, 10),
    currentState: currentState,
    requiredApproval: ApprovalRequirement.marketingLeadRequired,
    evidenceCodes: evidenceCodes,
  );
}

ScheduleRecord _buildSchedule() {
  return ScheduleRecord(
    id: 'schedule-1',
    draftId: 'draft-1',
    channel: SocialChannel.linkedin,
    scheduledAt: DateTime(2026, 4, 14, 10),
    denialReasons: const [],
  );
}
