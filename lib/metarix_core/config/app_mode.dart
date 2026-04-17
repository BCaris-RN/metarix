enum AppMode { demo, localConnected }

extension AppModeX on AppMode {
  String get label => switch (this) {
    AppMode.demo => 'Demo',
    AppMode.localConnected => 'Local connected',
  };

  static AppMode fromName(String value) =>
      AppMode.values.firstWhere((mode) => mode.name == value);
}
