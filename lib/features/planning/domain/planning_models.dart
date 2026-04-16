import '../../shared/domain/core_models.dart';
import '../../workflow/domain/workflow_models.dart';

class Campaign {
  const Campaign({
    required this.id,
    required this.brandId,
    required this.name,
    required this.summary,
    required this.startDate,
    required this.endDate,
    required this.channels,
    required this.contentPillarId,
  });

  final String id;
  final String brandId;
  final String name;
  final String summary;
  final DateTime startDate;
  final DateTime endDate;
  final List<SocialChannel> channels;
  final String contentPillarId;

  Campaign copyWith({
    String? id,
    String? brandId,
    String? name,
    String? summary,
    DateTime? startDate,
    DateTime? endDate,
    List<SocialChannel>? channels,
    String? contentPillarId,
  }) {
    return Campaign(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      summary: summary ?? this.summary,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      channels: channels ?? this.channels,
      contentPillarId: contentPillarId ?? this.contentPillarId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'name': name,
        'summary': summary,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'channels': channels.map((channel) => channel.name).toList(),
        'contentPillarId': contentPillarId,
      };

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
        id: json['id'] as String,
        brandId: json['brandId'] as String,
        name: json['name'] as String,
        summary: json['summary'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        channels: (json['channels'] as List<dynamic>)
            .cast<String>()
            .map(SocialChannelX.fromName)
            .toList(),
        contentPillarId: json['contentPillarId'] as String,
      );
}

class EvergreenContentItem {
  const EvergreenContentItem({
    required this.id,
    required this.brandId,
    required this.title,
    required this.summary,
    required this.contentPillarId,
    required this.assetRefs,
    required this.suggestedChannels,
  });

  final String id;
  final String brandId;
  final String title;
  final String summary;
  final String contentPillarId;
  final List<AssetRef> assetRefs;
  final List<SocialChannel> suggestedChannels;

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'title': title,
        'summary': summary,
        'contentPillarId': contentPillarId,
        'assetRefs': assetRefs.map((asset) => asset.toJson()).toList(),
        'suggestedChannels':
            suggestedChannels.map((channel) => channel.name).toList(),
      };

  factory EvergreenContentItem.fromJson(Map<String, dynamic> json) =>
      EvergreenContentItem(
        id: json['id'] as String,
        brandId: json['brandId'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
        contentPillarId: json['contentPillarId'] as String,
        assetRefs: (json['assetRefs'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(AssetRef.fromJson)
            .toList(),
        suggestedChannels: (json['suggestedChannels'] as List<dynamic>)
            .cast<String>()
            .map(SocialChannelX.fromName)
            .toList(),
      );
}

class EditorialCalendarDay {
  const EditorialCalendarDay({
    required this.date,
    required this.drafts,
  });

  final DateTime date;
  final List<PostDraft> drafts;
}
