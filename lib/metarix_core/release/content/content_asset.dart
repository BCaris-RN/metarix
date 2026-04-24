import '../common/release_helpers.dart';
import 'content_metadata.dart';

enum AssetStatus { local, uploading, uploaded, failed, archived }

extension AssetStatusX on AssetStatus {
  static AssetStatus fromName(String? value) {
    return AssetStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => AssetStatus.local,
    );
  }
}

class ContentAsset {
  const ContentAsset({
    required this.id,
    required this.workspaceId,
    required this.createdAtIso,
    required this.updatedAtIso,
    required this.localPathOrUri,
    required this.filename,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.status,
    required this.metadata,
    this.remoteUrl,
    this.width,
    this.height,
    this.durationSeconds,
    this.thumbnailUrl,
    this.campaignId,
    List<String>? intendedPlatforms,
    this.note,
  }) : intendedPlatforms = intendedPlatforms ?? const <String>[];

  final String id;
  final String workspaceId;
  final String createdAtIso;
  final String updatedAtIso;
  final String localPathOrUri;
  final String filename;
  final String mimeType;
  final int fileSizeBytes;
  final int? width;
  final int? height;
  final int? durationSeconds;
  final String? thumbnailUrl;
  final String? remoteUrl;
  final String? campaignId;
  final List<String> intendedPlatforms;
  final AssetStatus status;
  final ContentMetadata metadata;
  final String? note;

  // Compatibility aliases for older release-layer call sites.
  String get fileName => filename;
  String? get storageUrl => remoteUrl;
  String? get previewUrl => thumbnailUrl;
  int get sizeBytes => fileSizeBytes;
  List<String> get platformTargets => intendedPlatforms;
  String? get metadataId => metadata.id;

  ContentAsset copyWith({
    String? id,
    String? workspaceId,
    String? createdAtIso,
    String? updatedAtIso,
    String? localPathOrUri,
    String? filename,
    String? mimeType,
    int? fileSizeBytes,
    int? width,
    bool clearWidth = false,
    int? height,
    bool clearHeight = false,
    int? durationSeconds,
    bool clearDurationSeconds = false,
    String? thumbnailUrl,
    bool clearThumbnailUrl = false,
    String? remoteUrl,
    bool clearRemoteUrl = false,
    String? campaignId,
    bool clearCampaignId = false,
    List<String>? intendedPlatforms,
    AssetStatus? status,
    ContentMetadata? metadata,
    String? note,
    bool clearNote = false,
  }) {
    return ContentAsset(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
      localPathOrUri: localPathOrUri ?? this.localPathOrUri,
      filename: filename ?? this.filename,
      mimeType: mimeType ?? this.mimeType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      width: clearWidth ? null : width ?? this.width,
      height: clearHeight ? null : height ?? this.height,
      durationSeconds: clearDurationSeconds
          ? null
          : durationSeconds ?? this.durationSeconds,
      thumbnailUrl: clearThumbnailUrl ? null : thumbnailUrl ?? this.thumbnailUrl,
      remoteUrl: clearRemoteUrl ? null : remoteUrl ?? this.remoteUrl,
      campaignId: clearCampaignId ? null : campaignId ?? this.campaignId,
      intendedPlatforms: intendedPlatforms ?? this.intendedPlatforms,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      note: clearNote ? null : note ?? this.note,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'workspaceId': workspaceId,
        'createdAtIso': createdAtIso,
        'updatedAtIso': updatedAtIso,
        'localPathOrUri': localPathOrUri,
        'filename': filename,
        'mimeType': mimeType,
        'fileSizeBytes': fileSizeBytes,
        'width': width,
        'height': height,
        'durationSeconds': durationSeconds,
        'thumbnailUrl': thumbnailUrl,
        'remoteUrl': remoteUrl,
        'campaignId': campaignId,
        'intendedPlatforms': intendedPlatforms,
        'status': status.name,
        'metadata': metadata.toJson(),
        'note': note,
      };

  factory ContentAsset.fromJson(Map<String, Object?> json) {
    final metadataJson = json['metadata'];
    final fallbackMetadata = ContentMetadata(
      id: stringOrFallback(json['metadataId'], 'metadata-local'),
      createdAtIso: isoOrNow(json['createdAtIso']),
      updatedAtIso: isoOrNow(json['updatedAtIso']),
      title: stringOrEmpty(json['filename'] ?? json['fileName']),
      caption: '',
      description: '',
      tags: const <String>[],
      hashtags: const <String>[],
      altText: null,
      intendedChannel: null,
      notes: json['note'] as String?,
    );
    return ContentAsset(
      id: stringOrFallback(json['id'], 'asset-local'),
      workspaceId: stringOrFallback(json['workspaceId'], 'workspace-local'),
      createdAtIso: isoOrNow(json['createdAtIso']),
      updatedAtIso: isoOrNow(json['updatedAtIso']),
      localPathOrUri: stringOrEmpty(json['localPathOrUri']),
      filename: stringOrFallback(json['filename'] ?? json['fileName'], 'asset.bin'),
      mimeType: stringOrEmpty(json['mimeType']),
      fileSizeBytes: (json['fileSizeBytes'] as int?) ??
          (json['sizeBytes'] as int?) ??
          0,
      width: json['width'] as int?,
      height: json['height'] as int?,
      durationSeconds: json['durationSeconds'] as int?,
      thumbnailUrl: json['thumbnailUrl'] as String? ??
          json['previewUrl'] as String?,
      remoteUrl: json['remoteUrl'] as String? ??
          json['storageUrl'] as String?,
      campaignId: json['campaignId'] as String?,
      intendedPlatforms: stringListFromJson(
        json['intendedPlatforms'] ?? json['platformTargets'],
      ),
      status: AssetStatusX.fromName(json['status'] as String?),
      metadata: metadataJson is Map
          ? ContentMetadata.fromJson(metadataJson.cast<String, Object?>())
          : fallbackMetadata,
      note: json['note'] as String?,
    );
  }
}
