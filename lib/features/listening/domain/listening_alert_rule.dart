class ListeningAlertRule {
  const ListeningAlertRule({
    required this.id,
    required this.queryId,
    required this.name,
    required this.threshold,
    required this.smartThresholdPlaceholder,
    required this.active,
  });

  final String id;
  final String queryId;
  final String name;
  final int threshold;
  final bool smartThresholdPlaceholder;
  final bool active;

  Map<String, dynamic> toJson() => {
        'id': id,
        'queryId': queryId,
        'name': name,
        'threshold': threshold,
        'smartThresholdPlaceholder': smartThresholdPlaceholder,
        'active': active,
      };

  factory ListeningAlertRule.fromJson(Map<String, dynamic> json) =>
      ListeningAlertRule(
        id: json['id'] as String,
        queryId: json['queryId'] as String,
        name: json['name'] as String,
        threshold: json['threshold'] as int,
        smartThresholdPlaceholder: json['smartThresholdPlaceholder'] as bool,
        active: json['active'] as bool,
      );
}
