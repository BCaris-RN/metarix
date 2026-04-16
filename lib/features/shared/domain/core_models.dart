enum SocialChannel {
  instagram,
  facebook,
  x,
  linkedin,
  youtube,
  tiktok,
}

extension SocialChannelX on SocialChannel {
  String get label => switch (this) {
        SocialChannel.instagram => 'Instagram',
        SocialChannel.facebook => 'Facebook',
        SocialChannel.x => 'X',
        SocialChannel.linkedin => 'LinkedIn',
        SocialChannel.youtube => 'YouTube',
        SocialChannel.tiktok => 'TikTok',
      };

  static SocialChannel fromName(String value) =>
      SocialChannel.values.firstWhere((channel) => channel.name == value);
}

class Workspace {
  const Workspace({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;

  Workspace copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };

  factory Workspace.fromJson(Map<String, dynamic> json) => Workspace(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
      );
}

class Brand {
  const Brand({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.voice,
    required this.primaryChannels,
  });

  final String id;
  final String workspaceId;
  final String name;
  final String voice;
  final List<SocialChannel> primaryChannels;

  Brand copyWith({
    String? id,
    String? workspaceId,
    String? name,
    String? voice,
    List<SocialChannel>? primaryChannels,
  }) {
    return Brand(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      voice: voice ?? this.voice,
      primaryChannels: primaryChannels ?? this.primaryChannels,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'name': name,
        'voice': voice,
        'primaryChannels': primaryChannels.map((channel) => channel.name).toList(),
      };

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json['id'] as String,
        workspaceId: json['workspaceId'] as String,
        name: json['name'] as String,
        voice: json['voice'] as String,
        primaryChannels: (json['primaryChannels'] as List<dynamic>)
            .cast<String>()
            .map(SocialChannelX.fromName)
            .toList(),
      );
}

class AssetRef {
  const AssetRef({
    required this.id,
    required this.label,
    required this.kind,
    required this.location,
  });

  final String id;
  final String label;
  final String kind;
  final String location;

  AssetRef copyWith({
    String? id,
    String? label,
    String? kind,
    String? location,
  }) {
    return AssetRef(
      id: id ?? this.id,
      label: label ?? this.label,
      kind: kind ?? this.kind,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'kind': kind,
        'location': location,
      };

  factory AssetRef.fromJson(Map<String, dynamic> json) => AssetRef(
        id: json['id'] as String,
        label: json['label'] as String,
        kind: json['kind'] as String,
        location: json['location'] as String,
      );
}
