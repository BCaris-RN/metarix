import '../common/release_helpers.dart';

class ProviderConnectionSummary {
  const ProviderConnectionSummary({
    required this.provider,
    required this.connected,
    required this.workspaceId,
    required this.displayName,
    required this.pageCount,
    required this.connectedAtIso,
    required this.updatedAtIso,
    required this.statusMessage,
  });

  final String provider;
  final bool connected;
  final String workspaceId;
  final String? displayName;
  final int pageCount;
  final String? connectedAtIso;
  final String? updatedAtIso;
  final String? statusMessage;

  factory ProviderConnectionSummary.fromJson(Map<String, Object?> json) {
    return ProviderConnectionSummary(
      provider: stringOrFallback(json['provider'], 'unknown'),
      connected: json['connected'] == true,
      workspaceId: stringOrEmpty(json['workspaceId']),
      displayName: json['summary'] is Map
          ? (json['summary'] as Map)['displayName'] as String?
          : json['displayName'] as String?,
      pageCount: json['summary'] is Map
          ? ((json['summary'] as Map)['pageCount'] as int?) ?? 0
          : (json['pageCount'] as int?) ?? 0,
      connectedAtIso: json['summary'] is Map
          ? (json['summary'] as Map)['connectedAtIso'] as String?
          : json['connectedAtIso'] as String?,
      updatedAtIso: json['summary'] is Map
          ? (json['summary'] as Map)['updatedAtIso'] as String?
          : json['updatedAtIso'] as String?,
      statusMessage: json['statusMessage'] as String? ??
          (json['summary'] is Map ? (json['summary'] as Map)['statusMessage'] as String? : null),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'provider': provider,
        'connected': connected,
        'workspaceId': workspaceId,
        'displayName': displayName,
        'pageCount': pageCount,
        'connectedAtIso': connectedAtIso,
        'updatedAtIso': updatedAtIso,
        'statusMessage': statusMessage,
      };
}
