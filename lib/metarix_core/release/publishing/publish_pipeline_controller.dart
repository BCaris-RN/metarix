import 'package:flutter/foundation.dart';

import '../common/release_result.dart';
import '../scheduler/scheduled_post.dart';
import 'publish_audit_event.dart';
import 'publish_job.dart';
import 'publish_pipeline_service.dart';

class PublishPipelineController extends ChangeNotifier {
  PublishPipelineController(this._service);

  final PublishPipelineService _service;

  List<PublishJob> jobs = <PublishJob>[];
  List<PublishAuditEvent> auditEvents = <PublishAuditEvent>[];
  PublishJob? selectedJob;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadJobs(String workspaceId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final jobsResult = await _service.listJobs(workspaceId);
    if (jobsResult.success) {
      jobs = jobsResult.value ?? <PublishJob>[];
      selectedJob = jobs.isEmpty ? null : jobs.first;
      auditEvents = selectedJob == null
          ? <PublishAuditEvent>[]
          : (await _service.listAuditEvents(selectedJob!.id)).value ??
              <PublishAuditEvent>[];
    } else {
      errorMessage = jobsResult.userMessage;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<ReleaseResult<PublishJob>> createJobFromScheduledPost(
    ScheduledPost post,
  ) async {
    final result = await _service.createJobFromScheduledPost(post);
    if (result.success && result.value != null) {
      selectedJob = result.value!;
      jobs = [result.value!, ...jobs.where((job) => job.id != result.value!.id)];
      auditEvents = await _loadAudit(result.value!.id);
      notifyListeners();
    }
    return result;
  }

  Future<ReleaseResult<PublishJob>> queueJob(String jobId) async {
    final result = await _service.queueScheduledJob(jobId);
    await _reload(jobId);
    return result;
  }

  Future<ReleaseResult<List<PublishJob>>> runLocalDueJobs(String workspaceId) async {
    final result = await _service.runLocalDueJobs(
      workspaceId,
      DateTime.now().toUtc().toIso8601String(),
    );
    await loadJobs(workspaceId);
    return result;
  }

  Future<ReleaseResult<PublishJob>> cancelJob(
    String jobId,
    String reason,
  ) async {
    final result = await _service.cancelJob(jobId, reason);
    await _reload(jobId);
    return result;
  }

  void selectJob(PublishJob? job) {
    selectedJob = job;
    if (job != null) {
      _loadAuditForSelection(job.id);
    }
    notifyListeners();
  }

  Future<void> _reload(String jobId) async {
    final found = await _service.getJob(jobId);
    if (found.success && found.value != null) {
      selectedJob = found.value!;
      auditEvents = await _loadAudit(jobId);
    }
    notifyListeners();
  }

  Future<void> _loadAuditForSelection(String jobId) async {
    auditEvents = await _loadAudit(jobId);
  }

  Future<List<PublishAuditEvent>> _loadAudit(String jobId) async {
    final result = await _service.listAuditEvents(jobId);
    return result.value ?? <PublishAuditEvent>[];
  }
}
