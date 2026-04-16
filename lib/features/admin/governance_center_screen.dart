import 'package:flutter/material.dart';

import '../../../connectors/connector_registry.dart';
import '../../../services/caris_policy_service.dart';
import '../../../services/workflow_services.dart';
import '../shared/domain/core_models.dart';
import '../schedule/domain/schedule_models.dart';
import '../workflow/domain/workflow_models.dart';
import 'approval_matrix_panel.dart';
import 'connector_posture_panel.dart';
import 'policy_version_card.dart';
import 'publish_boundary_panel.dart';

class GovernanceCenterScreen extends StatelessWidget {
  const GovernanceCenterScreen({
    required this.policies,
    required this.connectorRegistry,
    required this.publishResults,
    required this.loadedAtLabel,
    super.key,
  });

  final CarisPolicyBundle policies;
  final ConnectorRegistry connectorRegistry;
  final List<PublishPostureResult> publishResults;
  final String loadedAtLabel;

  @override
  Widget build(BuildContext context) {
    final connectorRows = SocialChannel.values
        .map(
          (channel) => (
            channel: channel,
            schedule: connectorRegistry.connectorFor(channel).canSchedule,
            publish: connectorRegistry.connectorFor(channel).canPublish,
            analytics: connectorRegistry.connectorFor(channel).canFetchAnalytics,
          ),
        )
        .toList();

    final approvalRows = SocialChannel.values
        .map(
          (channel) => (
            channel: channel.label,
            action: 'publish_attempt',
            requirement:
                policies.approvalRequirementFor(channel, 'publish_attempt').label,
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            PolicyVersionCard(
              title: 'Capabilities',
              version: policies.capabilityVersion,
              loadedAtLabel: loadedAtLabel,
            ),
            PolicyVersionCard(
              title: 'Approvals',
              version: policies.approvalVersion,
              loadedAtLabel: loadedAtLabel,
            ),
            PolicyVersionCard(
              title: 'Publish',
              version: policies.publishVersion,
              loadedAtLabel: loadedAtLabel,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ConnectorPosturePanel(rows: connectorRows),
        const SizedBox(height: 16),
        PublishBoundaryPanel(
          eligibleCount: publishResults
              .where((entry) => entry.posture == PublishPosture.publishEligible)
              .length,
          deniedCount: publishResults
              .where((entry) => entry.posture == PublishPosture.publishDenied)
              .length,
          denialReasonsCount: publishResults.fold<int>(
            0,
            (sum, entry) => sum + entry.denialReasons.length,
          ),
        ),
        const SizedBox(height: 16),
        ApprovalMatrixPanel(rows: approvalRows),
      ],
    );
  }
}
