import 'listening_alert_rule.dart';
import 'listening_result_group.dart';
import 'share_of_voice_snapshot.dart';

enum QueryFamily {
  brand,
  campaign,
  competitor,
  industry,
  influencer,
  crisis,
}

extension QueryFamilyX on QueryFamily {
  String get label => switch (this) {
        QueryFamily.brand => 'Brand',
        QueryFamily.campaign => 'Campaign',
        QueryFamily.competitor => 'Competitor',
        QueryFamily.industry => 'Industry',
        QueryFamily.influencer => 'Influencer',
        QueryFamily.crisis => 'Crisis',
      };

  static QueryFamily fromName(String value) =>
      QueryFamily.values.firstWhere((family) => family.name == value);
}

enum InsightAction {
  observe,
  replyLater,
  escalate,
  report,
  opportunity,
}

extension InsightActionX on InsightAction {
  String get label => switch (this) {
        InsightAction.observe => 'Observe',
        InsightAction.replyLater => 'Reply later',
        InsightAction.escalate => 'Escalate',
        InsightAction.report => 'Report',
        InsightAction.opportunity => 'Opportunity',
      };

  static InsightAction fromName(String value) =>
      InsightAction.values.firstWhere((action) => action.name == value);
}

class ListeningQuery {
  const ListeningQuery({
    required this.id,
    required this.brandId,
    required this.name,
    required this.queryFamily,
    required this.queryText,
    required this.tags,
    required this.targetCompetitors,
  });

  final String id;
  final String brandId;
  final String name;
  final QueryFamily queryFamily;
  final String queryText;
  final List<String> tags;
  final List<String> targetCompetitors;

  ListeningQuery copyWith({
    String? id,
    String? brandId,
    String? name,
    QueryFamily? queryFamily,
    String? queryText,
    List<String>? tags,
    List<String>? targetCompetitors,
  }) {
    return ListeningQuery(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      queryFamily: queryFamily ?? this.queryFamily,
      queryText: queryText ?? this.queryText,
      tags: tags ?? this.tags,
      targetCompetitors: targetCompetitors ?? this.targetCompetitors,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'name': name,
        'queryFamily': queryFamily.name,
        'queryText': queryText,
        'tags': tags,
        'targetCompetitors': targetCompetitors,
      };

  factory ListeningQuery.fromJson(Map<String, dynamic> json) => ListeningQuery(
        id: json['id'] as String,
        brandId: (json['brandId'] as String?) ?? '',
        name: json['name'] as String,
        queryFamily: QueryFamilyX.fromName(json['queryFamily'] as String),
        queryText: json['queryText'] as String,
        tags: (json['tags'] as List<dynamic>).cast<String>().toList(),
        targetCompetitors:
            (json['targetCompetitors'] as List<dynamic>).cast<String>().toList(),
      );
}

class Mention {
  const Mention({
    required this.id,
    required this.queryId,
    required this.source,
    required this.excerpt,
    required this.sentimentLabel,
    required this.spikeDetected,
    required this.recommendedAction,
    required this.occurredAt,
  });

  final String id;
  final String queryId;
  final String source;
  final String excerpt;
  final String sentimentLabel;
  final bool spikeDetected;
  final InsightAction recommendedAction;
  final DateTime occurredAt;

