enum UserRole {
  owner,
  admin,
  strategist,
  editor,
  approver,
  analyst,
}

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.owner => 'Owner',
        UserRole.admin => 'Admin',
        UserRole.strategist => 'Strategist',
        UserRole.editor => 'Editor',
        UserRole.approver => 'Approver',
        UserRole.analyst => 'Analyst',
      };

  static UserRole fromName(String value) =>
      UserRole.values.firstWhere((role) => role.name == value);
}

enum RuntimeAction {
  createCampaign,
  editDraft,
  approveContent,
  schedulePost,
  generateReport,
  manageListeningQueries,
  manageMembers,
}

extension RuntimeActionX on RuntimeAction {
  String get label => switch (this) {
        RuntimeAction.createCampaign => 'Create campaign',
        RuntimeAction.editDraft => 'Edit draft',
        RuntimeAction.approveContent => 'Approve content',
        RuntimeAction.schedulePost => 'Schedule post',
        RuntimeAction.generateReport => 'Generate report',
        RuntimeAction.manageListeningQueries => 'Manage listening queries',
        RuntimeAction.manageMembers => 'Manage members',
      };
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
      );
}

class WorkspaceMembership {
  const WorkspaceMembership({
    required this.id,
    required this.workspaceId,
    required this.userId,
    required this.role,
  });

  final String id;
  final String workspaceId;
  final String userId;
  final UserRole role;

  WorkspaceMembership copyWith({
    String? id,
    String? workspaceId,
    String? userId,
    UserRole? role,
  }) {
    return WorkspaceMembership(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'userId': userId,
        'role': role.name,
      };

  factory WorkspaceMembership.fromJson(Map<String, dynamic> json) =>
      WorkspaceMembership(
        id: json['id'] as String,
        workspaceId: json['workspaceId'] as String,
        userId: json['userId'] as String,
        role: UserRoleX.fromName(json['role'] as String),
      );
}

class AccessDecision {
  const AccessDecision({
    required this.allowed,
    required this.reason,
  });

  final bool allowed;
  final String reason;
}

class RoleVisibilityRule {
  const RoleVisibilityRule({
    required this.action,
    required this.allowedRoles,
  });

  final RuntimeAction action;
  final List<UserRole> allowedRoles;
}
