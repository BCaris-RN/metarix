import 'content_asset.dart';

class ContentAssetFilters {
  const ContentAssetFilters({
    this.query = '',
    this.status,
    this.platformTargets = const <String>{},
  });

  final String query;
  final AssetStatus? status;
  final Set<String> platformTargets;

  ContentAssetFilters copyWith({
    String? query,
    bool clearQuery = false,
    AssetStatus? status,
    bool clearStatus = false,
    Set<String>? platformTargets,
  }) {
    return ContentAssetFilters(
      query: clearQuery ? '' : query ?? this.query,
      status: clearStatus ? null : status ?? this.status,
      platformTargets: platformTargets ?? this.platformTargets,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'query': query,
        'status': status?.name,
        'platformTargets': platformTargets.toList(),
      };

  factory ContentAssetFilters.fromJson(Map<String, Object?> json) {
    final rawTargets = json['platformTargets'];
    return ContentAssetFilters(
      query: json['query'] is String ? json['query'] as String : '',
      status: AssetStatusX.fromName(json['status'] as String?),
      platformTargets: rawTargets is List
          ? rawTargets.whereType<String>().toSet()
          : <String>{},
    );
  }
}
