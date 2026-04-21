class LinkedInCallbackResult {
  const LinkedInCallbackResult({
    required this.code,
    required this.state,
    required this.error,
    required this.errorDescription,
  });

  final String? code;
  final String? state;
  final String? error;
  final String? errorDescription;

  bool get hasError => error != null && error!.isNotEmpty;

  bool get hasCode => code != null && code!.isNotEmpty;

  factory LinkedInCallbackResult.fromUri(Uri callbackUri) {
    final params = callbackUri.queryParameters;
    return LinkedInCallbackResult(
      code: params['code'],
      state: params['state'],
      error: params['error'],
      errorDescription: params['error_description'],
    );
  }
}