  Mention copyWith({
    String? id,
    String? queryId,
    String? source,
    String? excerpt,
    String? sentimentLabel,
    bool? spikeDetected,
    InsightAction? recommendedAction,
    DateTime? occurredAt,
  }) {
    return Mention(
      id: id ?? this.id,
      queryId: queryId ?? this.queryId,
      source: source ?? this.source,
      excerpt: excerpt ?? this.excerpt,
      sentimentLabel: sentimentLabel ?? this.sentimentLabel,
      spikeDetected: spikeDetected ?? this.spikeDetected,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'queryId': queryId,
        'source': source,
        'excerpt': excerpt,
        'sentimentLabel': sentimentLabel,
        'spikeDetected': spikeDetected,
        'recommendedAction': recommendedAction.name,
        'occurredAt': occurredAt.toIso8601String(),
      };

  factory Mention.fromJson(Map<String, dynamic> json) => Mention(
        id: json['id'] as String,
        queryId: json['queryId'] as String,
        source: json['source'] as String,
        excerpt: json['excerpt'] as String,
        sentimentLabel: json['sentimentLabel'] as String,
        spikeDetected: json['spikeDetected'] as bool,
        recommendedAction: InsightActionX.fromName(
          json['recommendedAction'] as String,
        ),
        occurredAt: DateTime.parse(json['occurredAt'] as String),
      );
}

class SpikeEvent {
  const SpikeEvent({
    required this.id,
    required this.queryId,
    required this.headline,
    required this.mentionCount,
    required this.sentimentLabel,
    required this.recommendedAction,
    required this.detectedAt,
  });

  final String id;
  final String queryId;
  final String headline;
  final int mentionCount;
  final String sentimentLabel;
  final InsightAction recommendedAction;
  final DateTime detectedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'queryId': queryId,
        'headline': headline,
        'mentionCount': mentionCount,
        'sentimentLabel': sentimentLabel,
        'recommendedAction': recommendedAction.name,
        'detectedAt': detectedAt.toIso8601String(),
      };

  factory SpikeEvent.fromJson(Map<String, dynamic> json) => SpikeEvent(
        id: json['id'] as String,
        queryId: json['queryId'] as String,
        headline: json['headline'] as String,
        mentionCount: json['mentionCount'] as int,
        sentimentLabel: json['sentimentLabel'] as String,
        recommendedAction: InsightActionX.fromName(
          json['recommendedAction'] as String,
        ),
        detectedAt: DateTime.parse(json['detectedAt'] as String),
      );
}

class CompetitorWatchEntry {
  const CompetitorWatchEntry({
    required this.id,
    required this.competitorName,
    required this.shareOfVoice,
    required this.sentimentLabel,
    required this.recommendedAction,
  });

  final String id;
  final String competitorName;
  final double shareOfVoice;
  final String sentimentLabel;
  final InsightAction recommendedAction;

  Map<String, dynamic> toJson() => {
        'id': id,
        'competitorName': competitorName,
        'shareOfVoice': shareOfVoice,
        'sentimentLabel': sentimentLabel,
        'recommendedAction': recommendedAction.name,
      };

  factory CompetitorWatchEntry.fromJson(Map<String, dynamic> json) =>
      CompetitorWatchEntry(
        id: json['id'] as String,
        competitorName: json['competitorName'] as String,
        shareOfVoice: (json['shareOfVoice'] as num).toDouble(),
        sentimentLabel: json['sentimentLabel'] as String,
        recommendedAction: InsightActionX.fromName(
          json['recommendedAction'] as String,
        ),
      );
}

class SentimentSummary {
  const SentimentSummary({
    required this.positive,
    required this.mixed,
    required this.negative,
  });

  final int positive;
  final int mixed;
  final int negative;

  Map<String, dynamic> toJson() => {
        'positive': positive,
        'mixed': mixed,
        'negative': negative,
      };

  factory SentimentSummary.fromJson(Map<String, dynamic> json) =>
      SentimentSummary(
        positive: json['positive'] as int,
        mixed: json['mixed'] as int,
        negative: json['negative'] as int,
      );
}

class ListeningSnapshot {
  const ListeningSnapshot({
    required this.queries,
    required this.mentions,
    required this.spikes,
    required this.resultGroups,
    required this.shareOfVoiceSnapshots,
    required this.alertRules,
    required this.competitorWatch,
    required this.sentimentSummary,
  });

  final List<ListeningQuery> queries;
  final List<Mention> mentions;
  final List<SpikeEvent> spikes;
  final List<ListeningResultGroup> resultGroups;
  final List<ShareOfVoiceSnapshot> shareOfVoiceSnapshots;
  final List<ListeningAlertRule> alertRules;
  final List<CompetitorWatchEntry> competitorWatch;
  final SentimentSummary sentimentSummary;
}
