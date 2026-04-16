enum SearchObjectType {
  campaign,
  draft,
  asset,
  report,
  listeningQuery,
  activityEvent,
}

extension SearchObjectTypeX on SearchObjectType {
  String get label => switch (this) {
        SearchObjectType.campaign => 'Campaign',
        SearchObjectType.draft => 'Draft',
        SearchObjectType.asset => 'Asset',
        SearchObjectType.report => 'Report',
        SearchObjectType.listeningQuery => 'Listening query',
        SearchObjectType.activityEvent => 'Activity event',
      };
}

class SearchResultRecord {
  const SearchResultRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.targetSurface,
    required this.objectId,
  });

  final String id;
  final SearchObjectType type;
  final String title;
  final String subtitle;
  final int targetSurface;
  final String objectId;
}
