import '../../shared/domain/core_models.dart';

enum AssetRecordType {
  image,
  video,
  copyBlock,
  template,
  link,
  brandReference,
}

extension AssetRecordTypeX on AssetRecordType {
  String get label => switch (this) {
        AssetRecordType.image => 'Image',
        AssetRecordType.video => 'Video',
        AssetRecordType.copyBlock => 'Copy block',
        AssetRecordType.template => 'Template',
        AssetRecordType.link => 'Link',
        AssetRecordType.brandReference => 'Brand reference',
      };

  static AssetRecordType fromName(String value) => switch (value) {
        'copy_block' => AssetRecordType.copyBlock,
        'brand_reference' => AssetRecordType.brandReference,
        _ => AssetRecordType.values.firstWhere((type) => type.name == value),
      };

  String get storageName => switch (this) {
        AssetRecordType.copyBlock => 'copy_block',
        AssetRecordType.brandReference => 'brand_reference',
        _ => name,
      };
}

class AssetRecord {
  const AssetRecord({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.type,
    required this.tags,
    required this.channels,
    required this.location,
    required this.description,
  });

  final String id;
  final String workspaceId;
  final String name;
  final AssetRecordType type;
  final List<String> tags;
  final List<SocialChannel> channels;
  final String location;
  final String description;

  AssetRef toAssetRef() => AssetRef(
        id: id,
        label: name,
        kind: type.storageName,
        location: location,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'name': name,
        'type': type.storageName,
        'tags': tags,
        'channels': channels.map((entry) => entry.name).toList(),
        'location': location,
        'description': description,
      };

  factory AssetRecord.fromJson(Map<String, dynamic> json) => AssetRecord(
        id: json['id'] as String,
        workspaceId: json['workspaceId'] as String,
        name: json['name'] as String,
        type: AssetRecordTypeX.fromName(json['type'] as String),
        tags: (json['tags'] as List<dynamic>).cast<String>().toList(),
        channels: (json['channels'] as List<dynamic>)
            .cast<String>()
            .map(SocialChannelX.fromName)
            .toList(),
        location: json['location'] as String,
        description: json['description'] as String,
      );
}
