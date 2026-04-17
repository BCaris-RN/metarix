import 'model_types.dart';

class SmartlinkBlock {
  const SmartlinkBlock({
    required this.blockId,
    required this.type,
    required this.label,
    required this.body,
    required this.linkUrl,
  });

  final String blockId;
  final SmartlinkBlockType type;
  final String label;
  final String? body;
  final String? linkUrl;

  SmartlinkBlock copyWith({
    String? blockId,
    SmartlinkBlockType? type,
    String? label,
    String? body,
    bool clearBody = false,
    String? linkUrl,
    bool clearLinkUrl = false,
  }) {
    return SmartlinkBlock(
      blockId: blockId ?? this.blockId,
      type: type ?? this.type,
      label: label ?? this.label,
      body: clearBody ? null : body ?? this.body,
      linkUrl: clearLinkUrl ? null : linkUrl ?? this.linkUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'blockId': blockId,
    'type': type.name,
    'label': label,
    'body': body,
    'linkUrl': linkUrl,
  };

  factory SmartlinkBlock.fromJson(Map<String, dynamic> json) => SmartlinkBlock(
    blockId: json['blockId'] as String,
    type: SmartlinkBlockTypeX.fromName(json['type'] as String),
    label: json['label'] as String,
    body: json['body'] as String?,
    linkUrl: json['linkUrl'] as String?,
  );
}

class SmartlinkPage {
  const SmartlinkPage({
    required this.pageId,
    required this.slug,
    required this.title,
    required this.heroText,
    required this.themeKey,
    required this.blocks,
    required this.updatedAt,
  });

  final String pageId;
  final String slug;
  final String title;
  final String heroText;
  final String themeKey;
  final List<SmartlinkBlock> blocks;
  final DateTime updatedAt;

  SmartlinkPage copyWith({
    String? pageId,
    String? slug,
    String? title,
    String? heroText,
    String? themeKey,
    List<SmartlinkBlock>? blocks,
    DateTime? updatedAt,
  }) {
    return SmartlinkPage(
      pageId: pageId ?? this.pageId,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      heroText: heroText ?? this.heroText,
      themeKey: themeKey ?? this.themeKey,
      blocks: blocks ?? this.blocks,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'pageId': pageId,
    'slug': slug,
    'title': title,
    'heroText': heroText,
    'themeKey': themeKey,
    'blocks': blocks.map((block) => block.toJson()).toList(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory SmartlinkPage.fromJson(Map<String, dynamic> json) => SmartlinkPage(
    pageId: json['pageId'] as String,
    slug: json['slug'] as String,
    title: json['title'] as String,
    heroText: json['heroText'] as String,
    themeKey: json['themeKey'] as String,
    blocks: (json['blocks'] as List<dynamic>)
        .map(
          (entry) =>
              SmartlinkBlock.fromJson(Map<String, dynamic>.from(entry as Map)),
        )
        .toList(),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}
