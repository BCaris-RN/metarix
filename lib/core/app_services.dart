import '../connectors/connector_registry.dart';
import '../data/local_metarix_gateway.dart';
import '../features/activity/application/activity_controller.dart';
import '../features/admin/application/admin_controller.dart';
import '../features/assets/application/asset_library_controller.dart';
import '../features/assets/data/local_asset_repository.dart';
import '../features/collaboration/application/collaboration_controller.dart';
import '../features/conversation/application/conversation_controller.dart';
import '../features/conversation/application/conversation_state_transition_service.dart';
import '../features/connectors/adapters/channel_metric_mapper.dart';
import '../features/exports/application/export_service.dart';
import '../features/exports/formatters/evidence_export_formatter.dart';
import '../features/exports/formatters/report_export_formatter.dart';
import '../features/exports/formatters/strategy_export_formatter.dart';
import '../features/listening/application/listening_controller.dart';
import '../features/planning/application/planning_controller.dart';
import '../features/publish/application/publish_controller.dart';
import '../features/publish/application/publish_state_transition_service.dart';
import '../features/recommendations/recommendation_engine.dart';
import '../features/reports/application/metric_normalizer.dart';
import '../features/reports/application/report_controller.dart';
import '../features/search/application/global_search_service.dart';
import '../features/strategy/application/strategy_controller.dart';
import '../features/workflow/application/workflow_controller.dart';
import '../metarix_core/connectors/connector_bundle.dart';
import '../metarix_core/connectors/demo/demo_connector_bundle.dart';
import '../metarix_core/models/connected_social_account.dart';
import '../metarix_core/models/model_types.dart';
import '../runtime/jobs/job_queue_service.dart';
import '../services/access_control_service.dart';
import '../services/backend_api_service.dart';
import '../services/caris_policy_service.dart';
import '../services/linkedin/linkedin_connection_service.dart';
import '../services/linkedin/linkedin_auth_service.dart';
import '../services/linkedin/linkedin_token_exchange_service.dart';
import '../services/workflow_services.dart';
import 'backend_config.dart';
import 'config/environment_config.dart';
import 'config/feature_flag_service.dart';

class AppServices {
  AppServices._({
    required this.backendConfig,
    required this.environmentConfig,
    required this.featureFlags,
    required this.gateway,
    required this.policies,
    required this.accessControlService,
    required this.publishPostureEvaluator,
    required this.connectorRegistry,
    required this.backendConnectors,
    required this.metricNormalizer,
    required this.recommendationEngine,
    required this.linkedInAuthService,
    required this.linkedInConnectionService,
    required this.exportService,
    required this.globalSearchService,
    required this.backendApiService,
    required this.jobQueueService,
    required this.activityController,
    required this.assetLibraryController,
    required this.collaborationController,
    required this.strategyController,
    required this.planningController,
    required this.conversationController,
    required this.publishController,
    required this.workflowController,
    required this.reportController,
    required this.listeningController,
    required this.adminController,
  });

  final BackendConfig backendConfig;
  final EnvironmentConfig environmentConfig;
  final FeatureFlagService featureFlags;
  final LocalMetarixGateway gateway;
  final CarisPolicyBundle policies;
  final AccessControlService accessControlService;
  final PublishPostureEvaluator publishPostureEvaluator;
  final ConnectorRegistry connectorRegistry;
  final ConnectorBundle backendConnectors;
  final MetricNormalizer metricNormalizer;
  final RecommendationEngine recommendationEngine;
  final LinkedInAuthService linkedInAuthService;
  final LinkedInConnectionService linkedInConnectionService;
  final ExportService exportService;
  final GlobalSearchService globalSearchService;
  final BackendApiService backendApiService;
  final JobQueueService jobQueueService;
  final ActivityController activityController;
  final AssetLibraryController assetLibraryController;
  final CollaborationController collaborationController;
  final StrategyController strategyController;
  final PlanningController planningController;
  final ConversationController conversationController;
  final PublishController publishController;
  final WorkflowController workflowController;
  final ReportController reportController;
  final ListeningController listeningController;
  final AdminController adminController;
  bool _disposed = false;

