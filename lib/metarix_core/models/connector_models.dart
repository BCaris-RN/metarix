import 'content_item.dart';
import 'model_types.dart';
import 'smartlink_page.dart';

class AccountConnectionRequest {
  const AccountConnectionRequest({
    required this.platform,
    required this.requestedScopes,
    required this.redirectUri,
    required this.state,
  });

  final SocialPlatform platform;
  final List<String> requestedScopes;
  final Uri redirectUri;
  final String state;
}

class AccountConnectionSession {
  const AccountConnectionSession({
    required this.platform,
    required this.authorizationUrl,
    required this.state,
    required this.expiresAt,
  });

  final SocialPlatform platform;
  final Uri authorizationUrl;
  final String state;
  final DateTime expiresAt;
}

class PublishValidation {
  const PublishValidation({
    required this.content,
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  final ContentItem content;
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
}

class PublishReceipt {
  const PublishReceipt({
    required this.platform,
    required this.accountId,
    required this.contentId,
    required this.status,
    required this.remoteId,
    required this.message,
    required this.checkedAt,
  });

  final SocialPlatform platform;
  final String accountId;
  final String contentId;
  final PublishExecutionStatus status;
  final String? remoteId;
  final String message;
  final DateTime checkedAt;
}

class AccountAnalyticsSummary {
  const AccountAnalyticsSummary({
    required this.platform,
    required this.accountId,
    required this.periodStart,
    required this.periodEnd,
    required this.impressions,
    required this.reach,
    required this.engagements,
    required this.clicks,
    required this.followerCount,
    required this.followerDelta,
  });

  final SocialPlatform platform;
  final String accountId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int impressions;
  final int reach;
  final int engagements;
  final int clicks;
  final int followerCount;
  final int followerDelta;
}

enum ConversationStatus { unread, open, assigned, resolved }

extension ConversationStatusX on ConversationStatus {
  String get label => switch (this) {
    ConversationStatus.unread => 'Unread',
    ConversationStatus.open => 'Open',
    ConversationStatus.assigned => 'Assigned',
    ConversationStatus.resolved => 'Resolved',
  };

  static ConversationStatus fromName(String value) =>
      ConversationStatus.values.firstWhere((status) => status.name == value);
}

class ConversationThread {
  const ConversationThread({
    required this.threadId,
    required this.platform,
    required this.accountId,
    required this.remoteThreadId,
    required this.title,
    required this.participantHandles,
    required this.status,
    required this.assignedToUserId,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  final String threadId;
  final SocialPlatform platform;
  final String accountId;
  final String remoteThreadId;
  final String title;
  final List<String> participantHandles;
  final ConversationStatus status;
  final String? assignedToUserId;
  final DateTime lastMessageAt;
  final int unreadCount;

  ConversationThread copyWith({
    String? threadId,
    SocialPlatform? platform,
    String? accountId,
    String? remoteThreadId,
    String? title,
    List<String>? participantHandles,
    ConversationStatus? status,
    String? assignedToUserId,
    bool clearAssignedToUserId = false,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) {
    return ConversationThread(
      threadId: threadId ?? this.threadId,
      platform: platform ?? this.platform,
      accountId: accountId ?? this.accountId,
      remoteThreadId: remoteThreadId ?? this.remoteThreadId,
      title: title ?? this.title,
      participantHandles: participantHandles ?? this.participantHandles,
      status: status ?? this.status,
      assignedToUserId: clearAssignedToUserId
          ? null
          : assignedToUserId ?? this.assignedToUserId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'threadId': threadId,
    'platform': platform.name,
    'accountId': accountId,
    'remoteThreadId': remoteThreadId,
    'title': title,
    'participantHandles': participantHandles,
    'status': status.name,
    'assignedToUserId': assignedToUserId,
    'lastMessageAt': lastMessageAt.toIso8601String(),
    'unreadCount': unreadCount,
  };

  factory ConversationThread.fromJson(Map<String, dynamic> json) =>
      ConversationThread(
        threadId: json['threadId'] as String,
        platform: SocialPlatformX.fromName(json['platform'] as String),
        accountId: json['accountId'] as String,
        remoteThreadId: json['remoteThreadId'] as String,
        title: json['title'] as String,
        participantHandles: (json['participantHandles'] as List<dynamic>)
            .cast<String>(),
        status: ConversationStatusX.fromName(json['status'] as String),
        assignedToUserId: json['assignedToUserId'] as String?,
        lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
        unreadCount: json['unreadCount'] as int,
      );
}

class ConversationMessage {
  const ConversationMessage({
    required this.messageId,
    required this.threadId,
    required this.platform,
    required this.authorHandle,
    required this.body,
    required this.isOutbound,
    required this.sentAt,
  });

  final String messageId;
  final String threadId;
  final SocialPlatform platform;
  final String authorHandle;
  final String body;
  final bool isOutbound;
  final DateTime sentAt;

  ConversationMessage copyWith({
    String? messageId,
    String? threadId,
    SocialPlatform? platform,
    String? authorHandle,
    String? body,
    bool? isOutbound,
    DateTime? sentAt,
  }) {
    return ConversationMessage(
      messageId: messageId ?? this.messageId,
      threadId: threadId ?? this.threadId,
      platform: platform ?? this.platform,
      authorHandle: authorHandle ?? this.authorHandle,
      body: body ?? this.body,
      isOutbound: isOutbound ?? this.isOutbound,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'messageId': messageId,
    'threadId': threadId,
    'platform': platform.name,
    'authorHandle': authorHandle,
    'body': body,
    'isOutbound': isOutbound,
    'sentAt': sentAt.toIso8601String(),
  };

  factory ConversationMessage.fromJson(Map<String, dynamic> json) =>
      ConversationMessage(
        messageId: json['messageId'] as String,
        threadId: json['threadId'] as String,
        platform: SocialPlatformX.fromName(json['platform'] as String),
        authorHandle: json['authorHandle'] as String,
        body: json['body'] as String,
        isOutbound: json['isOutbound'] as bool,
        sentAt: DateTime.parse(json['sentAt'] as String),
      );
}

class ListeningMentionRecord {
  const ListeningMentionRecord({
    required this.mentionId,
    required this.platform,
    required this.watchTermId,
    required this.authorHandle,
    required this.text,
    required this.sentimentLabel,
    required this.sourceUrl,
    required this.observedAt,
  });

  final String mentionId;
  final SocialPlatform platform;
  final String watchTermId;
  final String authorHandle;
  final String text;
  final String sentimentLabel;
  final Uri? sourceUrl;
  final DateTime observedAt;
}

class ListeningSpikeSignal {
  const ListeningSpikeSignal({
    required this.watchTermId,
    required this.platform,
    required this.baselineMentions,
    required this.currentMentions,
    required this.percentChange,
    required this.detectedAt,
  });

  final String watchTermId;
  final SocialPlatform platform;
  final int baselineMentions;
  final int currentMentions;
  final double percentChange;
  final DateTime detectedAt;
}

class SmartLinkClickAttribution {
  const SmartLinkClickAttribution({
    required this.pageId,
    required this.blockId,
    required this.referrer,
    required this.sourcePlatform,
    required this.clickCount,
    required this.recordedAt,
  });

  final String pageId;
  final String blockId;
  final Uri? referrer;
  final SocialPlatform? sourcePlatform;
  final int clickCount;
  final DateTime recordedAt;
}

class SmartLinkStats {
  const SmartLinkStats({
    required this.page,
    required this.views,
    required this.clicks,
    required this.uniqueVisitors,
    required this.topSources,
    required this.updatedAt,
  });

  final SmartlinkPage page;
  final int views;
  final int clicks;
  final int uniqueVisitors;
  final Map<String, int> topSources;
  final DateTime updatedAt;
}
