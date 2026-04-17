import 'model_types.dart';

class IntakeRule {
  const IntakeRule({
    required this.ruleId,
    required this.sourceType,
    required this.filenamePattern,
    required this.allowedExtensions,
    required this.groupByDateAndSlug,
  });

  final String ruleId;
  final MediaSourceType sourceType;
  final String filenamePattern;
  final List<String> allowedExtensions;
  final bool groupByDateAndSlug;

  IntakeRule copyWith({
    String? ruleId,
    MediaSourceType? sourceType,
    String? filenamePattern,
    List<String>? allowedExtensions,
    bool? groupByDateAndSlug,
  }) {
    return IntakeRule(
      ruleId: ruleId ?? this.ruleId,
      sourceType: sourceType ?? this.sourceType,
      filenamePattern: filenamePattern ?? this.filenamePattern,
      allowedExtensions: allowedExtensions ?? this.allowedExtensions,
      groupByDateAndSlug: groupByDateAndSlug ?? this.groupByDateAndSlug,
    );
  }

  Map<String, dynamic> toJson() => {
    'ruleId': ruleId,
    'sourceType': sourceType.name,
    'filenamePattern': filenamePattern,
    'allowedExtensions': allowedExtensions,
    'groupByDateAndSlug': groupByDateAndSlug,
  };

  factory IntakeRule.fromJson(Map<String, dynamic> json) => IntakeRule(
    ruleId: json['ruleId'] as String,
    sourceType: MediaSourceTypeX.fromName(json['sourceType'] as String),
    filenamePattern: json['filenamePattern'] as String,
    allowedExtensions: (json['allowedExtensions'] as List<dynamic>)
        .cast<String>()
        .toList(),
    groupByDateAndSlug: json['groupByDateAndSlug'] as bool,
  );
}
