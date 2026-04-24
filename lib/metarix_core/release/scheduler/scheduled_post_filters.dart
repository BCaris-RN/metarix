import '../publishing/publish_status.dart';

class ScheduledPostFilters {
  const ScheduledPostFilters({
    this.query = '',
    this.status,
  });

  final String query;
  final PublishStatus? status;

  ScheduledPostFilters copyWith({
    String? query,
    bool clearQuery = false,
    PublishStatus? status,
    bool clearStatus = false,
  }) {
    return ScheduledPostFilters(
      query: clearQuery ? '' : query ?? this.query,
      status: clearStatus ? null : status ?? this.status,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'query': query,
        'status': status?.name,
      };

  factory ScheduledPostFilters.fromJson(Map<String, Object?> json) {
    return ScheduledPostFilters(
      query: json['query'] is String ? json['query'] as String : '',
      status: PublishStatusX.fromName(json['status'] as String?),
    );
  }
}
