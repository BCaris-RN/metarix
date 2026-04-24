import '../common/release_result.dart';
import 'publish_audit_event.dart';
import 'publish_job.dart';
import 'publish_status.dart';

abstract class PublishJobRepository {
  Future<ReleaseResult<List<PublishJob>>> listJobs(String workspaceId);
  Future<ReleaseResult<PublishJob?>> getJob(String jobId);
  Future<ReleaseResult<PublishJob>> saveJob(PublishJob job);
  Future<ReleaseResult<void>> deleteJob(String jobId);
  Future<ReleaseResult<List<PublishJob>>> listJobsByStatus(
    String workspaceId,
    PublishStatus status,
  );
  Future<ReleaseResult<List<PublishJob>>> listDueJobs(
    String workspaceId,
    String nowIso,
  );
  Future<ReleaseResult<List<PublishAuditEvent>>> listAuditEvents(String jobId);
  Future<ReleaseResult<PublishAuditEvent>> appendAuditEvent(
    PublishAuditEvent event,
  );
}
