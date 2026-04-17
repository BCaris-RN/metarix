import 'model_types.dart';

class MediaAsset {
  const MediaAsset({
    required this.assetId,
    required this.sourceType,
    required this.originalPath,
    required this.previewPath,
    required this.mimeType,
    required this.width,
    required this.height,
    required this.durationMs,
    required this.tags,
    required this.importedAt,
  });

  final String assetId;
  final MediaSourceType sourceType;
  final String originalPath;
  final String previewPath;
  final String mimeType;
  final int width;
  final int height;
  final int? durationMs;
  final List<String> tags;
  final DateTime importedAt;

  MediaAsset copyWith({
    String? assetId,
    MediaSourceType? sourceType,
    String? originalPath,
    String? previewPath,
    String? mimeType,
    int? width,
    int? height,
    int? durationMs,
    bool clearDurationMs = false,
    List<String>? tags,
    DateTime? importedAt,
  }) {
    return MediaAsset(
      assetId: assetId ?? this.assetId,
      sourceType: sourceType ?? this.sourceType,
      originalPath: originalPath ?? this.originalPath,
      previewPath: previewPath ?? this.previewPath,
      mimeType: mimeType ?? this.mimeType,
      width: width ?? this.width,
      height: height ?? this.height,
      durationMs: clearDurationMs ? null : durationMs ?? this.durationMs,
      tags: tags ?? this.tags,
      importedAt: importedAt ?? this.importedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'assetId': assetId,
    'sourceType': sourceType.name,
    'originalPath': originalPath,
    'previewPath': previewPath,
    'mimeType': mimeType,
    'width': width,
    'height': height,
    'durationMs': durationMs,
    'tags': tags,
    'importedAt': importedAt.toIso8601String(),
  };

  factory MediaAsset.fromJson(Map<String, dynamic> json) => MediaAsset(
    assetId: json['assetId'] as String,
    sourceType: MediaSourceTypeX.fromName(json['sourceType'] as String),
    originalPath: json['originalPath'] as String,
    previewPath: json['previewPath'] as String,
    mimeType: json['mimeType'] as String,
    width: json['width'] as int,
    height: json['height'] as int,
    durationMs: json['durationMs'] as int?,
    tags: (json['tags'] as List<dynamic>).cast<String>().toList(),
    importedAt: DateTime.parse(json['importedAt'] as String),
  );
}
