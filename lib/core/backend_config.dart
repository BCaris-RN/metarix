enum BackendMode {
  demo,
  supabaseRest,
}

class BackendConfig {
  const BackendConfig({
    required this.mode,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  final BackendMode mode;
  final String supabaseUrl;
  final String supabaseAnonKey;

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
}
