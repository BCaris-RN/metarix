import '../metarix_core/models/connector_runtime_state.dart';

enum BackendMode { demo, supabaseRest }

class BackendConfig {
  const BackendConfig({
    required this.mode,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.linkedinClientIdValue = linkedinClientId,
    this.linkedinClientSecretValue = linkedinClientSecret,
    this.linkedinRedirectUriValue = linkedinRedirectUri,
    this.linkedinScopesValue = linkedinScopes,
  });

  static const String linkedinClientId = String.fromEnvironment(
    'LINKEDIN_CLIENT_ID',
    defaultValue: '',
  );
  static const String linkedinClientSecret = String.fromEnvironment(
    'LINKEDIN_CLIENT_SECRET',
    defaultValue: '',
  );
  static const String linkedinRedirectUri = String.fromEnvironment(
    'LINKEDIN_REDIRECT_URI',
    defaultValue: '',
  );
  static const String linkedinScopes = String.fromEnvironment(
    'LINKEDIN_SCOPES',
    defaultValue: 'openid profile email w_member_social',
  );

  final BackendMode mode;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String linkedinClientIdValue;
  final String linkedinClientSecretValue;
  final String linkedinRedirectUriValue;
  final String linkedinScopesValue;

  factory BackendConfig.fromEnvironment() {
    const modeName = String.fromEnvironment(
      'METARIX_BACKEND_MODE',
      defaultValue: 'demo',
    );
    final mode = switch (modeName) {
      'supabase_rest' => BackendMode.supabaseRest,
      _ => BackendMode.demo,
    };

    return BackendConfig(
      mode: mode,
      supabaseUrl: const String.fromEnvironment(
        'METARIX_SUPABASE_URL',
        defaultValue: '',
      ),
      supabaseAnonKey: const String.fromEnvironment(
        'METARIX_SUPABASE_ANON_KEY',
        defaultValue: '',
      ),
    );
  }

  bool get isRemoteEnabled =>
      mode == BackendMode.supabaseRest &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;

  static bool get linkedinConfigured =>
      linkedinClientId.trim().isNotEmpty &&
      linkedinRedirectUri.trim().isNotEmpty;

  bool get isLinkedInConfigured =>
      linkedinClientIdValue.trim().isNotEmpty &&
      linkedinRedirectUriValue.trim().isNotEmpty;

  List<String> get linkedInScopes => linkedinScopesValue
      .split(RegExp(r'\s+'))
      .where((scope) => scope.trim().isNotEmpty)
      .toList(growable: false);

  ConnectorRuntimeState linkedInRuntimeState({bool connected = false}) {
    if (!isLinkedInConfigured) {
      return ConnectorRuntimeState(
        platformKey: 'linkedin',
        availability: ConnectorAvailabilityState.notConfigured,
        clientIdPresent: linkedinClientIdValue.trim().isNotEmpty,
        redirectUriPresent: linkedinRedirectUriValue.trim().isNotEmpty,
        secretPresent: linkedinClientSecretValue.trim().isNotEmpty,
        note: 'LinkedIn runtime configuration is incomplete.',
      );
    }

    return ConnectorRuntimeState(
      platformKey: 'linkedin',
      availability: connected
          ? ConnectorAvailabilityState.connected
          : ConnectorAvailabilityState.configured,
      clientIdPresent: linkedinClientIdValue.trim().isNotEmpty,
      redirectUriPresent: linkedinRedirectUriValue.trim().isNotEmpty,
      secretPresent: linkedinClientSecretValue.trim().isNotEmpty,
      note: connected
          ? 'LinkedIn connector is configured and connected.'
          : 'LinkedIn connector is configured but not yet connected.',
    );
  }

  static ConnectorRuntimeState linkedinRuntimeState({bool connected = false}) {
    if (!linkedinConfigured) {
      return ConnectorRuntimeState(
        platformKey: 'linkedin',
        availability: ConnectorAvailabilityState.notConfigured,
        clientIdPresent: linkedinClientId.trim().isNotEmpty,
        redirectUriPresent: linkedinRedirectUri.trim().isNotEmpty,
        secretPresent: linkedinClientSecret.trim().isNotEmpty,
        note: 'LinkedIn runtime configuration is incomplete.',
      );
    }

    return ConnectorRuntimeState(
      platformKey: 'linkedin',
      availability: connected
          ? ConnectorAvailabilityState.connected
          : ConnectorAvailabilityState.configured,
      clientIdPresent: linkedinClientId.trim().isNotEmpty,
      redirectUriPresent: linkedinRedirectUri.trim().isNotEmpty,
      secretPresent: linkedinClientSecret.trim().isNotEmpty,
      note: connected
          ? 'LinkedIn connector is configured and connected.'
          : 'LinkedIn connector is configured but not yet connected.',
    );
  }
}
