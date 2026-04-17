enum MetricFamily {
  followers,
  reach,
  impressions,
  engagement,
  clicks,
  views,
  shares,
  comments,
  sentimentScore,
  responseTime,
}

extension MetricFamilyX on MetricFamily {
  String get label => switch (this) {
    MetricFamily.followers => 'Followers',
    MetricFamily.reach => 'Reach',
    MetricFamily.impressions => 'Impressions',
    MetricFamily.engagement => 'Engagement',
    MetricFamily.clicks => 'Clicks',
    MetricFamily.views => 'Views',
    MetricFamily.shares => 'Shares',
    MetricFamily.comments => 'Comments',
    MetricFamily.sentimentScore => 'Sentiment score',
    MetricFamily.responseTime => 'Response time',
  };

  static MetricFamily fromName(String value) => switch (value) {
    'sentiment_score' => MetricFamily.sentimentScore,
    'response_time' => MetricFamily.responseTime,
    _ => MetricFamily.values.firstWhere((family) => family.name == value),
  };

  String get storageName => switch (this) {
    MetricFamily.sentimentScore => 'sentiment_score',
    MetricFamily.responseTime => 'response_time',
    _ => name,
  };
}
