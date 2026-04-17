import 'model_types.dart';

class WatchedSource {
  const WatchedSource({
    required this.sourceId,
    required this.label,
    required this.sourceType,
    required this.localPathRef,
    required this.isEnabled,
    required this.lastScanAt,
  });

  final String sourceId;
  final String label;
  final MediaSourceType sourceType;
  final String localPathRef;
  final bool isEnabled;
  final DateTime? lastScanAt;

  WatchedSource copyWith({
    String? sourceId,
    String? label,
    MediaSourceType? sourceType,
    String? localPathRef,
    bool? isEnabled,
    DateTime? lastScanAt,
    bool clearLastScanAt = false,
  }) {
    return WatchedSource(
      sourceId: sourceId ?? this.sourceId,
      label: label ?? this.label,
      sourceType: sourceType ?? this.sourceType,
      localPathRef: localPathRef ?? this.localPathRef,
      isEnabled: isEnabled ?? this.isEnabled,
      lastScanAt: clearLastScanAt ? null : lastScanAt ?? this.lastScanAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'sourceId': sourceId,
    'label': label,
    'sourceType': sourceType.name,
    'localPathRef': localPathRef,
    'isEnabled': isEnabled,
    'lastScanAt': lastScanAt?.toIso8601String(),
  };

  factory WatchedSource.fromJson(Map<String, dynamic> json) => WatchedSource(
    sourceId: json['sourceId'] as String,
    label: json['label'] as String,
    sourceType: MediaSourceTypeX.fromName(json['sourceType'] as String),
    localPathRef: json['localPathRef'] as String,
    isEnabled: json['isEnabled'] as bool,
    lastScanAt: json['lastScanAt'] == null
        ? null
        : DateTime.parse(json['lastScanAt'] as String),
  );
}
