import '../../shared/domain/core_models.dart';
import '../../shared/domain/signal_summary.dart';
import '../../recommendations/domain/recommendation_model.dart';
import 'normalized_metric_record.dart';

enum ReportActionType {
  continueAction,
  stopAction,
  startAction,
  investigate,
  escalate,
}

extension ReportActionTypeX on ReportActionType {
  String get label => switch (this) {
    ReportActionType.continueAction => 'Continue',
    ReportActionType.stopAction => 'Stop',
    ReportActionType.startAction => 'Start',
    ReportActionType.investigate => 'Investigate',
    ReportActionType.escalate => 'Escalate',
  };

  static ReportActionType fromName(String value) =>
      ReportActionType.values.firstWhere((type) => type.name == value);
}

class ReportPeriod {
  const ReportPeriod({
    required this.id,
    required this.label,
    required this.start,
    required this.end,
  });

  final String id;
  final String label;
  final DateTime start;
  final DateTime end;

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
  };

  factory ReportPeriod.fromJson(Map<String, dynamic> json) => ReportPeriod(
    id: json['id'] as String,
    label: json['label'] as String,
    start: DateTime.parse(json['start'] as String),
    end: DateTime.parse(json['end'] as String),
  );
}

class ChannelPerformanceRecord {
  const ChannelPerformanceRecord({
    required this.id,
    required this.reportPeriodId,
    required this.channel,
    required this.reach,
    required this.impressions,
    required this.engagements,
    required this.clicks,
    required this.sentimentScore,
  });

  final String id;
  final String reportPeriodId;
  final SocialChannel channel;
  final int reach;
  final int impressions;
  final int engagements;
  final int clicks;
  final double sentimentScore;

  Map<String, dynamic> toJson() => {
    'id': id,
    'reportPeriodId': reportPeriodId,
    'channel': channel.name,
    'reach': reach,
    'impressions': impressions,
    'engagements': engagements,
    'clicks': clicks,
    'sentimentScore': sentimentScore,
  };

  factory ChannelPerformanceRecord.fromJson(Map<String, dynamic> json) =>
      ChannelPerformanceRecord(
        id: json['id'] as String,
        reportPeriodId: json['reportPeriodId'] as String,
        channel: SocialChannelX.fromName(json['channel'] as String),
        reach: json['reach'] as int,
        impressions: json['impressions'] as int,
        engagements: json['engagements'] as int,
        clicks: json['clicks'] as int,
        sentimentScore: (json['sentimentScore'] as num).toDouble(),
      );
}

class StandoutResult {
  const StandoutResult({
    required this.id,
    required this.reportPeriodId,
    required this.headline,
    required this.detail,
  });

  final String id;
  final String reportPeriodId;
  final String headline;
  final String detail;

  Map<String, dynamic> toJson() => {
    'id': id,
    'reportPeriodId': reportPeriodId,
    'headline': headline,
    'detail': detail,
  };

  factory StandoutResult.fromJson(Map<String, dynamic> json) => StandoutResult(
    id: json['id'] as String,
    reportPeriodId: json['reportPeriodId'] as String,
    headline: json['headline'] as String,
    detail: json['detail'] as String,
  );
}

class Takeaway {
  const Takeaway({
    required this.id,
    required this.reportPeriodId,
    required this.title,
    required this.whatHappened,
    required this.whyItHappened,
    required this.howWeKnow,
    required this.whatWeLearned,
  });

  final String id;
  final String reportPeriodId;
  final String title;
  final String whatHappened;
  final String whyItHappened;
  final String howWeKnow;
  final String whatWeLearned;

