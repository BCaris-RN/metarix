import 'dart:convert';

import 'package:flutter/services.dart';

import '../features/shared/domain/core_models.dart';
import '../features/workflow/domain/workflow_models.dart';

class CarisPolicyBundle {
  const CarisPolicyBundle({
    required this.capabilityVersion,
    required this.permissionVersion,
    required this.approvalVersion,
    required this.publishVersion,
    required this.stateVersion,
    required this.evidenceVersion,
    required this.capabilities,
    required this.actionPermissions,
    required this.actionCapabilityDependencies,
    required this.defaultApprovalPolicies,
    required this.channelApprovalOverrides,
    required this.evidenceProfiles,
  });

  final String capabilityVersion;
  final String permissionVersion;
  final String approvalVersion;
  final String publishVersion;
  final String stateVersion;
  final String evidenceVersion;
  final Map<SocialChannel, Map<String, bool>> capabilities;
  final Map<SocialChannel, Map<String, List<String>>> actionPermissions;
  final Map<String, String> actionCapabilityDependencies;
  final Map<String, String> defaultApprovalPolicies;
  final Map<SocialChannel, Map<String, String>> channelApprovalOverrides;
  final Map<String, List<String>> evidenceProfiles;

  bool supports(SocialChannel channel, String capabilityFlag) {
    return capabilities[channel]?[capabilityFlag] ?? false;
  }

  List<String> allowedRoles(SocialChannel channel, String action) {
    return actionPermissions[channel]?[action] ?? const [];
  }

  ApprovalRequirement approvalRequirementFor(
    SocialChannel channel,
    String action,
  ) {
    final override = channelApprovalOverrides[channel]?[action];
    final value = override ?? defaultApprovalPolicies[action] ?? 'none';
    return switch (value) {
      'manager_required' => ApprovalRequirement.managerRequired,
      'marketing_lead_required' => ApprovalRequirement.marketingLeadRequired,
      _ => ApprovalRequirement.none,
    };
  }

  List<String> evidenceFor(String profile) => evidenceProfiles[profile] ?? const [];
}

class CarisPolicyService {
  const CarisPolicyService();

  static const _assetBase = 'caris';

  Future<CarisPolicyBundle> load() async {
    final capabilityJson = await _loadJson('connector_capability_registry.json');
    final permissionJson = await _loadJson('channel_action_permissions.json');
    final approvalJson = await _loadJson('approval_policy_matrix.json');
    final publishJson = await _loadJson('publish_boundedness_rules.json');
    final stateJson = await _loadJson('content_state_contract.json');
    final evidenceJson = await _loadJson('evidence_requirements.json');

    return CarisPolicyBundle(
      capabilityVersion: capabilityJson['version'] as String,
      permissionVersion: permissionJson['version'] as String,
      approvalVersion: approvalJson['version'] as String,
      publishVersion: publishJson['version'] as String,
      stateVersion: stateJson['version'] as String,
      evidenceVersion: evidenceJson['version'] as String,
      capabilities: _parseCapabilities(
        capabilityJson['channels'] as Map<String, dynamic>,
      ),
      actionPermissions: _parseActionPermissions(
        permissionJson['channels'] as Map<String, dynamic>,
      ),
      actionCapabilityDependencies: Map<String, String>.from(
        permissionJson['action_capability_dependencies'] as Map,
      ),
      defaultApprovalPolicies: Map<String, String>.from(
        approvalJson['default_policies'] as Map,
      ),
      channelApprovalOverrides: _parseApprovalOverrides(
        approvalJson['channel_overrides'] as Map<String, dynamic>,
      ),
      evidenceProfiles: _parseEvidenceProfiles(
        evidenceJson['profiles'] as Map<String, dynamic>,
      ),
    );
  }

  Future<Map<String, dynamic>> _loadJson(String fileName) async {
    final raw = await rootBundle.loadString('$_assetBase/$fileName');
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Map<SocialChannel, Map<String, bool>> _parseCapabilities(
    Map<String, dynamic> source,
  ) {
    return source.map(
      (channelName, entry) => MapEntry(
        SocialChannelX.fromName(channelName),
        Map<String, bool>.from((entry as Map)['capabilities'] as Map),
      ),
    );
  }

  Map<SocialChannel, Map<String, List<String>>> _parseActionPermissions(
    Map<String, dynamic> source,
  ) {
    return source.map(
      (channelName, entry) => MapEntry(
        SocialChannelX.fromName(channelName),
        (entry as Map<String, dynamic>).map(
          (action, roles) => MapEntry(
            action,
            (roles as List<dynamic>).cast<String>().toList(),
          ),
        ),
      ),
    );
  }

  Map<SocialChannel, Map<String, String>> _parseApprovalOverrides(
    Map<String, dynamic> source,
  ) {
    return source.map(
      (channelName, overrides) => MapEntry(
        SocialChannelX.fromName(channelName),
        Map<String, String>.from(overrides as Map),
      ),
    );
  }

  Map<String, List<String>> _parseEvidenceProfiles(Map<String, dynamic> source) {
    return source.map(
      (profile, items) =>
          MapEntry(profile, (items as List<dynamic>).cast<String>().toList()),
    );
  }
}
