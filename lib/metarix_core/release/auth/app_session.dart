import '../common/release_helpers.dart';

class AppSession {
  const AppSession({
    required this.sessionId,
    required this.userId,
    required this.workspaceId,
    required this.workspaceName,
    required this.role,
    required this.accessTokenPreview,
    required this.createdAtIso,
    required this.updatedAtIso,
    required this.expiresAtIso,
  });

  final String sessionId;
  final String userId;
  final String workspaceId;
  final String workspaceName;
  final String role;
  final String accessTokenPreview;
  final String createdAtIso;
  final String updatedAtIso;
  final String expiresAtIso;

  bool get isExpired {
    final parsed = DateTime.tryParse(expiresAtIso);
    if (parsed == null) {
      return true;
    }
    return parsed.isBefore(DateTime.now().toUtc());
  }

  AppSession copyWith({
    String? sessionId,
    String? userId,
    String? workspaceId,
    String? workspaceName,
    String? role,
    String? accessTokenPreview,
    String? createdAtIso,
    String? updatedAtIso,
    String? expiresAtIso,
  }) {
    return AppSession(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      workspaceId: workspaceId ?? this.workspaceId,
      workspaceName: workspaceName ?? this.workspaceName,
      role: role ?? this.role,
      accessTokenPreview: accessTokenPreview ?? this.accessTokenPreview,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
      expiresAtIso: expiresAtIso ?? this.expiresAtIso,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionId': sessionId,
        'userId': userId,
        'workspaceId': workspaceId,
        'workspaceName': workspaceName,
        'role': role,
        'accessTokenPreview': accessTokenPreview,
        'createdAtIso': createdAtIso,
        'updatedAtIso': updatedAtIso,
        'expiresAtIso': expiresAtIso,
      };

  factory AppSession.fromJson(Map<String, Object?> json) {
    return AppSession(
      sessionId: stringOrFallback(json['sessionId'], 'session-local'),
      userId: stringOrFallback(json['userId'], 'user-local'),
      workspaceId: stringOrFallback(json['workspaceId'], 'workspace-local'),
      workspaceName: stringOrFallback(json['workspaceName'], 'Demo Workspace'),
      role: stringOrFallback(json['role'], 'owner'),
      accessTokenPreview: stringOrFallback(json['accessTokenPreview'], 'demo...'),
      createdAtIso: isoOrNow(json['createdAtIso']),
      updatedAtIso: isoOrNow(json['updatedAtIso']),
      expiresAtIso: stringOrFallback(
        json['expiresAtIso'],
        DateTime.now().toUtc().add(const Duration(hours: 8)).toIso8601String(),
      ),
    );
  }
}

