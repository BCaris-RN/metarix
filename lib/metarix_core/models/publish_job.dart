import 'model_types.dart';

class PublishJob {
  const PublishJob({
    required this.publishJobId,
    required this.contentId,
    required this.platform,
    required this.accountId,
    required this.scheduledAt,
    required this.executionStatus,
    required this.remotePostId,
    required this.attemptCount,
    required this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });

  final String publishJobId;
  final String contentId;
  final SocialPlatform platform;
  final String accountId;
  final DateTime scheduledAt;
  final PublishExecutionStatus executionStatus;
  final String? remotePostId;
  final int attemptCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;

  static const Map<PublishExecutionStatus, Set<PublishExecutionStatus>>
  _allowedTransitions = {
    PublishExecutionStatus.queued: {
      PublishExecutionStatus.running,
      PublishExecutionStatus.failed,
      PublishExecutionStatus.canceled,
    },
    PublishExecutionStatus.running: {
      PublishExecutionStatus.succeeded,
      PublishExecutionStatus.failed,
    },
    PublishExecutionStatus.failed: {
      PublishExecutionStatus.queued,
      PublishExecutionStatus.canceled,
    },
    PublishExecutionStatus.succeeded: {},
    PublishExecutionStatus.canceled: {},
  };

  bool canTransitionTo(PublishExecutionStatus nextStatus) =>
      _allowedTransitions[executionStatus]!.contains(nextStatus);

  PublishJob transitionTo(
    PublishExecutionStatus nextStatus, {
    DateTime? occurredAt,
    String? remotePostId,
    String? lastError,
  }) {
    if (!canTransitionTo(nextStatus)) {
      throw StateError('Cannot transition $executionStatus to $nextStatus');
    }

    final transitionTime = occurredAt ?? updatedAt;
    return copyWith(
      executionStatus: nextStatus,
      updatedAt: transitionTime,
      remotePostId: remotePostId ?? this.remotePostId,
      lastError: nextStatus == PublishExecutionStatus.failed
          ? (lastError ?? this.lastError)
          : this.lastError,
      clearLastError: nextStatus == PublishExecutionStatus.queued,
      attemptCount: nextStatus == PublishExecutionStatus.running
          ? attemptCount + 1
          : attemptCount,
    );
  }

  PublishJob copyWith({
    String? publishJobId,
    String? contentId,
    SocialPlatform? platform,
    String? accountId,
    DateTime? scheduledAt,
    PublishExecutionStatus? executionStatus,
    String? remotePostId,
    bool clearRemotePostId = false,
    int? attemptCount,
    String? lastError,
    bool clearLastError = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PublishJob(
      publishJobId: publishJobId ?? this.publishJobId,
      contentId: contentId ?? this.contentId,
      platform: platform ?? this.platform,
      accountId: accountId ?? this.accountId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      executionStatus: executionStatus ?? this.executionStatus,
      remotePostId: clearRemotePostId
          ? null
          : remotePostId ?? this.remotePostId,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: clearLastError ? null : lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'publishJobId': publishJobId,
    'contentId': contentId,
    'platform': platform.name,
    'accountId': accountId,
    'scheduledAt': scheduledAt.toIso8601String(),
    'executionStatus': executionStatus.name,
    'remotePostId': remotePostId,
    'attemptCount': attemptCount,
    'lastError': lastError,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory PublishJob.fromJson(Map<String, dynamic> json) => PublishJob(
    publishJobId: json['publishJobId'] as String,
    contentId: json['contentId'] as String,
    platform: SocialPlatformX.fromName(json['platform'] as String),
    accountId: json['accountId'] as String,
    scheduledAt: DateTime.parse(json['scheduledAt'] as String),
    executionStatus: PublishExecutionStatusX.fromName(
      json['executionStatus'] as String,
    ),
    remotePostId: json['remotePostId'] as String?,
    attemptCount: json['attemptCount'] as int,
    lastError: json['lastError'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}
