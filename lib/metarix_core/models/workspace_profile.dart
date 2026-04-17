import 'model_types.dart';

class WorkspaceProfile {
  const WorkspaceProfile({
    required this.workspaceId,
    required this.displayName,
    required this.mode,
    required this.timezone,
    required this.defaultPlatforms,
    required this.createdAt,
    required this.updatedAt,
  });

  final String workspaceId;
  final String displayName;
  final WorkspaceMode mode;
  final String timezone;
  final List<SocialPlatform> defaultPlatforms;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkspaceProfile copyWith({
    String? workspaceId,
    String? displayName,
    WorkspaceMode? mode,
    String? timezone,
    List<SocialPlatform>? defaultPlatforms,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkspaceProfile(
      workspaceId: workspaceId ?? this.workspaceId,
      displayName: displayName ?? this.displayName,
      mode: mode ?? this.mode,
      timezone: timezone ?? this.timezone,
      defaultPlatforms: defaultPlatforms ?? this.defaultPlatforms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'workspaceId': workspaceId,
    'displayName': displayName,
    'mode': mode.name,
    'timezone': timezone,
    'defaultPlatforms': defaultPlatforms
        .map((platform) => platform.name)
        .toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory WorkspaceProfile.fromJson(Map<String, dynamic> json) =>
      WorkspaceProfile(
        workspaceId: json['workspaceId'] as String,
        displayName: json['displayName'] as String,
        mode: WorkspaceModeX.fromName(json['mode'] as String),
        timezone: json['timezone'] as String,
        defaultPlatforms: (json['defaultPlatforms'] as List<dynamic>)
            .cast<String>()
            .map(SocialPlatformX.fromName)
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