  static Future<AppServices> bootstrap({
    BackendConfig? backendConfigOverride,
    LinkedInAuthService? linkedInAuthServiceOverride,
    LinkedInTokenExchangeService? linkedInTokenExchangeServiceOverride,
  }) async {
    final backendConfig =
        backendConfigOverride ?? BackendConfig.fromEnvironment();
    final environmentConfig = EnvironmentConfig.fromEnvironment();
    final featureFlags = FeatureFlagService(environmentConfig);
    final gateway = await LocalMetarixGateway.bootstrap();
    await gateway.saveConnectorRuntimeState(
      backendConfig.linkedInRuntimeState(
        connected:
            gateway.connectedAccountFor('linkedin')?.status ==
            SocialConnectionStatus.connected,
      ),
    );
    final policies = await const CarisPolicyService().load();
    const accessControlService = AccessControlService();
    final approvalEvaluator = ApprovalEvaluator(policies);
    final scheduleValidator = ScheduleValidator(policies);
    final publishPostureEvaluator = PublishPostureEvaluator(
      policies,
      approvalEvaluator,
      scheduleValidator,
    );
    final connectorRegistry = ConnectorRegistry(policies);
    final backendConnectors = _selectBackendConnectors(backendConfig);
    const conversationStateTransitionService =
        ConversationStateTransitionService();
    const publishStateTransitionService = PublishStateTransitionService();
    final metricNormalizer = MetricNormalizer(
      connectorRegistry,
      const ChannelMetricMapper(),
      'v1',
    );
    const recommendationEngine = RecommendationEngine();
    final linkedInAuthService =
        linkedInAuthServiceOverride ?? const LinkedInAuthService();
    final linkedInTokenExchangeService =
        linkedInTokenExchangeServiceOverride ??
        const LinkedInTokenExchangeService();
    final linkedInConnectionService = LinkedInConnectionService(
      gateway,
      linkedInTokenExchangeService,
    );
    final exportService = ExportService(
      gateway,
      const StrategyExportFormatter(),
      const ReportExportFormatter(),
      const EvidenceExportFormatter(),
    );
    final globalSearchService = GlobalSearchService(gateway);
    final backendApiService = BackendApiService();
    final jobQueueService = JobQueueService.seeded(gateway.workspace.id);
    final assetLibraryController = AssetLibraryController(
      LocalAssetRepository(gateway),
      gateway,
    );
    final collaborationController = CollaborationController(gateway);
    final publishController = PublishController(
      gateway,
      gateway,
      gateway,
      publishStateTransitionService,
    );
    final conversationController = ConversationController(
      gateway,
      gateway,
      conversationStateTransitionService,
    );

    return AppServices._(
      backendConfig: backendConfig,
      environmentConfig: environmentConfig,
      featureFlags: featureFlags,
      gateway: gateway,
      policies: policies,
      accessControlService: accessControlService,
      publishPostureEvaluator: publishPostureEvaluator,
      connectorRegistry: connectorRegistry,
      backendConnectors: backendConnectors,
      metricNormalizer: metricNormalizer,
      recommendationEngine: recommendationEngine,
      linkedInAuthService: linkedInAuthService,
      linkedInConnectionService: linkedInConnectionService,
      exportService: exportService,
      globalSearchService: globalSearchService,
      backendApiService: backendApiService,
      jobQueueService: jobQueueService,
      activityController: ActivityController(gateway),
      assetLibraryController: assetLibraryController,
      collaborationController: collaborationController,
      strategyController: StrategyController(gateway, gateway),
      planningController: PlanningController(
        gateway,
        gateway,
        gateway,
        gateway,
        publishStateTransitionService,
      ),
      conversationController: conversationController,
      publishController: publishController,
      workflowController: WorkflowController(
        gateway,
        gateway,
        gateway,
        gateway,
        gateway,
        backendConnectors,
        accessControlService,
        publishPostureEvaluator,
        publishStateTransitionService,
      ),
      reportController: ReportController(gateway, gateway),
      listeningController: ListeningController(gateway, gateway),
      adminController: AdminController(gateway, gateway, accessControlService),
    );
  }

  static ConnectorBundle _selectBackendConnectors(BackendConfig backendConfig) {
    final bundle = switch (backendConfig.mode) {
      BackendMode.demo => DemoConnectorBundle.create(),
      // TODO: Replace this fallback with local secret-backed connector
      // implementations once real platform adapters are available.
      BackendMode.supabaseRest => DemoConnectorBundle.create(),
    };

    return ConnectorBundle(
      runtimeKind: bundle.runtimeKind,
      accountConnectors: bundle.accountConnectors,
      publishConnectors: bundle.publishConnectors,
      analyticsConnectors: bundle.analyticsConnectors,
      conversationConnectors: bundle.conversationConnectors,
      listeningConnectors: bundle.listeningConnectors,
      smartLinkService: bundle.smartLinkService,
    );
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    activityController.dispose();
    assetLibraryController.dispose();
    collaborationController.dispose();
    jobQueueService.dispose();
    backendApiService.dispose();
    strategyController.dispose();
    planningController.dispose();
    conversationController.dispose();
    publishController.dispose();
    workflowController.dispose();
    reportController.dispose();
    listeningController.dispose();
    adminController.dispose();
    gateway.dispose();
  }
}
