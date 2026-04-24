String stringOrEmpty(Object? value) => value is String ? value : '';

String stringOrFallback(Object? value, String fallback) =>
    value is String && value.isNotEmpty ? value : fallback;

List<String> stringListFromJson(Object? value) {
  if (value is! List) {
    return const <String>[];
  }
  return value
      .whereType<String>()
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

String isoOrNow(Object? value) {
  final text = value is String ? value : '';
  if (text.isNotEmpty && DateTime.tryParse(text) != null) {
    return DateTime.parse(text).toIso8601String();
  }
  return DateTime.now().toUtc().toIso8601String();
}

DateTime? dateTimeOrNull(Object? value) {
  final text = value is String ? value : '';
  if (text.isEmpty) {
    return null;
  }
  return DateTime.tryParse(text);
}

bool isLikelyUrl(String value) {
  final text = value.trim();
  return text.startsWith('http://') ||
      text.startsWith('https://') ||
      text.startsWith('app://') ||
      text.startsWith('urn:');
}

