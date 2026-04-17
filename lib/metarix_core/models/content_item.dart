import 'model_types.dart';

class ContentItem {
  const ContentItem({
    required this.contentId,
    required this.title,
    required this.campaign,
    required this.pillar,
    required this.objective,
    required this.status,
    required this.targetPlatforms,
    required this.assetIds,
    required this.captionVariantIds,
    required this.scheduledAt,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String contentId;
  final String title;
  final String campaign;
  final String pillar;
  final String objective;
  final ContentStatus status;
  final List<SocialPlatform> targetPlatforms;
  final List<String> assetIds;
  final List<String> captionVariantIds;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  static const Map<ContentStatus, Set<ContentStatus>> _allowedTransitions = {
    ContentStatus.draft: {ContentStatus.approved, ContentStatus.archived},
    ContentStatus.approved: {
      ContentStatus.scheduled,
      ContentStatus.failed,
      ContentStatus.archived,
    },
    ContentStatus.scheduled: {
      ContentStatus.published,
      ContentStatus.failed,
      ContentStatus.archived,
    },
    ContentStatus.published: {ContentStatus.archived},
    ContentStatus.failed: {ContentStatus.draft, ContentStatus.archived},
    ContentStatus.archived: {},
  };

  bool canTransitionTo(ContentStatus nextStatus) =>
      _allowedTransitions[status]!.contains(nextStatus);

  ContentItem transitionTo(ContentStatus nextStatus, {DateTime? occurredAt}) {
    if (!canTransitionTo(nextStatus)) {
      throw StateError('Cannot transition $status to $nextStatus');
    }

    final transitionTime = occurredAt ?? updatedAt;
    return copyWith(
      status: nextStatus,
      updatedAt: transitionTime,
      scheduledAt: nextStatus == ContentStatus.scheduled
          ? scheduledAt ?? transitionTime
          : scheduledAt,
      publishedAt: nextStatus == ContentStatus.published
          ? publishedAt ?? transitionTime
          : publishedAt,
    );
  }

  ContentItem copyWith({
    String? contentId,
    String? title,
    String? campaign,
    String? pillar,
    String? objective,
    ContentStatus? status,
    List<SocialPlatform>? targetPlatforms,
    List<String>? assetIds,
    List<String>? captionVariantIds,
    DateTime? scheduledAt,
    bool clearScheduledAt = false,
    DateTime? publishedAt,
    bool clearPublishedAt = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContentItem(
      contentId: contentId ?? this.contentId,
      title: title ?? this.title,
      campaign: campaign ?? this.campaign,
      pillar: pillar ?? this.pillar,
      objective: objective ?? this.objective,
      status: status ?? this.status,
      targetPlatforms: targetPlatforms ?? this.targetPlatforms,
      assetIds: assetIds ?? this.assetIds,
      captionVariantIds: captionVariantIds ?? this.captionVariantIds,
      scheduledAt: clearScheduledAt ? null : scheduledAt ?? this.scheduledAt,
      publishedAt: clearPublishedAt ? null : publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'contentId': contentId,
    'title': title,
    'campaign': campaign,
    'pillar': pillar,
    'objective': objective,
    'status': status.name,
    'targetPlatforms': targetPlatforms
        .map((platform) => platform.name)
        .toList(),
    'assetIds': assetIds,
    'captionVariantIds': captionVariantIds,
    'scheduledAt': scheduledAt?.toIso8601String(),
    'publishedAt': publishedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ContentItem.fromJson(Map<String, dynamic> json) => ContentItem(
    contentId: json['contentId'] as String,
    title: json['title'] as String,
    campaign: json['campaign'] as String,
    pillar: json['pillar'] as String,
    objective: json['objective'] as String,
    status: ContentStatusX.fromName(json['status'] as String),
    targetPlatforms: (json['targetPlatforms'] as List<dynamic>)
        .cast<String>()
        .map(SocialPlatformX.fromName)
        .toList(),
    assetIds: (json['assetIds'] as List<dynamic>).cast<String>().toList(),
    captionVariantIds: (json['captionVariantIds'] as List<dynamic>)
        .cast<String>()
        .toList(),
    scheduledAt: json['scheduledAt'] == null
        ? null
        : DateTime.parse(json['scheduledAt'] as String),
    publishedAt: json['publishedAt'] == null
        ? null
        : DateTime.parse(json['publishedAt'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}
