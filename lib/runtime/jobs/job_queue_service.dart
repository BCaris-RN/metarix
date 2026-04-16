import 'package:flutter/foundation.dart';

import 'job_history_repository.dart';
import 'job_record.dart';
import 'job_status.dart';
import 'job_type.dart';

class JobQueueService extends ChangeNotifier implements JobHistoryRepository {
  JobQueueService._(this._workspaceId, this._jobs);

  factory JobQueueService.seeded(String workspaceId) {
    final now = DateTime.now();
    return JobQueueService._(workspaceId, [
      JobRecord(
        id: 'job-seed-1',
        workspaceId: workspaceId,
        jobType: JobType.schedulePrepare,
        status: JobStatus.completed,
        title: 'Prepare weekly schedule',
        requestedAt: now.subtract(const Duration(hours: 6)),
        startedAt: now.subtract(const Duration(hours: 6)),
        completedAt: now.subtract(const Duration(hours: 5, minutes: 45)),
        objectType: 'draft',
        objectId: 'draft-seed-1',
        outcome: 'Schedule prepared successfully.',
      ),
      JobRecord(
        id: 'job-seed-2',
        workspaceId: workspaceId,
        jobType: JobType.publishAttempt,
        status: JobStatus.blocked,
        title: 'Publish hero post',
        requestedAt: now.subtract(const Duration(hours: 3)),
        objectType: 'draft',
        objectId: 'draft-seed-2',
        details: 'Approval missing at queue time.',
        outcome: 'Blocked by publish boundary.',
      ),
      JobRecord(
        id: 'job-seed-3',
        workspaceId: workspaceId,
        jobType: JobType.reportGenerate,
        status: JobStatus.failed,
        title: 'Generate April report packet',
        requestedAt: now.subtract(const Duration(hours: 1)),
        startedAt: now.subtract(const Duration(hours: 1)),
        completedAt: now.subtract(const Duration(minutes: 50)),
        outcome: 'Report export formatter returned incomplete content.',
      ),
    ]);
  }

  final String _workspaceId;
  final List<JobRecord> _jobs;

  List<JobRecord> get jobs =>
      _jobs.where((job) => job.workspaceId == _workspaceId).toList()
        ..sort((left, right) => right.requestedAt.compareTo(left.requestedAt));

  @override
  List<JobRecord> listJobs({String? workspaceId}) {
    final scope = workspaceId ?? _workspaceId;
    return _jobs.where((job) => job.workspaceId == scope).toList()
      ..sort((left, right) => right.requestedAt.compareTo(left.requestedAt));
  }

  @override
  Future<JobRecord> saveJob(JobRecord job) async {
    final index = _jobs.indexWhere((entry) => entry.id == job.id);
    if (index == -1) {
      _jobs.add(job);
    } else {
      _jobs[index] = job;
    }
    notifyListeners();
    return job;
  }

  @override
  Future<JobRecord?> updateJobStatus(
    String jobId,
    JobStatus status, {
    String? details,
    String? outcome,
  }) async {
    final index = _jobs.indexWhere((entry) => entry.id == jobId);
    if (index == -1) {
      return null;
    }
    final existing = _jobs[index];
    final now = DateTime.now();
    final updated = existing.copyWith(
      status: status,
      startedAt: status == JobStatus.running ? now : existing.startedAt,
      completedAt: status == JobStatus.completed ||
              status == JobStatus.failed ||
              status == JobStatus.blocked
          ? now
          : existing.completedAt,
      details: details,
      outcome: outcome,
    );
    _jobs[index] = updated;
    notifyListeners();
    return updated;
  }

  @override
  Future<JobRecord> queueJob({
    required String workspaceId,
    required JobType jobType,
    required String title,
    String? objectType,
    String? objectId,
    String? details,
  }) async {
    final job = JobRecord(
      id: 'job-${DateTime.now().microsecondsSinceEpoch}',
      workspaceId: workspaceId,
      jobType: jobType,
      status: JobStatus.queued,
      title: title,
      requestedAt: DateTime.now(),
      objectType: objectType,
      objectId: objectId,
      details: details,
    );
    _jobs.add(job);
    notifyListeners();
    return job;
  }
}
