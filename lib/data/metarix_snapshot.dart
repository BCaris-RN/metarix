import '../features/admin/domain/admin_models.dart';
import '../features/assets/domain/asset_record.dart';
import '../features/assets/domain/content_library_entry.dart';
import '../features/collaboration/domain/assignment_record.dart';
import '../features/collaboration/domain/comment_record.dart';
import '../features/listening/domain/listening_models.dart';
import '../features/listening/domain/listening_alert_rule.dart';
import '../features/listening/domain/share_of_voice_snapshot.dart';
import '../features/planning/domain/planning_models.dart';
import '../features/publish/domain/publish_models.dart';
import '../features/recommendations/domain/recommendation_model.dart';
import '../features/reports/domain/normalized_metric_record.dart';
import '../features/reports/domain/report_models.dart';
import '../features/schedule/domain/schedule_models.dart';
import '../features/shared/domain/core_models.dart';
import '../features/strategy/domain/strategy_models.dart';
import '../features/workflow/domain/workflow_models.dart';
import '../metarix_core/models/connector_models.dart';
import '../metarix_core/models/connected_social_account.dart';
import '../metarix_core/models/connector_runtime_state.dart';
import '../metarix_core/models/linkedin_auth_record.dart';
import '../features/exports/domain/export_artifact.dart';
import '../runtime/activity/activity_event.dart';
import '../services/linkedin/linkedin_auth_session.dart';

class MetarixSnapshot {
  const MetarixSnapshot({
    required this.workspace,
    required this.brand,
    required this.currentUserId,
    required this.users,
    required this.memberships,
    required this.assetRecords,
    required this.contentLibraryEntries,
    required this.commentRecords,
    required this.assignmentRecords,
    required this.businessGoals,
    required this.socialGoals,
    required this.personas,
    required this.competitors,
    required this.swotEntries,
    required this.auditFindings,
    required this.contentPillars,
    required this.campaigns,
    required this.evergreenItems,
    required this.drafts,
    required this.approvals,
    required this.schedules,
    required this.scheduledPosts,
    required this.conversationThreads,
    required this.conversationMessages,
    required this.reportPeriods,
    required this.comparisonPeriods,
    required this.normalizedMetrics,
    required this.channelPerformance,
    required this.standoutResults,
    required this.takeaways,
    required this.overallLearnings,
    required this.futureActions,
    required this.recommendationInsights,
    required this.successSnapshot,
    required this.topPostPlaceholder,
    required this.listeningQueries,
    required this.mentions,
    required this.spikes,
    required this.shareOfVoiceSnapshots,
    required this.listeningAlertRules,
    required this.competitorWatch,
    required this.sentimentSummary,
    required this.exportArtifacts,
    required this.activityEvents,
    this.connectedAccounts = const <ConnectedSocialAccount>[],
    this.connectorRuntimeStates = const <ConnectorRuntimeState>[],
    this.pendingLinkedInAuthSession,
    this.linkedInAuthRecords = const <LinkedInAuthRecord>[],
  });

