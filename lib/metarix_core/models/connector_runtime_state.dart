enum ConnectorAvailabilityState {
  unavailable,
  notConfigured,
  configured,
  connected,
}

class ConnectorRuntimeState {
  const ConnectorRuntimeState({
    required this.platformKey,
    required this.availability,
    this.clientIdPresent = false,
    this.redirectUriPresent = false,
    this.secretPresent = false,
    this.note,
  });

  final String platformKey;
  final ConnectorAvailabilityState availability;
  final bool clientIdPresent;
  final bool redirectUriPresent;
  final bool secretPresent;
  final String? note;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'platformKey': platformKey,
      'availability': availability.name,
      'clientIdPresent': clientIdPresent,
      'redirectUriPresent': redirectUriPresent,
      'secretPresent': secretPresent,
      'note': note,
    };
  }

  factory ConnectorRuntimeState.fromJson(Map<String, Object?> json) {
    return ConnectorRuntimeState(
      platformKey: (json['platformKey'] as String?) ?? '',
      availability: ConnectorAvailabilityState.values.firstWhere(
        (value) => value.name == json['availability'],
        orElse: () => ConnectorAvailabilityState.unavailable,
      ),
      clientIdPresent: (json['clientIdPresent'] as bool?) ?? false,
      redirectUriPresent: (json['redirectUriPresent'] as bool?) ?? false,
      secretPresent: (json['secretPresent'] as bool?) ?? false,
      note: json['note'] as String?,
    );
  }
}