  Takeaway copyWith({
    String? id,
    String? reportPeriodId,
    String? title,
    String? whatHappened,
    String? whyItHappened,
    String? howWeKnow,
    String? whatWeLearned,
  }) {
    return Takeaway(
      id: id ?? this.id,
      reportPeriodId: reportPeriodId ?? this.reportPeriodId,
      title: title ?? this.title,
      whatHappened: whatHappened ?? this.whatHappened,
      whyItHappened: whyItHappened ?? this.whyItHappened,
      howWeKnow: howWeKnow ?? this.howWeKnow,
      whatWeLearned: whatWeLearned ?? this.whatWeLearned,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reportPeriodId': reportPeriodId,
    'title': title,
    'whatHappened': whatHappened,
    'whyItHappened': whyItHappened,
    'howWeKnow': howWeKnow,
    'whatWeLearned': whatWeLearned,
  };

  factory Takeaway.fromJson(Map<String, dynamic> json) => Takeaway(
    id: json['id'] as String,
    reportPeriodId: json['reportPeriodId'] as String,
    title: json['title'] as String,
    whatHappened: json['whatHappened'] as String,
    whyItHappened: json['whyItHappened'] as String,
    howWeKnow: json['howWeKnow'] as String,
    whatWeLearned: json['whatWeLearned'] as String,
  );
}

class LearningEntry {
  const LearningEntry({
    required this.id,
    required this.reportPeriodId,
    required this.text,
  });

  final String id;
  final String reportPeriodId;
  final String text;

  Map<String, dynamic> toJson() => {
    'id': id,
    'reportPeriodId': reportPeriodId,
    'text': text,
  };

  factory LearningEntry.fromJson(Map<String, dynamic> json) => LearningEntry(
    id: json['id'] as String,
    reportPeriodId: json['reportPeriodId'] as String,
    text: json['text'] as String,
  );
}

class Recommendation {
  const Recommendation({
    required this.id,
    required this.reportPeriodId,
    required this.title,
    required this.actionType,
    required this.rationale,
    required this.owner,
    required this.expectedBenefit,
  });

  final String id;
  final String reportPeriodId;
  final String title;
  final ReportActionType actionType;
  final String rationale;
  final String owner;
  final String expectedBenefit;

  Recommendation copyWith({
    String? id,
    String? reportPeriodId,
    String? title,
    ReportActionType? actionType,
    String? rationale,
    String? owner,
    String? expectedBenefit,
  }) {
    return Recommendation(
      id: id ?? this.id,
      reportPeriodId: reportPeriodId ?? this.reportPeriodId,
      title: title ?? this.title,
      actionType: actionType ?? this.actionType,
      rationale: rationale ?? this.rationale,
      owner: owner ?? this.owner,
      expectedBenefit: expectedBenefit ?? this.expectedBenefit,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reportPeriodId': reportPeriodId,
    'title': title,
    'actionType': actionType.name,
    'rationale': rationale,
    'owner': owner,
    'expectedBenefit': expectedBenefit,
  };

  factory Recommendation.fromJson(Map<String, dynamic> json) => Recommendation(
    id: json['id'] as String,
    reportPeriodId: json['reportPeriodId'] as String,
    title: json['title'] as String,
    actionType: ReportActionTypeX.fromName(json['actionType'] as String),
    rationale: json['rationale'] as String,
    owner: json['owner'] as String,
    expectedBenefit: json['expectedBenefit'] as String,
  );
}

class ReportSnapshot {
  const ReportSnapshot({
    required this.activePeriodId,
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
    required this.signalSummaries,
  });

  final String activePeriodId;
  final Map<String, String> comparisonPeriods;
  final List<ReportPeriod> reportPeriods;
  final List<NormalizedMetricRecord> normalizedMetrics;
  final List<ChannelPerformanceRecord> channelPerformance;
  final List<StandoutResult> standoutResults;
  final List<Takeaway> takeaways;
  final List<LearningEntry> overallLearnings;
  final List<Recommendation> futureActions;
  final List<RecommendationInsight> recommendationInsights;
  final String successSnapshot;
  final String topPostPlaceholder;
  final Map<String, SignalSummary> signalSummaries;

  SignalSummary signalSummaryFor(String periodId) {
    return signalSummaries[periodId]!;
  }
}