  final Workspace workspace;
  final Brand brand;
  final String currentUserId;
  final List<AppUser> users;
  final List<WorkspaceMembership> memberships;
  final List<AssetRecord> assetRecords;
  final List<ContentLibraryEntry> contentLibraryEntries;
  final List<CommentRecord> commentRecords;
  final List<AssignmentRecord> assignmentRecords;
  final List<BusinessGoal> businessGoals;
  final List<SocialGoal> socialGoals;
  final List<AudiencePersona> personas;
  final List<Competitor> competitors;
  final List<SwotEntry> swotEntries;
  final List<AuditFinding> auditFindings;
  final List<ContentPillar> contentPillars;
  final List<Campaign> campaigns;
  final List<EvergreenContentItem> evergreenItems;
  final List<PostDraft> drafts;
  final List<ApprovalRecord> approvals;
  final List<ScheduleRecord> schedules;
  final List<ScheduledPostRecord> scheduledPosts;
  final List<ConversationThread> conversationThreads;
  final List<ConversationMessage> conversationMessages;
  final List<ReportPeriod> reportPeriods;
  final Map<String, String> comparisonPeriods;
  final List<NormalizedMetricRecord> normalizedMetrics;
  final List<ChannelPerformanceRecord> channelPerformance;
  final List<StandoutResult> standoutResults;
  final List<Takeaway> takeaways;
  final List<LearningEntry> overallLearnings;
  final List<Recommendation> futureActions;
  final List<RecommendationInsight> recommendationInsights;
  final String successSnapshot;
  final String topPostPlaceholder;
  final List<ListeningQuery> listeningQueries;
  final List<Mention> mentions;
  final List<SpikeEvent> spikes;
  final List<ShareOfVoiceSnapshot> shareOfVoiceSnapshots;
  final List<ListeningAlertRule> listeningAlertRules;
  final List<CompetitorWatchEntry> competitorWatch;
  final SentimentSummary sentimentSummary;
  final List<ExportArtifact> exportArtifacts;
  final List<ActivityEvent> activityEvents;
  final List<ConnectedSocialAccount> connectedAccounts;
  final List<ConnectorRuntimeState> connectorRuntimeStates;
  final LinkedInAuthSession? pendingLinkedInAuthSession;
  final List<LinkedInAuthRecord> linkedInAuthRecords;

