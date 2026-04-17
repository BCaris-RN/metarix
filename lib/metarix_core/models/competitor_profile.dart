import 'model_types.dart';

class CompetitorProfile {
  const CompetitorProfile({
    required this.competitorId,
    required this.name,
    required this.platforms,
    required this.handles,
    required this.notes,
  });

  final String competitorId;
  final String name;
  final List<SocialPlatform> platforms;
  final Map<SocialPlatform, String> handles;
  final String notes;

  CompetitorProfile copyWith({
    String? competitorId,
    String? name,
    List<SocialPlatform>? platforms,
    Map<SocialPlatform, String>? handles,
    String? notes,
  }) {
    return CompetitorProfile(
      competitorId: competitorId ?? this.competitorId,
      name: name ?? this.name,
      platforms: platforms ?? this.platforms,
      handles: handles ?? this.handles,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'competitorId': competitorId,
    'name': name,
    'platforms': platforms.map((platform) => platform.name).toList(),
    'handles': {
      for (final entry in handles.entries) entry.key.name: entry.value,
    },
    'notes': notes,
  };

  factory CompetitorProfile.fromJson(Map<String, dynamic> json) =>
      CompetitorProfile(
        competitorId: json['competitorId'] as String,
        name: json['name'] as String,
        platforms: (json['platforms'] as List<dynamic>)
            .cast<String>()
            .map(SocialPlatformX.fromName)
            .toList(),
        handles: (json['handles'] as Map<String, dynamic>).map(
          (key, value) =>
              MapEntry(SocialPlatformX.fromName(key), value as String),
        ),
        notes: json['notes'] as String,
      );
}
