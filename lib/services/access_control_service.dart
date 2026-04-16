import '../features/admin/domain/admin_models.dart';
import '../features/workflow/domain/workflow_models.dart';

class AccessControlService {
  const AccessControlService();

  static const _rules = [
    RoleVisibilityRule(
      action: RuntimeAction.createCampaign,
      allowedRoles: [UserRole.owner, UserRole.admin, UserRole.strategist],
    ),
    RoleVisibilityRule(
      action: RuntimeAction.editDraft,
      allowedRoles: [
        UserRole.owner,
        UserRole.admin,
        UserRole.strategist,
        UserRole.editor,
      ],
    ),
    RoleVisibilityRule(
      action: RuntimeAction.approveContent,
      allowedRoles: [UserRole.owner, UserRole.admin, UserRole.approver],
    ),
    RoleVisibilityRule(
      action: RuntimeAction.schedulePost,
      allowedRoles: [UserRole.owner, UserRole.admin, UserRole.approver],
    ),
    RoleVisibilityRule(
      action: RuntimeAction.generateReport,
      allowedRoles: [
        UserRole.owner,
        UserRole.admin,
        UserRole.analyst,
        UserRole.strategist,
      ],
    ),
    RoleVisibilityRule(
      action: RuntimeAction.manageListeningQueries,
      allowedRoles: [UserRole.owner, UserRole.admin, UserRole.strategist],
    ),
    RoleVisibilityRule(
      action: RuntimeAction.manageMembers,
      allowedRoles: [UserRole.owner, UserRole.admin],
    ),
  ];

  List<RoleVisibilityRule> get rules => _rules;

  AccessDecision canPerform(
    UserRole role,
    RuntimeAction action, {
    ApprovalRequirement? approvalRequirement,
  }) {
    final rule = _rules.firstWhere((entry) => entry.action == action);
    if (!rule.allowedRoles.contains(role)) {
      return AccessDecision(
        allowed: false,
        reason: '${role.label} cannot ${action.label.toLowerCase()}.',
      );
    }

    if (action == RuntimeAction.approveContent &&
        approvalRequirement == ApprovalRequirement.marketingLeadRequired &&
        ![
          UserRole.owner,
          UserRole.admin,
          UserRole.approver,
        ].contains(role)) {
      return const AccessDecision(
        allowed: false,
        reason: 'Marketing-lead approval maps to owner, admin, or approver.',
      );
    }

    return const AccessDecision(allowed: true, reason: 'Allowed');
  }

  List<RuntimeAction> visibleActionsFor(UserRole role) {
    return _rules
        .where((rule) => rule.allowedRoles.contains(role))
        .map((rule) => rule.action)
        .toList();
  }
}
