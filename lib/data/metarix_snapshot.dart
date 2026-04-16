import '../features/admin/domain/admin_models.dart';
import '../features/assets/domain/asset_record.dart';
import '../features/assets/domain/content_library_entry.dart';
import '../features/collaboration/domain/assignment_record.dart';
import '../features/collaboration/domain/comment_record.dart';
import '../features/listening/domain/listening_models.dart';
import '../features/listening/domain/listening_alert_rule.dart';
import '../features/listening/domain/share_of_voice_snapshot.dart';
import '../features/planning/domain/planning_models.dart';
import '../features/recommendations/domain/recommendation_model.dart';
import '../features/reports/domain/normalized_metric_record.dart';
import '../features/reports/domain/report_models.dart';
import '../features/schedule/domain/schedule_models.dart';
import '../features/shared/domain/core_models.dart';
import '../features/strategy/domain/strategy_models.dart';
import '../features/workflow/domain/workflow_models.dart';
import '../features/exports/domain/export_artifact.dart';
import '../runtime/activity/activity_event.dart';

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
  }) {
    return MetarixSnapshot(
      workspace: workspace ?? this.workspace,
      brand: brand ?? this.brand,
      currentUserId: currentUserId ?? this.currentUserId,
      users: users ?? this.users,
      memberships: memberships ?? this.memberships,
      assetRecords: assetRecords ?? this.assetRecords,
      contentLibraryEntries: contentLibraryEntries ?? this.contentLibraryEntries,
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
    );
  }

  Map<String, dynamic> toJson() => {
        'workspace': workspace.toJson(),
        'brand': brand.toJson(),
        'currentUserId': currentUserId,
        'users': users.map((entry) => entry.toJson()).toList(),
        'memberships': memberships.map((entry) => entry.toJson()).toList(),
        'assetRecords': assetRecords.map((entry) => entry.toJson()).toList(),
        'contentLibraryEntries':
            contentLibraryEntries.map((entry) => entry.toJson()).toList(),
        'commentRecords': commentRecords.map((entry) => entry.toJson()).toList(),
        'assignmentRecords':
            assignmentRecords.map((entry) => entry.toJson()).toList(),
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
        'reportPeriods': reportPeriods.map((entry) => entry.toJson()).toList(),
        'comparisonPeriods': comparisonPeriods,
        'normalizedMetrics':
            normalizedMetrics.map((entry) => entry.toJson()).toList(),
        'channelPerformance':
            channelPerformance.map((entry) => entry.toJson()).toList(),
        'standoutResults':
            standoutResults.map((entry) => entry.toJson()).toList(),
        'takeaways': takeaways.map((entry) => entry.toJson()).toList(),
        'overallLearnings':
            overallLearnings.map((entry) => entry.toJson()).toList(),
        'futureActions': futureActions.map((entry) => entry.toJson()).toList(),
        'recommendationInsights':
            recommendationInsights.map((entry) => entry.toJson()).toList(),
        'successSnapshot': successSnapshot,
        'topPostPlaceholder': topPostPlaceholder,
        'listeningQueries':
            listeningQueries.map((entry) => entry.toJson()).toList(),
        'mentions': mentions.map((entry) => entry.toJson()).toList(),
        'spikes': spikes.map((entry) => entry.toJson()).toList(),
        'shareOfVoiceSnapshots':
            shareOfVoiceSnapshots.map((entry) => entry.toJson()).toList(),
        'listeningAlertRules':
            listeningAlertRules.map((entry) => entry.toJson()).toList(),
        'competitorWatch':
            competitorWatch.map((entry) => entry.toJson()).toList(),
        'sentimentSummary': sentimentSummary.toJson(),
        'exportArtifacts': exportArtifacts.map((entry) => entry.toJson()).toList(),
        'activityEvents': activityEvents.map((entry) => entry.toJson()).toList(),
      };

  factory MetarixSnapshot.fromJson(Map<String, dynamic> json) => MetarixSnapshot(
        workspace: Workspace.fromJson(
          Map<String, dynamic>.from(json['workspace'] as Map),
        ),
        brand: Brand.fromJson(Map<String, dynamic>.from(json['brand'] as Map)),
        currentUserId: json['currentUserId'] as String,
        users: _mapList(json['users'], AppUser.fromJson),
        memberships: _mapList(
          json['memberships'],
          WorkspaceMembership.fromJson,
        ),
        assetRecords: _mapList(
          json['assetRecords'] ?? const <dynamic>[],
          AssetRecord.fromJson,
        ),
        contentLibraryEntries: _mapList(
          json['contentLibraryEntries'] ?? const <dynamic>[],
          ContentLibraryEntry.fromJson,
        ),
        commentRecords: _mapList(
          json['commentRecords'] ?? const <dynamic>[],
          CommentRecord.fromJson,
        ),
        assignmentRecords: _mapList(
          json['assignmentRecords'] ?? const <dynamic>[],
          AssignmentRecord.fromJson,
        ),
        businessGoals: _mapList(json['businessGoals'], BusinessGoal.fromJson),
        socialGoals: _mapList(json['socialGoals'], SocialGoal.fromJson),
        personas: _mapList(json['personas'], AudiencePersona.fromJson),
        competitors: _mapList(json['competitors'], Competitor.fromJson),
        swotEntries: _mapList(json['swotEntries'], SwotEntry.fromJson),
        auditFindings: _mapList(json['auditFindings'], AuditFinding.fromJson),
        contentPillars: _mapList(
          json['contentPillars'],
          ContentPillar.fromJson,
        ),
        campaigns: _mapList(json['campaigns'], Campaign.fromJson),
        evergreenItems: _mapList(
          json['evergreenItems'],
          EvergreenContentItem.fromJson,
        ),
        drafts: _mapList(json['drafts'], PostDraft.fromJson),
        approvals: _mapList(json['approvals'], ApprovalRecord.fromJson),
        schedules: _mapList(json['schedules'], ScheduleRecord.fromJson),
        reportPeriods: _mapList(json['reportPeriods'], ReportPeriod.fromJson),
        comparisonPeriods:
            Map<String, String>.from(json['comparisonPeriods'] as Map),
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
        futureActions: _mapList(
          json['futureActions'],
          Recommendation.fromJson,
        ),
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
      );

  static List<T> _mapList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) mapper,
  ) {
    return (source as List<dynamic>)
        .map((entry) => mapper(Map<String, dynamic>.from(entry as Map)))
        .toList();
  }
}
