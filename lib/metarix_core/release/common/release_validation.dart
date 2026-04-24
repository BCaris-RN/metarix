import 'release_helpers.dart';

bool isSafeNonEmptyString(String? value, {int maxLength = 4096}) {
  final text = value?.trim() ?? '';
  return text.isNotEmpty && text.length <= maxLength;
}

bool isValidIsoDateTime(String? value) {
  return value != null && DateTime.tryParse(value) != null;
}

bool isUrlish(String? value) {
  if (value == null || value.trim().isEmpty) {
    return false;
  }
  return isLikelyUrl(value);
}

bool isCaptionLengthValid(String? value, {int maxLength = 2200}) {
  return (value ?? '').length <= maxLength;
}

bool isValidPlatformTarget(List<String> targets) {
  return targets.isNotEmpty && targets.every(isSafeNonEmptyString);
}

