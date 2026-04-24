import '../common/release_helpers.dart';

class ContentMetadata {
  const ContentMetadata({
    required this.id,
    required this.createdAtIso,
    required this.updatedAtIso,
    required this.title,
    required this.caption,
    required this.description,
    required this.tags,
    required this.hashtags,
    required this.altText,
    required this.intendedChannel,
    required this.notes,
  });

  final String id;
  final String createdAtIso;
  final String updatedAtIso;
  final String title;
  final String caption;
  final String description;
  final List<String> tags;
  final List<String> hashtags;
  final String? altText;
  final String? intendedChannel;
  final String? notes;

  ContentMetadata copyWith({
    String? id,
    String? createdAtIso,
    String? updatedAtIso,
    String? title,
    String? caption,
    String? description,
    List<String>? tags,
    List<String>? hashtags,
    String? altText,
    bool clearAltText = false,
    String? intendedChannel,
    bool clearIntendedChannel = false,
    String? notes,
    bool clearNotes = false,
  }) {
    return ContentMetadata(
      id: id ?? this.id,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
      title: title ?? this.title,
      caption: caption ?? this.caption,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      hashtags: hashtags ?? this.hashtags,
      altText: clearAltText ? null : altText ?? this.altText,
      intendedChannel: clearIntendedChannel
          ? null
          : intendedChannel ?? this.intendedChannel,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'createdAtIso': createdAtIso,
        'updatedAtIso': updatedAtIso,
        'title': title,
        'caption': caption,
        'description': description,
        'tags': tags,
        'hashtags': hashtags,
        'altText': altText,
        'intendedChannel': intendedChannel,
        'notes': notes,
      };

  factory ContentMetadata.fromJson(Map<String, Object?> json) {
    return ContentMetadata(
      id: stringOrFallback(json['id'], 'metadata-local'),
      createdAtIso: isoOrNow(json['createdAtIso']),
      updatedAtIso: isoOrNow(json['updatedAtIso']),
      title: stringOrEmpty(json['title']),
      caption: stringOrEmpty(json['caption']),
      description: stringOrEmpty(json['description']),
      tags: stringListFromJson(json['tags']),
      hashtags: stringListFromJson(json['hashtags']),
      altText: json['altText'] as String?,
      intendedChannel: json['intendedChannel'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

