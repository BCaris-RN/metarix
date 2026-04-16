enum RecommendationType {
  cadenceAdjustment,
  contentShift,
  channelFocus,
}

extension RecommendationTypeX on RecommendationType {
  String get label => switch (this) {
        RecommendationType.cadenceAdjustment => 'Cadence adjustment',
        RecommendationType.contentShift => 'Content shift',
        RecommendationType.channelFocus => 'Channel focus',
      };

  static RecommendationType fromName(String value) => RecommendationType.values
      .firstWhere((type) => type.name == value);
}

class RecommendationInsight {
  const RecommendationInsight({
    required this.id,
    required this.reportPeriodId,
    required this.type,
    required this.title,
    required this.rationale,
    required this.sourceReferences,
    required this.assignedTo,
  });

  final String id;
  final String reportPeriodId;
  final RecommendationType type;
  final String title;
  final String rationale;
  final List<String> sourceReferences;
  final String assignedTo;

  RecommendationInsight copyWith({
    String? id,
    String? reportPeriodId,
    RecommendationType? type,
    String? title,
    String? rationale,
    List<String>? sourceReferences,
    String? assignedTo,
  }) {
    return RecommendationInsight(
      id: id ?? this.id,
      reportPeriodId: reportPeriodId ?? this.reportPeriodId,
      type: type ?? this.type,
      title: title ?? this.title,
      rationale: rationale ?? this.rationale,
      sourceReferences: sourceReferences ?? this.sourceReferences,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reportPeriodId': reportPeriodId,
        'type': type.name,
        'title': title,
        'rationale': rationale,
        'sourceReferences': sourceReferences,
        'assignedTo': assignedTo,
      };

  factory RecommendationInsight.fromJson(Map<String, dynamic> json) =>
      RecommendationInsight(
        id: json['id'] as String,
        reportPeriodId: json['reportPeriodId'] as String,
        type: RecommendationTypeX.fromName(json['type'] as String),
        title: json['title'] as String,
        rationale: json['rationale'] as String,
        sourceReferences:
            (json['sourceReferences'] as List<dynamic>).cast<String>().toList(),
        assignedTo: json['assignedTo'] as String,
      );
}
