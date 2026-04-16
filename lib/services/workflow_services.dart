import '../features/schedule/domain/schedule_models.dart';
import '../features/shared/domain/core_models.dart';
import '../features/workflow/domain/workflow_models.dart';
import 'caris_policy_service.dart';

class ApprovalEvaluation {
  const ApprovalEvaluation({
    required this.requirement,
    required this.satisfied,
  });

  final ApprovalRequirement requirement;
  final bool satisfied;
}

class PublishPostureResult {
  const PublishPostureResult({
    required this.posture,
    required this.approvalRequirement,
    required this.approvalSatisfied,
    required this.channelSupportsSchedule,
    required this.channelSupportsPublish,
    required this.denialReasons,
  });

  final PublishPosture posture;
  final ApprovalRequirement approvalRequirement;
  final bool approvalSatisfied;
  final bool channelSupportsSchedule;
  final bool channelSupportsPublish;
  final List<DenialReason> denialReasons;
}

class ScheduleValidator {
  const ScheduleValidator(this._policies);

  final CarisPolicyBundle _policies;

  List<DenialReason> validate(PostDraft draft) {
    final reasons = <DenialReason>[];
    if (!_policies.supports(draft.targetNetwork, 'schedule_supported')) {
      reasons.add(
        DenialReason(
          code: 'schedule_unsupported',
          message: '${draft.targetNetwork.label} does not support scheduling.',
        ),
      );
    }
    if (draft.plannedPublishAt == null) {
      reasons.add(
        const DenialReason(
          code: 'schedule_missing_time',
          message: 'A planned publish time is required before scheduling.',
        ),
      );
    }
    return reasons;
  }
}

class ApprovalEvaluator {
  const ApprovalEvaluator(this._policies);

  final CarisPolicyBundle _policies;

  ApprovalEvaluation evaluate(
    PostDraft draft,
    List<ApprovalRecord> approvals,
  ) {
    final requirement = _policies.approvalRequirementFor(
      draft.targetNetwork,
      'publish_attempt',
    );
    final satisfied = approvals.any(
      (record) =>
          record.draftId == draft.id &&
          record.approved &&
          _satisfiesRequirement(record.requirement, requirement),
    );
    return ApprovalEvaluation(requirement: requirement, satisfied: satisfied);
  }

  bool _satisfiesRequirement(
    ApprovalRequirement actual,
    ApprovalRequirement required,
  ) {
    const ranking = {
      ApprovalRequirement.none: 0,
      ApprovalRequirement.managerRequired: 1,
      ApprovalRequirement.marketingLeadRequired: 2,
    };
    return ranking[actual]! >= ranking[required]!;
  }
}

class PublishPostureEvaluator {
  const PublishPostureEvaluator(
    this._policies,
    this._approvalEvaluator,
    this._scheduleValidator,
  );

  final CarisPolicyBundle _policies;
  final ApprovalEvaluator _approvalEvaluator;
  final ScheduleValidator _scheduleValidator;

  PublishPostureResult evaluate({
    required PostDraft draft,
    required List<ApprovalRecord> approvals,
    required ScheduleRecord? schedule,
  }) {
    final approval = _approvalEvaluator.evaluate(draft, approvals);
    final scheduleSupported =
        _policies.supports(draft.targetNetwork, 'schedule_supported');
    final publishSupported =
        _policies.supports(draft.targetNetwork, 'publish_supported');
    final reasons = <DenialReason>[];

    if (schedule != null) {
      reasons.addAll(_scheduleValidator.validate(draft));
    }

    if (!approval.satisfied &&
        (draft.currentState == ContentState.scheduled || schedule != null)) {
      reasons.add(
        DenialReason(
          code: 'approval_missing',
          message:
              '${approval.requirement.label} has not been satisfied for this draft.',
        ),
      );
    }

    final requiredEvidence = _policies.evidenceFor('publish_eligibility');
    for (final evidenceCode in requiredEvidence) {
      if (!draft.evidenceCodes.contains(evidenceCode)) {
        reasons.add(
          DenialReason(
            code: 'evidence_$evidenceCode',
            message: 'Missing required evidence: $evidenceCode.',
          ),
        );
      }
    }

    if (schedule != null && !publishSupported) {
      reasons.add(
        DenialReason(
          code: 'publish_unsupported',
          message: '${draft.targetNetwork.label} does not support publish attempts.',
        ),
      );
    }

    final posture = switch (draft.currentState) {
      ContentState.draft || ContentState.changesRequested => PublishPosture.notReady,
      ContentState.inReview => PublishPosture.readyForReview,
      ContentState.approved when schedule == null => PublishPosture.approved,
      ContentState.scheduled when reasons.isEmpty => PublishPosture.publishEligible,
      ContentState.scheduled => PublishPosture.publishDenied,
      _ when schedule != null && reasons.isEmpty => PublishPosture.publishEligible,
      _ when schedule != null => PublishPosture.publishDenied,
      _ => PublishPosture.notReady,
    };

    return PublishPostureResult(
      posture: posture,
      approvalRequirement: approval.requirement,
      approvalSatisfied: approval.satisfied,
      channelSupportsSchedule: scheduleSupported,
      channelSupportsPublish: publishSupported,
      denialReasons: reasons,
    );
  }
}
