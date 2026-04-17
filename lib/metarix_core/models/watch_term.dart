import 'model_types.dart';

class WatchTerm {
  const WatchTerm({
    required this.watchTermId,
    required this.term,
    required this.platformScope,
    required this.category,
    required this.booleanQuery,
    required this.isActive,
  });

  final String watchTermId;
  final String term;
  final List<SocialPlatform> platformScope;
  final WatchTermCategory category;
  final String booleanQuery;
  final bool isActive;

  WatchTerm copyWith({
    String? watchTermId,
    String? term,
    List<SocialPlatform>? platformScope,
    WatchTermCategory? category,
    String? booleanQuery,
    bool? isActive,
  }) {
    return WatchTerm(
      watchTermId: watchTermId ?? this.watchTermId,
      term: term ?? this.term,
      platformScope: platformScope ?? this.platformScope,
      category: category ?? this.category,
      booleanQuery: booleanQuery ?? this.booleanQuery,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'watchTermId': watchTermId,
    'term': term,
    'platformScope': platformScope.map((platform) => platform.name).toList(),
    'category': category.name,
    'booleanQuery': booleanQuery,
    'isActive': isActive,
  };

  factory WatchTerm.fromJson(Map<String, dynamic> json) => WatchTerm(
    watchTermId: json['watchTermId'] as String,
    term: json['term'] as String,
    platformScope: (json['platformScope'] as List<dynamic>)
        .cast<String>()
        .map(SocialPlatformX.fromName)
        .toList(),
    category: WatchTermCategoryX.fromName(json['category'] as String),
    booleanQuery: json['booleanQuery'] as String,
    isActive: json['isActive'] as bool,
  );
}
