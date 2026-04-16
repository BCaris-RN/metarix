import 'package:flutter/foundation.dart';

import '../features/admin/domain/admin_models.dart';
import '../features/assets/domain/asset_record.dart';
import '../features/assets/domain/content_library_entry.dart';
import '../features/collaboration/domain/assignment_record.dart';
import '../features/collaboration/domain/comment_record.dart';
import '../features/listening/domain/listening_models.dart';
import '../features/listening/domain/listening_alert_rule.dart';
import '../features/listening/domain/listening_result_group.dart';
import '../features/planning/domain/planning_models.dart';
import '../features/recommendations/domain/recommendation_model.dart';
import '../features/recommendations/recommendation_repository.dart';
import '../features/reports/data/normalized_metric_repository.dart';
import '../features/reports/domain/metric_family.dart';
import '../features/reports/domain/normalized_metric_record.dart';
import '../features/reports/domain/report_models.dart';
import '../features/schedule/domain/schedule_models.dart';
import '../features/shared/domain/core_models.dart';
import '../features/strategy/domain/strategy_models.dart';
import '../features/workflow/domain/workflow_models.dart';
import '../features/exports/domain/export_artifact.dart';
import '../repositories/approval_repository.dart';
import '../repositories/campaign_repository.dart';
import '../repositories/draft_repository.dart';
import '../repositories/listening_query_repository.dart';
import '../repositories/report_repository.dart';
import '../repositories/schedule_repository.dart';
import '../repositories/strategy_repository.dart';
import '../repositories/workspace_repository.dart';
import '../runtime/activity/activity_event.dart';
import '../runtime/activity/activity_event_type.dart';
import '../runtime/activity/activity_ledger_repository.dart';
import 'local_storage_adapter.dart';
import 'metarix_snapshot.dart';
import 'sample_data_pack.dart';