  MetarixSnapshot copyWith({
    Workspace? workspace,
    Brand? brand,
    String? currentUserId,
    List<AppUser>? users,
    List<WorkspaceMembership>? memberships,
    List<AssetRecord>? assetRecords,
    List<ContentLibraryEntry>? contentLibraryEntries,
    List<CommentRecord>? commentRecords,
    List<AssignmentRecord>? assignmentRecords,
    List<BusinessGoal>? businessGoals,
    List<SocialGoal>? socialGoals,
    List<AudiencePersona>? personas,
    List<Competitor>? competitors,
    List<SwotEntry>? swotEntries,
    List<AuditFinding>? auditFindings,
    List<ContentPillar>? contentPillars,
    List<Campaign>? campaigns,
    List<EvergreenContentItem>? evergreenItems,
    List<PostDraft>? drafts,
    List<ApprovalRecord>? approvals,
    List<ScheduleRecord>? schedules,
    List<ScheduledPostRecord>? scheduledPosts,
    List<ConversationThread>? conversationThreads,
    List<ConversationMessage>? conversationMessages,
    List<ReportPeriod>? reportPeriods,
    Map<String, String>? comparisonPeriods,
    List<NormalizedMetricRecord>? normalizedMetrics,
    List<ChannelPerformanceRecord>? channelPerformance,
    List<StandoutResult>? standoutResults,
    List<Takeaway>? takeaways,
    List<LearningEntry>? overallLearnings,
    List<Recommendation>? futureActions,
    List<RecommendationInsight>? recommendationInsights,
    String? successSnapshot,
    String? topPostPlaceholder,
    List<ListeningQuery>? listeningQueries,
    List<Mention>? mentions,
    List<SpikeEvent>? spikes,
    List<ShareOfVoiceSnapshot>? shareOfVoiceSnapshots,
    List<ListeningAlertRule>? listeningAlertRules,
    List<CompetitorWatchEntry>? competitorWatch,
    SentimentSummary? sentimentSummary,
    List<ExportArtifact>? exportArtifacts,
    List<ActivityEvent>? activityEvents,
    List<ConnectedSocialAccount>? connectedAccounts,
    List<ConnectorRuntimeState>? connectorRuntimeStates,
    LinkedInAuthSession? pendingLinkedInAuthSession,
    bool clearPendingLinkedInAuthSession = false,
    List<LinkedInAuthRecord>? linkedInAuthRecords,
  }) {
    return MetarixSnapshot(
      workspace: workspace ?? this.workspace,
      brand: brand ?? this.brand,
      currentUserId: currentUserId ?? this.currentUserId,
      users: users ?? this.users,
      memberships: memberships ?? this.memberships,
      assetRecords: assetRecords ?? this.assetRecords,
      contentLibraryEntries:
          contentLibraryEntries ?? this.contentLibraryEntries,
      commentRecords: commentRecords ?? this.commentRecords,
      assignmentRecords: assignmentRecords ?? this.assignmentRecords,
      businessGoals: businessGoals ?? this.businessGoals,
      socialGoals: socialGoals ?? this.socialGoals,
      personas: personas ?? this.personas,
      competitors: competitors ?? this.competitors,
      swotEntries: swotEntries ?? this.swotEntries,
      auditFindings: auditFindings ?? this.auditFindings,
      contentPillars: contentPillars ?? this.contentPillars,
      campaigns: campaigns ?? this.campaigns,
      evergreenItems: evergreenItems ?? this.evergreenItems,
      drafts: drafts ?? this.drafts,
      approvals: approvals ?? this.approvals,
      schedules: schedules ?? this.schedules,
      scheduledPosts: scheduledPosts ?? this.scheduledPosts,
      conversationThreads: conversationThreads ?? this.conversationThreads,
      conversationMessages: conversationMessages ?? this.conversationMessages,
      reportPeriods: reportPeriods ?? this.reportPeriods,
      comparisonPeriods: comparisonPeriods ?? this.comparisonPeriods,
      normalizedMetrics: normalizedMetrics ?? this.normalizedMetrics,
      channelPerformance: channelPerformance ?? this.channelPerformance,
      standoutResults: standoutResults ?? this.standoutResults,
      takeaways: takeaways ?? this.takeaways,
      overallLearnings: overallLearnings ?? this.overallLearnings,
      futureActions: futureActions ?? this.futureActions,
      recommendationInsights:
          recommendationInsights ?? this.recommendationInsights,
      successSnapshot: successSnapshot ?? this.successSnapshot,
      topPostPlaceholder: topPostPlaceholder ?? this.topPostPlaceholder,
      listeningQueries: listeningQueries ?? this.listeningQueries,
      mentions: mentions ?? this.mentions,
      spikes: spikes ?? this.spikes,
      shareOfVoiceSnapshots:
          shareOfVoiceSnapshots ?? this.shareOfVoiceSnapshots,
      listeningAlertRules: listeningAlertRules ?? this.listeningAlertRules,
      competitorWatch: competitorWatch ?? this.competitorWatch,
      sentimentSummary: sentimentSummary ?? this.sentimentSummary,
      exportArtifacts: exportArtifacts ?? this.exportArtifacts,
      activityEvents: activityEvents ?? this.activityEvents,
      connectedAccounts: connectedAccounts ?? this.connectedAccounts,
      connectorRuntimeStates:
          connectorRuntimeStates ?? this.connectorRuntimeStates,
      pendingLinkedInAuthSession: clearPendingLinkedInAuthSession
          ? null
          : pendingLinkedInAuthSession ?? this.pendingLinkedInAuthSession,
      linkedInAuthRecords: linkedInAuthRecords ?? this.linkedInAuthRecords,
    );
  }

