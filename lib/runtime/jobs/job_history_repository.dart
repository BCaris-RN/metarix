import 'job_record.dart';
import 'job_status.dart';
import 'job_type.dart';

abstract interface class JobHistoryRepository {
  List<JobRecord> listJobs({String? workspaceId});

  Future<JobRecord> saveJob(JobRecord job);

  Future<JobRecord?> updateJobStatus(
    String jobId,
    JobStatus status, {
    String? details,
    String? outcome,
  });

  Future<JobRecord> queueJob({
    required String workspaceId,
    required JobType jobType,
    required String title,
    String? objectType,
    String? objectId,
    String? details,
  });
}
