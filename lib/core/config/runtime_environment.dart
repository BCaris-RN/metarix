enum RuntimeEnvironment {
  dev,
  demo,
  productionLike,
}

extension RuntimeEnvironmentX on RuntimeEnvironment {
  String get label => switch (this) {
        RuntimeEnvironment.dev => 'Dev',
        RuntimeEnvironment.demo => 'Demo',
        RuntimeEnvironment.productionLike => 'Production-like',
      };

  static RuntimeEnvironment fromName(String value) => switch (value) {
        'dev' => RuntimeEnvironment.dev,
        'production' || 'production_like' => RuntimeEnvironment.productionLike,
        _ => RuntimeEnvironment.demo,
      };
}
