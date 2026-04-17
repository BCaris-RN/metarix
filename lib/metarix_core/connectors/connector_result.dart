class ConnectorResult<T> {
  const ConnectorResult.success({required this.value, this.message})
    : isSuccess = true,
      error = null;

  const ConnectorResult.failure({required this.error, this.message})
    : isSuccess = false,
      value = null;

  final bool isSuccess;
  final T? value;
  final String? error;
  final String? message;
}
