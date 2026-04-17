class MetarixLocalConfigRef {
  const MetarixLocalConfigRef({
    required this.profileName,
    required this.description,
    required this.runtimeHint,
  });

  final String profileName;
  final String description;
  final String runtimeHint;

  Map<String, dynamic> toJson() => {
    'profileName': profileName,
    'description': description,
    'runtimeHint': runtimeHint,
  };

  factory MetarixLocalConfigRef.fromJson(Map<String, dynamic> json) =>
      MetarixLocalConfigRef(
        profileName: json['profileName'] as String,
        description: json['description'] as String,
        runtimeHint: json['runtimeHint'] as String,
      );
}