  Map<String, dynamic> toJson() => {
    'workspace': workspace.toJson(),
    'brand': brand.toJson(),
    'currentUserId': currentUserId,
    'users': users.map((entry) => entry.toJson()).toList(),
    'memberships': memberships.map((entry) => entry.toJson()).toList(),
    'assetRecords': assetRecords.map((entry) => entry.toJson()).toList(),
    'contentLibraryEntries': contentLibraryEntries
        .map((entry) => entry.toJson())
        .toList(),
    'commentRecords': commentRecords.map((entry) => entry.toJson()).toList(),
    'assignmentRecords': assignmentRecords
        .map((entry) => entry.toJson())
        .toList(),
    'businessGoals': businessGoals.map((entry) => entry.toJson()).toList(),
    'socialGoals': socialGoals.map((entry) => entry.toJson()).toList(),
    'personas': personas.map((entry) => entry.toJson()).toList(),
    'competitors': competitors.map((entry) => entry.toJson()).toList(),
    'swotEntries': swotEntries.map((entry) => entry.toJson()).toList(),
    'auditFindings': auditFindings.map((entry) => entry.toJson()).toList(),
    'contentPillars': contentPillars.map((entry) => entry.toJson()).toList(),
    'campaigns': campaigns.map((entry) => entry.toJson()).toList(),
    'evergreenItems': evergreenItems.map((entry) => entry.toJson()).toList(),
    'drafts': drafts.map((entry) => entry.toJson()).toList(),
    'approvals': approvals.map((entry) => entry.toJson()).toList(),
    'schedules': schedules.map((entry) => entry.toJson()).toList(),
    'scheduledPosts': scheduledPosts.map((entry) => entry.toJson()).toList(),
    'conversationThreads': conversationThreads
        .map((entry) => entry.toJson())
        .toList(),
    'conversationMessages': conversationMessages
        .map((entry) => entry.toJson())
        .toList(),
    'reportPeriods': reportPeriods.map((entry) => entry.toJson()).toList(),
    'comparisonPeriods': comparisonPeriods,
    'normalizedMetrics': normalizedMetrics
        .map((entry) => entry.toJson())
        .toList(),
    'channelPerformance': channelPerformance
        .map((entry) => entry.toJson())
        .toList(),
    'standoutResults': standoutResults.map((entry) => entry.toJson()).toList(),
    'takeaways': takeaways.map((entry) => entry.toJson()).toList(),
    'overallLearnings': overallLearnings
        .map((entry) => entry.toJson())
        .toList(),
    'futureActions': futureActions.map((entry) => entry.toJson()).toList(),
    'recommendationInsights': recommendationInsights
        .map((entry) => entry.toJson())
        .toList(),
    'successSnapshot': successSnapshot,
    'topPostPlaceholder': topPostPlaceholder,
    'listeningQueries': listeningQueries
        .map((entry) => entry.toJson())
        .toList(),
    'mentions': mentions.map((entry) => entry.toJson()).toList(),
    'spikes': spikes.map((entry) => entry.toJson()).toList(),
    'shareOfVoiceSnapshots': shareOfVoiceSnapshots
        .map((entry) => entry.toJson())
        .toList(),
    'listeningAlertRules': listeningAlertRules
        .map((entry) => entry.toJson())
        .toList(),
    'competitorWatch': competitorWatch.map((entry) => entry.toJson()).toList(),
    'sentimentSummary': sentimentSummary.toJson(),
    'exportArtifacts': exportArtifacts.map((entry) => entry.toJson()).toList(),
    'activityEvents': activityEvents.map((entry) => entry.toJson()).toList(),
    'connectedAccounts': connectedAccounts
        .map((entry) => entry.toJson())
        .toList(),
    'connectorRuntimeStates': connectorRuntimeStates
        .map((entry) => entry.toJson())
        .toList(),
    'pendingLinkedInAuthSession': pendingLinkedInAuthSession?.toJson(),
    'linkedInAuthRecords': linkedInAuthRecords
        .map((entry) => entry.toJson())
        .toList(),
  };

