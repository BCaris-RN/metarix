import '../../shared/domain/core_models.dart';

enum ContentState {
  draft,
  inReview,
  changesRequested,
  approved,
  scheduled,
  publishEligible,
  publishDenied,
  published,
  archived,
}

extension ContentStateX on ContentState {
  String get label => switch (this) {
        ContentState.draft => 'Draft',
        ContentState.inReview => 'In review',
        ContentState.changesRequested => 'Changes requested',
        ContentState.approved => 'Approved',
        ContentState.scheduled => 'Scheduled',
        ContentState.publishEligible => 'Publish eligible',
        ContentState.publishDenied => 'Publish denied',
        ContentState.published => 'Published',
        ContentState.archived => 'Archived',
      };

  static ContentState fromName(String value) =>
      ContentState.values.firstWhere((state) => state.name == value);
}

enum ApprovalRequirement {
  none,
  managerRequired,
  marketingLeadRequired,
}

extension ApprovalRequirementX on ApprovalRequirement {
  String get label => switch (this) {
        ApprovalRequirement.none => 'None',
        ApprovalRequirement.managerRequired => 'Manager required',
        ApprovalRequirement.marketingLeadRequired => 'Marketing lead required',
      };

  static ApprovalRequirement fromName(String value) =>
      ApprovalRequirement.values.firstWhere(
        (requirement) => requirement.name == value,
      );
}

class DenialReason {
  const DenialReason({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
      };

  factory DenialReason.fromJson(Map<String, dynamic> json) => DenialReason(
        code: json['code'] as String,
        message: json['message'] as String,
      );
}

class ApprovalRecord {
  const ApprovalRecord({
    required this.id,
    required this.draftId,
    required this.requirement,
    required this.reviewerRole,
    required this.approved,
    required this.note,
    required this.decidedAt,
  });

  final String id;
  final String draftId;
  final ApprovalRequirement requirement;
  final String reviewerRole;
  final bool approved;
  final String note;
  final DateTime decidedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'draftId': draftId,
        'requirement': requirement.name,
        'reviewerRole': reviewerRole,
        'approved': approved,
        'note': note,
        'decidedAt': decidedAt.toIso8601String(),
      };

  factory ApprovalRecord.fromJson(Map<String, dynamic> json) => ApprovalRecord(
        id: json['id'] as String,
        draftId: json['draftId'] as String,
        requirement: ApprovalRequirementX.fromName(
          json['requirement'] as String,
        ),
        reviewerRole: json['reviewerRole'] as String,
        approved: json['approved'] as bool,
        note: json['note'] as String,
        decidedAt: DateTime.parse(json['decidedAt'] as String),
      );
}

class PostDraft {
  const PostDraft({
    required this.id,
    required this.campaignId,
    required this.title,
    required this.targetNetwork,
    required this.contentPillarId,
    required this.copy,
    required this.assetRefs,
    required this.plannedPublishAt,
    required this.currentState,
    required this.requiredApproval,
    required this.evidenceCodes,
  });

  final String id;
  final String campaignId;
  final String title;
  final SocialChannel targetNetwork;
  final String contentPillarId;
  final String copy;
  final List<AssetRef> assetRefs;
  final DateTime? plannedPublishAt;
  final ContentState currentState;
  final ApprovalRequirement requiredApproval;
  final List<String> evidenceCodes;

  PostDraft copyWith({
    String? id,
    String? campaignId,
    String? title,
    SocialChannel? targetNetwork,
    String? contentPillarId,
    String? copy,
    List<AssetRef>? assetRefs,
    DateTime? plannedPublishAt,
    bool clearPlannedPublishAt = false,
    ContentState? currentState,
    ApprovalRequirement? requiredApproval,
    List<String>? evidenceCodes,
  }) {
    return PostDraft(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      title: title ?? this.title,
      targetNetwork: targetNetwork ?? this.targetNetwork,
      contentPillarId: contentPillarId ?? this.contentPillarId,
      copy: copy ?? this.copy,
      assetRefs: assetRefs ?? this.assetRefs,
      plannedPublishAt:
          clearPlannedPublishAt ? null : plannedPublishAt ?? this.plannedPublishAt,
      currentState: currentState ?? this.currentState,
      requiredApproval: requiredApproval ?? this.requiredApproval,
      evidenceCodes: evidenceCodes ?? this.evidenceCodes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'campaignId': campaignId,
        'title': title,
        'targetNetwork': targetNetwork.name,
        'contentPillarId': contentPillarId,
        'copy': copy,
        'assetRefs': assetRefs.map((asset) => asset.toJson()).toList(),
        'plannedPublishAt': plannedPublishAt?.toIso8601String(),
        'currentState': currentState.name,
        'requiredApproval': requiredApproval.name,
        'evidenceCodes': evidenceCodes,
      };

  factory PostDraft.fromJson(Map<String, dynamic> json) => PostDraft(
        id: json['id'] as String,
        campaignId: json['campaignId'] as String,
        title: json['title'] as String,
        targetNetwork: SocialChannelX.fromName(json['targetNetwork'] as String),
        contentPillarId: json['contentPillarId'] as String,
        copy: json['copy'] as String,
        assetRefs: (json['assetRefs'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(AssetRef.fromJson)
            .toList(),
        plannedPublishAt: json['plannedPublishAt'] == null
            ? null
            : DateTime.parse(json['plannedPublishAt'] as String),
        currentState: ContentStateX.fromName(json['currentState'] as String),
        requiredApproval: ApprovalRequirementX.fromName(
          json['requiredApproval'] as String,
        ),
        evidenceCodes:
            (json['evidenceCodes'] as List<dynamic>).cast<String>().toList(),
      );
}
