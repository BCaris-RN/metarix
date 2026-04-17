import 'model_types.dart';

class ConnectedAccount {
  const ConnectedAccount({
    required this.accountId,
    required this.platform,
    required this.handle,
    required this.displayName,
    required this.connectionStatus,
    required this.scopes,
    required this.isLocalOnly,
    required this.lastSyncAt,
  });

  final String accountId;
  final SocialPlatform platform;
  final String handle;
  final String displayName;
  final ConnectionStatus connectionStatus;
  final List<String> scopes;
  final bool isLocalOnly;
  final DateTime? lastSyncAt;

  ConnectedAccount copyWith({
    String? accountId,
    SocialPlatform? platform,
    String? handle,
    String? displayName,
    ConnectionStatus? connectionStatus,
    List<String>? scopes,
    bool? isLocalOnly,
    DateTime? lastSyncAt,
    bool clearLastSyncAt = false,
  }) {
    return ConnectedAccount(
      accountId: accountId ?? this.accountId,
      platform: platform ?? this.platform,
      handle: handle ?? this.handle,
      displayName: displayName ?? this.displayName,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      scopes: scopes ?? this.scopes,
      isLocalOnly: isLocalOnly ?? this.isLocalOnly,
      lastSyncAt: clearLastSyncAt ? null : lastSyncAt ?? this.lastSyncAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'accountId': accountId,
    'platform': platform.name,
    'handle': handle,
    'displayName': displayName,
    'connectionStatus': connectionStatus.name,
    'scopes': scopes,
    'isLocalOnly': isLocalOnly,
    'lastSyncAt': lastSyncAt?.toIso8601String(),
  };

  factory ConnectedAccount.fromJson(Map<String, dynamic> json) =>
      ConnectedAccount(
        accountId: json['accountId'] as String,
        platform: SocialPlatformX.fromName(json['platform'] as String),
        handle: json['handle'] as String,
        displayName: json['displayName'] as String,
        connectionStatus: ConnectionStatusX.fromName(
          json['connectionStatus'] as String,
        ),
        scopes: (json['scopes'] as List<dynamic>).cast<String>().toList(),
        isLocalOnly: json['isLocalOnly'] as bool,
        lastSyncAt: json['lastSyncAt'] == null
            ? null
            : DateTime.parse(json['lastSyncAt'] as String),
      );
}
