import 'model_types.dart';

class CaptionVariant {
  const CaptionVariant({
    required this.captionVariantId,
    required this.contentId,
    required this.platform,
    required this.caption,
    required this.hashtags,
    required this.linkUrl,
    required this.callToAction,
    required this.notes,
  });

  final String captionVariantId;
  final String contentId;
  final SocialPlatform platform;
  final String caption;
  final List<String> hashtags;
  final String? linkUrl;
  final String? callToAction;
  final String? notes;

  CaptionVariant copyWith({
    String? captionVariantId,
    String? contentId,
    SocialPlatform? platform,
    String? caption,
    List<String>? hashtags,
    String? linkUrl,
    bool clearLinkUrl = false,
    String? callToAction,
    bool clearCallToAction = false,
    String? notes,
    bool clearNotes = false,
  }) {
    return CaptionVariant(
      captionVariantId: captionVariantId ?? this.captionVariantId,
      contentId: contentId ?? this.contentId,
      platform: platform ?? this.platform,
      caption: caption ?? this.caption,
      hashtags: hashtags ?? this.hashtags,
      linkUrl: clearLinkUrl ? null : linkUrl ?? this.linkUrl,
      callToAction: clearCallToAction
          ? null
          : callToAction ?? this.callToAction,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'captionVariantId': captionVariantId,
    'contentId': contentId,
    'platform': platform.name,
    'caption': caption,
    'hashtags': hashtags,
    'linkUrl': linkUrl,
    'callToAction': callToAction,
    'notes': notes,
  };

  factory CaptionVariant.fromJson(Map<String, dynamic> json) => CaptionVariant(
    captionVariantId: json['captionVariantId'] as String,
    contentId: json['contentId'] as String,
    platform: SocialPlatformX.fromName(json['platform'] as String),
    caption: json['caption'] as String,
    hashtags: (json['hashtags'] as List<dynamic>).cast<String>().toList(),
    linkUrl: json['linkUrl'] as String?,
    callToAction: json['callToAction'] as String?,
    notes: json['notes'] as String?,
  );
}
