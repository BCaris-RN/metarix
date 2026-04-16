import 'job_status.dart';
import 'job_type.dart';

class JobRecord {
  const JobRecord({
    required this.id,
    required this.workspaceId,
    required this.jobType,
    required this.status,
    required this.title,
    required this.requestedAt,
    this.startedAt,
    this.completedAt,
    this.objectType,
    this.objectId,
    this.details,
    this.outcome,
  });

  final String id;
  final String workspaceId;
  final JobType jobType;
  final JobStatus status;
  final String title;
  final DateTime requestedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? objectType;
  final String? objectId;
  final String? details;
  final String? outcome;

  JobRecord copyWith({
    JobStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    String? details,
    String? outcome,
  }) {
    return JobRecord(
      id: id,
      workspaceId: workspaceId,
      jobType: jobType,
      status: status ?? this.status,
      title: title,
      requestedAt: requestedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      objectType: objectType,
      objectId: objectId,
      details: details ?? this.details,
      outcome: outcome ?? this.outcome,
    );
  }
}
