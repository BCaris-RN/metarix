import '../../shared/domain/core_models.dart';

class ContentLibraryEntry {
  const ContentLibraryEntry({
    required this.id,
    required this.workspaceId,
    required this.title,
    required this.summary,
    required this.assetIds,
    required this.tags,
    required this.channelTargets,
    required this.campaignId,
    required this.evergreen,
  });

  final String id;
  final String workspaceId;
  final String title;
  final String summary;
  final List<String> assetIds;
  final List<String> tags;
  final List<SocialChannel> channelTargets;
  final String? campaignId;
  final bool evergreen;

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'title': title,
        'summary': summary,
        'assetIds': assetIds,
        'tags': tags,
        'channelTargets': channelTargets.map((entry) => entry.name).toList(),
        'campaignId': campaignId,
        'evergreen': evergreen,
      };

  factory ContentLibraryEntry.fromJson(Map<String, dynamic> json) =>
      ContentLibraryEntry(
        id: json['id'] as String,
        workspaceId: json['workspaceId'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
        assetIds: (json['assetIds'] as List<dynamic>).cast<String>().toList(),
        tags: (json['tags'] as List<dynamic>).cast<String>().toList(),
        channelTargets: (json['channelTargets'] as List<dynamic>)
            .cast<String>()
            .map(SocialChannelX.fromName)
            .toList(),
        campaignId: json['campaignId'] as String?,
        evergreen: json['evergreen'] as bool,
      );
}