class LocalMetarixGateway extends ChangeNotifier
    implements
        WorkspaceRepository,
        StrategyRepository,
        CampaignRepository,
        DraftRepository,
        ApprovalRepository,
        ScheduleRepository,
        ReportRepository,
        NormalizedMetricRepository,
        ListeningQueryRepository,
        RecommendationRepository,
        ActivityLedgerRepository {
  LocalMetarixGateway._(this._storage, this._snapshot);

  final LocalStorageAdapter _storage;
  MetarixSnapshot _snapshot;

  static Future<LocalMetarixGateway> bootstrap() async {
    final storage = await LocalStorageAdapter.create();
    final storedSnapshot = await storage.loadSnapshot();
    final snapshot = storedSnapshot ?? SampleDataPack.initialSnapshot();
    final gateway = LocalMetarixGateway._(storage, snapshot);
    if (storedSnapshot == null) {
      await gateway._persist(snapshot);
    }
    return gateway;
  }

  MetarixSnapshot get snapshot => _snapshot;

  Workspace get workspace => _snapshot.workspace;

  Brand get brand => _snapshot.brand;

  AppUser get currentUser =>
      _snapshot.users.firstWhere((user) => user.id == _snapshot.currentUserId);

  WorkspaceMembership get currentMembership => _snapshot.memberships.firstWhere(
        (membership) =>
            membership.userId == _snapshot.currentUserId &&
            membership.workspaceId == _snapshot.workspace.id,
      );

  UserRole get currentUserRole => currentMembership.role;

  Future<void> switchUser(String userId) async {
    await _replaceSnapshot(_snapshot.copyWith(currentUserId: userId));
  }

  Future<void> resetDemo() async {
    final resetSnapshot = SampleDataPack.initialSnapshot();
    await _storage.saveSnapshot(resetSnapshot);
    _snapshot = resetSnapshot;
    notifyListeners();
  }

  String createId(String prefix) => '$prefix-${DateTime.now().microsecondsSinceEpoch}';

  Future<void> _replaceSnapshot(MetarixSnapshot snapshot) async {
    _snapshot = snapshot;
    await _persist(snapshot);
    notifyListeners();
  }

  Future<void> _persist(MetarixSnapshot snapshot) async {
    await _storage.saveSnapshot(snapshot);
  }

  ReportSnapshot loadReportDataSync() {
    final channelPerformance = _buildChannelPerformance();
    return ReportSnapshot(
      activePeriodId: _snapshot.reportPeriods.first.id,
      reportPeriods: _snapshot.reportPeriods,
      comparisonPeriods: _snapshot.comparisonPeriods,
      normalizedMetrics: _snapshot.normalizedMetrics,
      channelPerformance: channelPerformance,
      standoutResults: _snapshot.standoutResults,
      takeaways: _snapshot.takeaways,
      overallLearnings: _snapshot.overallLearnings,
      futureActions: _snapshot.futureActions,
      recommendationInsights: _snapshot.recommendationInsights,
      successSnapshot: _snapshot.successSnapshot,
      topPostPlaceholder: _snapshot.topPostPlaceholder,
    );
  }

  Future<void> saveAssetRecord(AssetRecord record) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        assetRecords: _upsert(_snapshot.assetRecords, record, (entry) => entry.id),
      ),
    );
  }

  Future<void> saveContentLibraryEntry(ContentLibraryEntry entry) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        contentLibraryEntries: _upsert(
          _snapshot.contentLibraryEntries,
          entry,
          (item) => item.id,
        ),
      ),
    );
  }

  Future<void> saveCommentRecord(CommentRecord record) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        commentRecords: _upsert(_snapshot.commentRecords, record, (entry) => entry.id),
      ),
    );
  }

  Future<void> saveAssignmentRecord(AssignmentRecord record) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        assignmentRecords: _upsert(
          _snapshot.assignmentRecords,
          record,
          (entry) => entry.id,
        ),
      ),
    );
  }

  List<CommentRecord> commentsFor(String objectType, String objectId) {
    return _snapshot.commentRecords
        .where(
          (entry) => entry.objectType == objectType && entry.objectId == objectId,
        )
        .toList()
      ..sort((left, right) => left.createdAt.compareTo(right.createdAt));
  }

  List<AssignmentRecord> assignmentsFor(String objectType, String objectId) {
    return _snapshot.assignmentRecords
        .where(
          (entry) => entry.objectType == objectType && entry.objectId == objectId,
        )
        .toList()
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
  }

  List<AssetRecord> filterAssets({
    AssetRecordType? type,
    String? tag,
    String? campaignId,
    SocialChannel? channel,
  }) {
    return _snapshot.assetRecords.where((asset) {
      if (type != null && asset.type != type) {
        return false;
      }
      if (tag != null && tag.isNotEmpty && !asset.tags.contains(tag)) {
        return false;
      }
      if (channel != null && !asset.channels.contains(channel)) {
        return false;
      }
      if (campaignId != null) {
        final linkedDraft = _snapshot.drafts.any(
          (draft) =>
              draft.campaignId == campaignId &&
              draft.assetRefs.any((ref) => ref.id == asset.id),
        );
        final linkedLibrary = _snapshot.contentLibraryEntries.any(
          (entry) => entry.campaignId == campaignId && entry.assetIds.contains(asset.id),
        );
        if (!linkedDraft && !linkedLibrary) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<String> assetUsageLabels(String assetId) {
    return [
      ..._snapshot.drafts
          .where((draft) => draft.assetRefs.any((ref) => ref.id == assetId))
          .map((draft) => 'Draft: ${draft.title}'),
      ..._snapshot.campaigns
          .where(
            (campaign) => _snapshot.contentLibraryEntries.any(
              (entry) => entry.campaignId == campaign.id && entry.assetIds.contains(assetId),
            ),
          )
          .map((campaign) => 'Campaign: ${campaign.name}'),
    ];
  }

  List<ActivityEvent> viewActivityEvents({
    required String workspaceId,
    ActivityObjectType? objectType,
    String? objectId,
    DateTime? from,
    DateTime? to,
  }) {
    final events = _snapshot.activityEvents.where((event) {
      if (event.workspaceId != workspaceId) {
        return false;
      }
      if (objectType != null && event.objectType != objectType) {
        return false;
      }
      if (objectId != null && event.objectId != objectId) {
        return false;
      }
      if (from != null && event.occurredAt.isBefore(from)) {
        return false;
      }
      if (to != null && event.occurredAt.isAfter(to)) {
        return false;
      }
      return true;
    }).toList()
      ..sort((left, right) => right.occurredAt.compareTo(left.occurredAt));
    return events;
  }

  @override
  Future<void> recordActivityEvent(ActivityEvent event) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        activityEvents: [..._snapshot.activityEvents, event],
      ),
    );
  }

  @override
  Future<List<ActivityEvent>> queryActivityEvents({
    required String workspaceId,
    ActivityObjectType? objectType,
    String? objectId,
    DateTime? from,
    DateTime? to,
  }) async {
    return viewActivityEvents(
      workspaceId: workspaceId,
      objectType: objectType,
      objectId: objectId,
      from: from,
      to: to,
    );
  }

  @override
  Future<Workspace> createWorkspace(Workspace workspace) async {
    await _replaceSnapshot(_snapshot.copyWith(workspace: workspace));
    return workspace;
  }

  @override
  Future<Workspace?> loadWorkspace(String workspaceId) async {
    if (_snapshot.workspace.id != workspaceId) {
      return null;
    }
    return _snapshot.workspace;
  }

  @override
  Future<List<Brand>> listBrands(String workspaceId) async {
    if (_snapshot.workspace.id != workspaceId) {
      return const [];
    }
    return [_snapshot.brand];
  }

  @override
  Future<Brand> saveBrand(Brand brand) async {
    await _replaceSnapshot(_snapshot.copyWith(brand: brand));
    return brand;
  }

  @override
  Future<List<AppUser>> listUsers() async => _snapshot.users;

  @override
  Future<List<WorkspaceMembership>> listMemberships(String workspaceId) async {
    return _snapshot.memberships
        .where((membership) => membership.workspaceId == workspaceId)
        .toList();
  }

  @override
  Future<WorkspaceMembership> saveMembership(WorkspaceMembership membership) async {
    final nextMemberships = _upsert(
      _snapshot.memberships,
      membership,
      (entry) => entry.id,
    );
    await _replaceSnapshot(_snapshot.copyWith(memberships: nextMemberships));
    return membership;
  }

  @override
  Future<StrategyRecord> loadStrategy(String brandId) async {
    return StrategyRecord(
      workspace: _snapshot.workspace,
      brand: _snapshot.brand,
      businessGoals:
          _snapshot.businessGoals.where((goal) => goal.brandId == brandId).toList(),
      socialGoals: _snapshot.socialGoals
          .where(
            (goal) => _snapshot.businessGoals
                .where((businessGoal) => businessGoal.brandId == brandId)
                .map((businessGoal) => businessGoal.id)
                .contains(goal.businessGoalId),
          )
          .toList(),
      personas: _snapshot.personas.where((entry) => entry.brandId == brandId).toList(),
      competitors:
          _snapshot.competitors.where((entry) => entry.brandId == brandId).toList(),
      swotEntries:
          _snapshot.swotEntries.where((entry) => entry.brandId == brandId).toList(),
      auditFindings:
          _snapshot.auditFindings.where((entry) => entry.brandId == brandId).toList(),
      contentPillars:
          _snapshot.contentPillars.where((entry) => entry.brandId == brandId).toList(),
    );
  }

  @override
  Future<void> saveBusinessGoal(BusinessGoal goal) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        businessGoals: _upsert(
          _snapshot.businessGoals,
          goal,
          (entry) => entry.id,
        ),
      ),
    );
  }

  @override
  Future<void> saveSocialGoal(SocialGoal goal) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        socialGoals: _upsert(
          _snapshot.socialGoals,
          goal,
          (entry) => entry.id,
        ),
      ),
    );
  }

  @override
  Future<void> saveAudiencePersona(AudiencePersona persona) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        personas: _upsert(_snapshot.personas, persona, (entry) => entry.id),
      ),
    );
  }

  @override
  Future<void> saveCompetitor(Competitor competitor) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        competitors: _upsert(
          _snapshot.competitors,
          competitor,
          (entry) => entry.id,
        ),
      ),
    );
  }

  @override
  Future<void> saveSwotEntry(SwotEntry entry) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        swotEntries: _upsert(_snapshot.swotEntries, entry, (item) => item.id),
      ),
    );
  }

  @override
  Future<void> saveAuditFinding(AuditFinding finding) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        auditFindings: _upsert(
          _snapshot.auditFindings,
          finding,
          (item) => item.id,
        ),
      ),
    );
  }

  @override
  Future<void> saveContentPillar(ContentPillar pillar) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        contentPillars: _upsert(
          _snapshot.contentPillars,
          pillar,
          (item) => item.id,
        ),
      ),
    );
  }

  @override
  Future<Campaign> createCampaign(Campaign campaign) async {
    final nextCampaigns = _upsert(
      _snapshot.campaigns,
      campaign,
      (entry) => entry.id,
    );
    await _replaceSnapshot(_snapshot.copyWith(campaigns: nextCampaigns));
    return campaign;
  }

  @override
  Future<List<Campaign>> listCampaigns(String brandId) async {
    return _snapshot.campaigns.where((campaign) => campaign.brandId == brandId).toList();
  }

  @override
  Future<void> saveEvergreenItem(EvergreenContentItem item) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        evergreenItems: _upsert(
          _snapshot.evergreenItems,
          item,
          (entry) => entry.id,
        ),
      ),
    );
  }

  @override
  Future<List<EvergreenContentItem>> listEvergreenItems(String brandId) async {
    return _snapshot.evergreenItems.where((item) => item.brandId == brandId).toList();
  }

  @override
  Future<PostDraft> createDraft(PostDraft draft) async {
    final nextDrafts = _upsert(_snapshot.drafts, draft, (entry) => entry.id);
    await _replaceSnapshot(_snapshot.copyWith(drafts: nextDrafts));
    return draft;
  }

  @override
  Future<List<PostDraft>> listDrafts() async => _snapshot.drafts;

  @override
  Future<PostDraft> updateDraft(PostDraft draft) async {
    final nextDrafts = _upsert(_snapshot.drafts, draft, (entry) => entry.id);
    await _replaceSnapshot(_snapshot.copyWith(drafts: nextDrafts));
    return draft;
  }

  @override
  Future<ApprovalRecord> createApprovalRecord(ApprovalRecord record) async {
    final nextApprovals = _upsert(
      _snapshot.approvals,
      record,
      (entry) => entry.id,
    );
    await _replaceSnapshot(_snapshot.copyWith(approvals: nextApprovals));
    return record;
  }

  @override
  Future<List<ApprovalRecord>> listApprovalRecords() async => _snapshot.approvals;

  @override
  Future<ScheduleRecord> saveScheduleRecord(ScheduleRecord record) async {
    final nextSchedules = _upsert(
      _snapshot.schedules,
      record,
      (entry) => entry.id,
    );
    await _replaceSnapshot(_snapshot.copyWith(schedules: nextSchedules));
    return record;
  }

  @override
  Future<List<ScheduleRecord>> listScheduleRecords() async => _snapshot.schedules;

  @override
  Future<ReportSnapshot> loadReportData() async {
    return loadReportDataSync();
  }

  @override
  Future<void> saveTakeaway(Takeaway takeaway) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        takeaways: _upsert(_snapshot.takeaways, takeaway, (entry) => entry.id),
      ),
    );
  }

  @override
  Future<void> saveLearning(LearningEntry learning) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        overallLearnings: _upsert(
          _snapshot.overallLearnings,
          learning,
          (entry) => entry.id,
        ),
      ),
    );
  }

  @override
  Future<void> saveRecommendation(Recommendation recommendation) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        futureActions: _upsert(
          _snapshot.futureActions,
          recommendation,
          (entry) => entry.id,
        ),
      ),
    );
  }

  @override
  Future<List<NormalizedMetricRecord>> loadNormalizedMetrics({
    String? reportPeriodId,
  }) async {
    if (reportPeriodId == null) {
      return _snapshot.normalizedMetrics;
    }
    return _snapshot.normalizedMetrics
        .where((entry) => entry.reportPeriodId == reportPeriodId)
        .toList();
  }

  @override
  Future<void> saveNormalizedMetrics(List<NormalizedMetricRecord> metrics) async {
    final nextMetrics = List<NormalizedMetricRecord>.from(_snapshot.normalizedMetrics);
    for (final metric in metrics) {
      final index = nextMetrics.indexWhere((entry) => entry.id == metric.id);
      if (index == -1) {
        nextMetrics.add(metric);
      } else {
        nextMetrics[index] = metric;
      }
    }
    await _replaceSnapshot(_snapshot.copyWith(normalizedMetrics: nextMetrics));
  }

  @override
  Future<List<RecommendationInsight>> listRecommendationInsights(
    String reportPeriodId,
  ) async {
    return _snapshot.recommendationInsights
        .where((entry) => entry.reportPeriodId == reportPeriodId)
        .toList();
  }

  @override
  Future<void> saveRecommendationInsight(
    RecommendationInsight recommendation,
  ) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        recommendationInsights: _upsert(
          _snapshot.recommendationInsights,
          recommendation,
          (entry) => entry.id,
        ),
      ),
    );
  }

  @override
  Future<ListeningSnapshot> loadListeningSnapshot() async {
    return ListeningSnapshot(
      queries: _snapshot.listeningQueries,
      mentions: _snapshot.mentions,
      spikes: _snapshot.spikes,
      resultGroups: listeningResultGroups(),
      shareOfVoiceSnapshots: _snapshot.shareOfVoiceSnapshots,
      alertRules: _snapshot.listeningAlertRules,
      competitorWatch: _snapshot.competitorWatch,
      sentimentSummary: _snapshot.sentimentSummary,
    );
  }

  @override
  Future<ListeningQuery> saveListeningQuery(ListeningQuery query) async {
    final nextQueries = _upsert(
      _snapshot.listeningQueries,
      query,
      (entry) => entry.id,
    );
    await _replaceSnapshot(_snapshot.copyWith(listeningQueries: nextQueries));
    return query;
  }

  @override
  Future<Mention> updateMention(Mention mention) async {
    final nextMentions = _upsert(
      _snapshot.mentions,
      mention,
      (entry) => entry.id,
    );
    await _replaceSnapshot(_snapshot.copyWith(mentions: nextMentions));
    return mention;
  }

  Future<void> saveListeningAlertRule(ListeningAlertRule rule) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        listeningAlertRules: _upsert(
          _snapshot.listeningAlertRules,
          rule,
          (entry) => entry.id,
        ),
      ),
    );
  }

  Future<void> saveExportArtifact(ExportArtifact artifact) async {
    await _replaceSnapshot(
      _snapshot.copyWith(
        exportArtifacts: _upsert(
          _snapshot.exportArtifacts,
          artifact,
          (entry) => entry.id,
        ),
      ),
    );
  }

  List<ExportArtifact> exportArtifactsFor(String objectId) {
    return _snapshot.exportArtifacts
        .where((entry) => entry.objectId == objectId)
        .toList()
      ..sort((left, right) => right.generatedAt.compareTo(left.generatedAt));
  }

  List<ChannelPerformanceRecord> _buildChannelPerformance() {
    if (_snapshot.normalizedMetrics.isEmpty) {
      return _snapshot.channelPerformance;
    }

    final grouped = <String, Map<MetricFamily, double>>{};
    for (final metric in _snapshot.normalizedMetrics) {
      final key = '${metric.reportPeriodId}:${metric.channel.name}';
      grouped.putIfAbsent(key, () => <MetricFamily, double>{});
      grouped[key]!.update(
        metric.family,
        (value) => value + metric.value,
        ifAbsent: () => metric.value,
      );
    }

    return grouped.entries.map((entry) {
      final parts = entry.key.split(':');
      final reportPeriodId = parts.first;
      final channel = SocialChannelX.fromName(parts.last);
      final values = entry.value;
      return ChannelPerformanceRecord(
        id: 'performance-${channel.name}-$reportPeriodId',
        reportPeriodId: reportPeriodId,
        channel: channel,
        reach: (values[MetricFamily.reach] ?? 0).round(),
        impressions: (values[MetricFamily.impressions] ?? 0).round(),
        engagements: (values[MetricFamily.engagement] ?? 0).round(),
        clicks: (values[MetricFamily.clicks] ?? 0).round(),
        sentimentScore: values[MetricFamily.sentimentScore] ?? 0,
      );
    }).toList();
  }

  List<ListeningResultGroup> listeningResultGroups() {
    final groups = <ListeningResultGroup>[];
    final bySentiment = <String, int>{};
    final bySource = <String, int>{};
    final byTopic = <String, int>{};

    for (final mention in _snapshot.mentions) {
      bySentiment.update(
        mention.sentimentLabel,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      bySource.update(
        mention.source,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      final topic = mention.excerpt.split(' ').take(2).join(' ');
      byTopic.update(
        topic,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    groups.addAll(
      bySentiment.entries.map(
        (entry) => ListeningResultGroup(
          label: entry.key,
          dimension: 'sentiment',
          count: entry.value,
        ),
      ),
    );
    groups.addAll(
      bySource.entries.map(
        (entry) => ListeningResultGroup(
          label: entry.key,
          dimension: 'competitor',
          count: entry.value,
        ),
      ),
    );
    groups.addAll(
      byTopic.entries.map(
        (entry) => ListeningResultGroup(
          label: entry.key,
          dimension: 'topic',
          count: entry.value,
        ),
      ),
    );

    return groups;
  }

  List<T> _upsert<T, K>(
    List<T> source,
    T next,
    K Function(T entry) keySelector,
  ) {
    final key = keySelector(next);
    final existingIndex = source.indexWhere((entry) => keySelector(entry) == key);
    final updated = List<T>.from(source);
    if (existingIndex == -1) {
      updated.add(next);
    } else {
      updated[existingIndex] = next;
    }
    return updated;
  }
}
