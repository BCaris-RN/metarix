import '../features/shared/domain/core_models.dart';
import '../features/workflow/domain/workflow_models.dart';

abstract class BaseConnector {
  const BaseConnector();

  SocialChannel get channel;
  bool get canSchedule;
  bool get canPublish;
  bool get canFetchAnalytics;

  Map<String, dynamic> fetchAnalyticsPayload(String reportPeriodId);

  ConnectorPublishResult simulatePublish(PostDraft draft);
}

class ConnectorPublishResult {
  const ConnectorPublishResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;
}

class PolicyBackedConnector extends BaseConnector {
  const PolicyBackedConnector({
    required this.channel,
    required this.canSchedule,
    required this.canPublish,
    required this.canFetchAnalytics,
    required this.analyticsPayloadBuilder,
  });

  @override
  final SocialChannel channel;

  @override
  final bool canSchedule;

  @override
  final bool canPublish;

  @override
  final bool canFetchAnalytics;

  final Map<String, dynamic> Function(String reportPeriodId) analyticsPayloadBuilder;

  @override
  Map<String, dynamic> fetchAnalyticsPayload(String reportPeriodId) =>
      analyticsPayloadBuilder(reportPeriodId);

  @override
  ConnectorPublishResult simulatePublish(PostDraft draft) {
    if (!canPublish) {
      return ConnectorPublishResult(
        success: false,
        message: '${channel.label} cannot publish from the sandbox connector.',
      );
    }
    final deterministic = (draft.id.hashCode + channel.name.hashCode).isEven;
    return ConnectorPublishResult(
      success: deterministic,
      message: deterministic
          ? 'Sandbox publish completed for ${draft.title}.'
          : 'Sandbox publish denied for ${draft.title}.',
    );
  }
}
