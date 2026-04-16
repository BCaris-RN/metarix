class ShareOfVoiceSnapshot {
  const ShareOfVoiceSnapshot({
    required this.id,
    required this.label,
    required this.comparisonSet,
    required this.shareByEntity,
    required this.capturedAt,
  });

  final String id;
  final String label;
  final List<String> comparisonSet;
  final Map<String, double> shareByEntity;
  final DateTime capturedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'comparisonSet': comparisonSet,
        'shareByEntity': shareByEntity,
        'capturedAt': capturedAt.toIso8601String(),
      };

  factory ShareOfVoiceSnapshot.fromJson(Map<String, dynamic> json) =>
      ShareOfVoiceSnapshot(
        id: json['id'] as String,
        label: json['label'] as String,
        comparisonSet:
            (json['comparisonSet'] as List<dynamic>).cast<String>().toList(),
        shareByEntity: Map<String, double>.from(
          (json['shareByEntity'] as Map).map(
            (key, value) => MapEntry(key as String, (value as num).toDouble()),
          ),
        ),
        capturedAt: DateTime.parse(json['capturedAt'] as String),
      );
}