  factory MetarixSnapshot.fromJson(Map<String, dynamic> json) {
    final workspace = Workspace.fromJson(
      Map<String, dynamic>.from(json['workspace'] as Map),
    );
    final brand = Brand.fromJson(
      Map<String, dynamic>.from(json['brand'] as Map),
    );
    final users = _mapList(json['users'], AppUser.fromJson);
    final memberships = _mapList(
      json['memberships'],
      WorkspaceMembership.fromJson,
    );
    final assetRecords = _mapList(
      json['assetRecords'] ?? const <dynamic>[],
      AssetRecord.fromJson,
    );
    final contentLibraryEntries = _mapList(
      json['contentLibraryEntries'] ?? const <dynamic>[],
      ContentLibraryEntry.fromJson,
    );
    final commentRecords = _mapList(
      json['commentRecords'] ?? const <dynamic>[],
      CommentRecord.fromJson,
    );
    final assignmentRecords = _mapList(
      json['assignmentRecords'] ?? const <dynamic>[],
      AssignmentRecord.fromJson,
    );
    final businessGoals = _mapList(
      json['businessGoals'],
      BusinessGoal.fromJson,
    );
    final socialGoals = _mapList(json['socialGoals'], SocialGoal.fromJson);
    final personas = _mapList(json['personas'], AudiencePersona.fromJson);
    final competitors = _mapList(json['competitors'], Competitor.fromJson);
    final swotEntries = _mapList(json['swotEntries'], SwotEntry.fromJson);
    final auditFindings = _mapList(
      json['auditFindings'],
      AuditFinding.fromJson,
    );
    final contentPillars = _mapList(
      json['contentPillars'],
      ContentPillar.fromJson,
    );
    final campaigns = _mapList(json['campaigns'], Campaign.fromJson);
    final evergreenItems = _mapList(
      json['evergreenItems'],
      EvergreenContentItem.fromJson,
    );
    final drafts = _mapList(json['drafts'], PostDraft.fromJson);
    final approvals = _mapList(json['approvals'], ApprovalRecord.fromJson);
    final schedules = _mapList(json['schedules'], ScheduleRecord.fromJson);
    final scheduledPosts = json['scheduledPosts'] == null
        ? _deriveScheduledPosts(
            campaigns: campaigns,
            drafts: drafts,
            schedules: schedules,
          )
        : _mapList(json['scheduledPosts'], ScheduledPostRecord.fromJson);
    final conversationThreads = json['conversationThreads'] == null
        ? const <ConversationThread>[]
        : _mapList(json['conversationThreads'], ConversationThread.fromJson);
    final conversationMessages = json['conversationMessages'] == null
        ? const <ConversationMessage>[]
        : _mapList(json['conversationMessages'], ConversationMessage.fromJson);
    final connectedAccounts =
        (json['connectedAccounts'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map(
              (item) => ConnectedSocialAccount.fromJson(
                Map<String, Object?>.from(item),
              ),
            )
            .toList(growable: false);
    final connectorRuntimeStates =
        (json['connectorRuntimeStates'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map(
              (item) => ConnectorRuntimeState.fromJson(
                Map<String, Object?>.from(item),
              ),
            )
            .toList(growable: false);
    final pendingLinkedInAuthSession =
        json['pendingLinkedInAuthSession'] == null
            ? null
            : LinkedInAuthSession.fromJson(
                Map<String, Object?>.from(
                  json['pendingLinkedInAuthSession'] as Map,
                ),
              );
    final linkedInAuthRecords =
        (json['linkedInAuthRecords'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map(
              (item) => LinkedInAuthRecord.fromJson(
                Map<String, Object?>.from(item),
              ),
            )
            .toList(growable: false);

    return MetarixSnapshot(
      workspace: workspace,
      brand: brand,
      currentUserId: json['currentUserId'] as String,
      users: users,
      memberships: memberships,
      assetRecords: assetRecords,
      contentLibraryEntries: contentLibraryEntries,
      commentRecords: commentRecords,
      assignmentRecords: assignmentRecords,
      businessGoals: businessGoals,
      socialGoals: socialGoals,
      personas: personas,
      competitors: competitors,
      swotEntries: swotEntries,
      auditFindings: auditFindings,
      contentPillars: contentPillars,
      campaigns: campaigns,
      evergreenItems: evergreenItems,
      drafts: drafts,
      approvals: approvals,
      schedules: schedules,
      scheduledPosts: scheduledPosts,
      conversationThreads: conversationThreads,
      conversationMessages: conversationMessages,
      reportPeriods: _mapList(json['reportPeriods'], ReportPeriod.fromJson),
      comparisonPeriods: Map<String, String>.from(
        json['comparisonPeriods'] as Map,
      ),
      normalizedMetrics: _mapList(
        json['normalizedMetrics'] ?? const <dynamic>[],
        NormalizedMetricRecord.fromJson,
      ),
      channelPerformance: _mapList(
        json['channelPerformance'],
        ChannelPerformanceRecord.fromJson,
      ),
      standoutResults: _mapList(
        json['standoutResults'],
        StandoutResult.fromJson,
      ),
      takeaways: _mapList(json['takeaways'], Takeaway.fromJson),
      overallLearnings: _mapList(
        json['overallLearnings'],
        LearningEntry.fromJson,
      ),
      futureActions: _mapList(json['futureActions'], Recommendation.fromJson),
      recommendationInsights: _mapList(
        json['recommendationInsights'] ?? const <dynamic>[],
        RecommendationInsight.fromJson,
      ),
      successSnapshot: json['successSnapshot'] as String,
      topPostPlaceholder: json['topPostPlaceholder'] as String,
      listeningQueries: _mapList(
        json['listeningQueries'],
        ListeningQuery.fromJson,
      ),
      mentions: _mapList(json['mentions'], Mention.fromJson),
      spikes: _mapList(json['spikes'], SpikeEvent.fromJson),
      shareOfVoiceSnapshots: _mapList(
        json['shareOfVoiceSnapshots'] ?? const <dynamic>[],
        ShareOfVoiceSnapshot.fromJson,
      ),
      listeningAlertRules: _mapList(
        json['listeningAlertRules'] ?? const <dynamic>[],
        ListeningAlertRule.fromJson,
      ),
      competitorWatch: _mapList(
        json['competitorWatch'],
        CompetitorWatchEntry.fromJson,
      ),
      sentimentSummary: SentimentSummary.fromJson(
        Map<String, dynamic>.from(json['sentimentSummary'] as Map),
      ),
      exportArtifacts: _mapList(
        json['exportArtifacts'] ?? const <dynamic>[],
        ExportArtifact.fromJson,
      ),
      activityEvents: _mapList(
        json['activityEvents'] ?? const <dynamic>[],
        ActivityEvent.fromJson,
      ),
      connectedAccounts: connectedAccounts,
      connectorRuntimeStates: connectorRuntimeStates,
      pendingLinkedInAuthSession: pendingLinkedInAuthSession,
      linkedInAuthRecords: linkedInAuthRecords,
    );
  }

  static List<T> _mapList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) mapper,
  ) {
    return (source as List<dynamic>)
        .map((entry) => mapper(Map<String, dynamic>.from(entry as Map)))
        .toList();
  }

  static List<ScheduledPostRecord> _deriveScheduledPosts({
    required List<Campaign> campaigns,
    required List<PostDraft> drafts,
    required List<ScheduleRecord> schedules,
  }) {
    final campaignNames = {
      for (final campaign in campaigns) campaign.id: campaign.name,
    };

    return drafts.map((draft) {
      ScheduleRecord? schedule;
      for (final entry in schedules) {
        if (entry.draftId == draft.id) {
          schedule = entry;
          break;
        }
      }

      final status = switch (draft.currentState) {
        ContentState.published => PublishRecordStatus.published,
        ContentState.publishDenied => PublishRecordStatus.blocked,
        ContentState.scheduled
            when schedule?.denialReasons.isNotEmpty ?? false =>
          PublishRecordStatus.blocked,
        ContentState.scheduled => PublishRecordStatus.scheduled,
        _ => PublishRecordStatus.draft,
      };

      return ScheduledPostRecord(
        id: 'publish-${draft.id}',
        draftId: draft.id,
        campaignId: draft.campaignId,
        campaignName: campaignNames[draft.campaignId] ?? draft.campaignId,
        title: draft.title,
        channel: draft.targetNetwork,
        status: status,
        scheduledAt: schedule?.scheduledAt ?? draft.plannedPublishAt,
        queuedAt: null,
        publishedAt: status == PublishRecordStatus.published
            ? draft.plannedPublishAt
            : null,
        updatedAt:
            schedule?.scheduledAt ??
            draft.plannedPublishAt ??
            DateTime.fromMillisecondsSinceEpoch(0),
        lastError: null,
        denialReasons: status == PublishRecordStatus.blocked
            ? schedule?.denialReasons ?? const []
            : const [],
      );
    }).toList();
  }
}
