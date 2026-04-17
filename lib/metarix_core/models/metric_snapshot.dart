import 'model_types.dart';

class MetricSnapshot {
  const MetricSnapshot({
    required this.snapshotId,
    required this.platform,
    required this.accountId,
    required this.contentId,
    required this.periodStart,
    required this.periodEnd,
    required this.impressions,
    required this.reach,
    required this.engagements,
    required this.clicks,
    required this.followerDelta,
    required this.videoViews,
    required this.saves,
    required this.shares,
    required this.comments,
    required this.likes,
  });

  final String snapshotId;
  final SocialPlatform platform;
  final String accountId;
  final String? contentId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int impressions;
  final int reach;
  final int engagements;
  final int clicks;
  final int followerDelta;
  final int videoViews;
  final int saves;
  final int shares;
  final int comments;
  final int likes;

  MetricSnapshot copyWith({
    String? snapshotId,
    SocialPlatform? platform,
    String? accountId,
    String? contentId,
    bool clearContentId = false,
    DateTime? periodStart,
    DateTime? periodEnd,
    int? impressions,
    int? reach,
    int? engagements,
    int? clicks,
    int? followerDelta,
    int? videoViews,
    int? saves,
    int? shares,
    int? comments,
    int? likes,
  }) {
    return MetricSnapshot(
      snapshotId: snapshotId ?? this.snapshotId,
      platform: platform ?? this.platform,
      accountId: accountId ?? this.accountId,
      contentId: clearContentId ? null : contentId ?? this.contentId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      impressions: impressions ?? this.impressions,
      reach: reach ?? this.reach,
      engagements: engagements ?? this.engagements,
      clicks: clicks ?? this.clicks,
      followerDelta: followerDelta ?? this.followerDelta,
      videoViews: videoViews ?? this.videoViews,
      saves: saves ?? this.saves,
      shares: shares ?? this.shares,
      comments: comments ?? this.comments,
      likes: likes ?? this.likes,
    );
  }

  Map<String, dynamic> toJson() => {
    'snapshotId': snapshotId,
    'platform': platform.name,
    'accountId': accountId,
    'contentId': contentId,
    'periodStart': periodStart.toIso8601String(),
    'periodEnd': periodEnd.toIso8601String(),
    'impressions': impressions,
    'reach': reach,
    'engagements': engagements,
    'clicks': clicks,
    'followerDelta': followerDelta,
    'videoViews': videoViews,
    'saves': saves,
    'shares': shares,
    'comments': comments,
    'likes': likes,
  };

  factory MetricSnapshot.fromJson(Map<String, dynamic> json) => MetricSnapshot(
    snapshotId: json['snapshotId'] as String,
    platform: SocialPlatformX.fromName(json['platform'] as String),
    accountId: json['accountId'] as String,
    contentId: json['contentId'] as String?,
    periodStart: DateTime.parse(json['periodStart'] as String),
    periodEnd: DateTime.parse(json['periodEnd'] as String),
    impressions: json['impressions'] as int,
    reach: json['reach'] as int,
    engagements: json['engagements'] as int,
    clicks: json['clicks'] as int,
    followerDelta: json['followerDelta'] as int,
    videoViews: json['videoViews'] as int,
    saves: json['saves'] as int,
    shares: json['shares'] as int,
    comments: json['comments'] as int,
    likes: json['likes'] as int,
  );
}
