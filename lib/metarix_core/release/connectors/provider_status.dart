import '../common/release_helpers.dart';

class ProviderStatus {
  const ProviderStatus({
    required this.provider,
    required this.displayName,
    required this.configured,
    required this.redirectUriConfigured,
    required this.scopes,
    required this.missingEnvKeys,
    required this.authBaseUrl,
    required this.tokenUrl,
    required this.docsHint,
  });

  final String provider;
  final String displayName;
  final bool configured;
  final bool redirectUriConfigured;
  final List<String> scopes;
  final List<String> missingEnvKeys;
  final String? authBaseUrl;
  final String? tokenUrl;
  final String docsHint;

  factory ProviderStatus.fromJson(Map<String, Object?> json) {
    return ProviderStatus(
      provider: stringOrFallback(json['provider'], 'unknown'),
      displayName: stringOrFallback(json['displayName'], 'Provider'),
      configured: json['configured'] == true,
      redirectUriConfigured: json['redirectUriConfigured'] == true,
      scopes: stringListFromJson(json['scopes']),
      missingEnvKeys: stringListFromJson(json['missingEnvKeys']),
      authBaseUrl: json['authBaseUrl'] as String?,
      tokenUrl: json['tokenUrl'] as String?,
      docsHint: stringOrEmpty(json['docsHint']),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'provider': provider,
        'displayName': displayName,
        'configured': configured,
        'redirectUriConfigured': redirectUriConfigured,
        'scopes': scopes,
        'missingEnvKeys': missingEnvKeys,
        'authBaseUrl': authBaseUrl,
        'tokenUrl': tokenUrl,
        'docsHint': docsHint,
      };
}
