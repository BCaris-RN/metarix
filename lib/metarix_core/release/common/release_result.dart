class ReleaseResult<T> {
  const ReleaseResult({
    required this.success,
    this.value,
    this.errorCode,
    this.userMessage,
    this.technicalMessage,
    this.retryable = false,
  });

  final bool success;
  final T? value;
  final String? errorCode;
  final String? userMessage;
  final String? technicalMessage;
  final bool retryable;

  factory ReleaseResult.success(T value) => ReleaseResult<T>(
        success: true,
        value: value,
      );

  factory ReleaseResult.failure({
    String? errorCode,
    String? userMessage,
    String? technicalMessage,
    bool retryable = false,
  }) =>
      ReleaseResult<T>(
        success: false,
        errorCode: errorCode,
        userMessage: userMessage,
        technicalMessage: technicalMessage,
        retryable: retryable,
      );
}


