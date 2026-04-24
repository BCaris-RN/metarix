import '../common/release_helpers.dart';

class PublishAttempt {
  const PublishAttempt({
    required this.id,
    required this.createdAtIso,
    required this.updatedAtIso,
    required this.attemptNumber,
    required this.startedAtIso,
    required this.endedAtIso,
    required this.success,
    required this.errorCode,
    required this.userMessage,
    required this.technicalMessage,
    required this.retryable,
  });

  final String id;
  final String createdAtIso;
  final String updatedAtIso;
  final int attemptNumber;
  final String? startedAtIso;
  final String? endedAtIso;
  final bool success;
  final String? errorCode;
  final String? userMessage;
  final String? technicalMessage;
  final bool retryable;

  PublishAttempt copyWith({
    String? id,
    String? createdAtIso,
    String? updatedAtIso,
    int? attemptNumber,
    String? startedAtIso,
    bool clearStartedAtIso = false,
    String? endedAtIso,
    bool clearEndedAtIso = false,
    bool? success,
    String? errorCode,
    bool clearErrorCode = false,
    String? userMessage,
    bool clearUserMessage = false,
    String? technicalMessage,
    bool clearTechnicalMessage = false,
    bool? retryable,
  }) {
    return PublishAttempt(
      id: id ?? this.id,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      startedAtIso: clearStartedAtIso ? null : startedAtIso ?? this.startedAtIso,
      endedAtIso: clearEndedAtIso ? null : endedAtIso ?? this.endedAtIso,
      success: success ?? this.success,
      errorCode: clearErrorCode ? null : errorCode ?? this.errorCode,
      userMessage: clearUserMessage ? null : userMessage ?? this.userMessage,
      technicalMessage: clearTechnicalMessage
          ? null
          : technicalMessage ?? this.technicalMessage,
      retryable: retryable ?? this.retryable,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'createdAtIso': createdAtIso,
        'updatedAtIso': updatedAtIso,
        'attemptNumber': attemptNumber,
        'startedAtIso': startedAtIso,
        'endedAtIso': endedAtIso,
        'success': success,
        'errorCode': errorCode,
        'userMessage': userMessage,
        'technicalMessage': technicalMessage,
        'retryable': retryable,
      };

  factory PublishAttempt.fromJson(Map<String, Object?> json) {
    return PublishAttempt(
      id: stringOrFallback(json['id'], 'attempt-local'),
      createdAtIso: isoOrNow(json['createdAtIso']),
      updatedAtIso: isoOrNow(json['updatedAtIso']),
      attemptNumber: json['attemptNumber'] is int ? json['attemptNumber'] as int : 0,
      startedAtIso: json['startedAtIso'] as String?,
      endedAtIso: json['endedAtIso'] as String?,
      success: json['success'] == true,
      errorCode: json['errorCode'] as String?,
      userMessage: json['userMessage'] as String?,
      technicalMessage: json['technicalMessage'] as String?,
      retryable: json['retryable'] == true,
    );
  }
}


