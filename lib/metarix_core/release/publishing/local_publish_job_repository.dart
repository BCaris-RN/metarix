import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../common/release_result.dart';
import 'publish_audit_event.dart';
import 'publish_job.dart';
import 'publish_job_repository.dart';
import 'publish_status.dart';

class LocalPublishJobRepository implements PublishJobRepository {
  LocalPublishJobRepository._(this._preferences);

  static const String _jobsKey = 'metarix.release.publish.jobs.v1';
  static const String _auditKey = 'metarix.release.publish.audit.v1';

  final SharedPreferences _preferences;

  static Future<LocalPublishJobRepository> create() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalPublishJobRepository._(preferences);
  }

  @override
  Future<ReleaseResult<List<PublishJob>>> listJobs(String workspaceId) async {
    try {
      return ReleaseResult<List<PublishJob>>.success(
        _loadJobs()
            .where((job) => job.workspaceId == workspaceId)
            .toList(growable: false),
      );
    } catch (error) {
      return ReleaseResult<List<PublishJob>>.failure(
        errorCode: 'publish.storage_failed',
        userMessage: 'Unable to load publish jobs.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<PublishJob?>> getJob(String jobId) async {
    try {
      for (final job in _loadJobs()) {
        if (job.id == jobId) {
          return ReleaseResult<PublishJob?>.success(job);
        }
      }
      return ReleaseResult<PublishJob?>.success(null);
    } catch (error) {
      return ReleaseResult<PublishJob?>.failure(
        errorCode: 'publish.storage_failed',
        userMessage: 'Unable to load publish job.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<PublishJob>> saveJob(PublishJob job) async {
    try {
      final items = _loadJobs();
      final index = items.indexWhere((entry) => entry.id == job.id);
      if (index >= 0) {
        items[index] = job;
      } else {
        items.add(job);
      }
      await _persistJobs(items);
      return ReleaseResult<PublishJob>.success(job);
    } catch (error) {
      return ReleaseResult<PublishJob>.failure(
        errorCode: 'publish.storage_failed',
        userMessage: 'Unable to save publish job.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<void>> deleteJob(String jobId) async {
    try {
      final items = _loadJobs()..removeWhere((entry) => entry.id == jobId);
      await _persistJobs(items);
      return ReleaseResult<void>.success(null);
    } catch (error) {
      return ReleaseResult<void>.failure(
        errorCode: 'publish.storage_failed',
        userMessage: 'Unable to delete publish job.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<List<PublishJob>>> listJobsByStatus(
    String workspaceId,
    PublishStatus status,
  ) async {
    final jobs = await listJobs(workspaceId);
    if (!jobs.success) {
      return ReleaseResult<List<PublishJob>>.failure(
        errorCode: jobs.errorCode,
        userMessage: jobs.userMessage,
        technicalMessage: jobs.technicalMessage,
        retryable: jobs.retryable,
      );
    }
    return ReleaseResult<List<PublishJob>>.success(
      jobs.value!
          .where((job) => job.publishStatus == status)
          .toList(growable: false),
    );
  }

  @override
  Future<ReleaseResult<List<PublishJob>>> listDueJobs(
    String workspaceId,
    String nowIso,
  ) async {
    final now = DateTime.tryParse(nowIso) ?? DateTime.now().toUtc();
    final jobs = await listJobs(workspaceId);
    if (!jobs.success) {
      return ReleaseResult<List<PublishJob>>.failure(
        errorCode: jobs.errorCode,
        userMessage: jobs.userMessage,
        technicalMessage: jobs.technicalMessage,
        retryable: jobs.retryable,
      );
    }
    return ReleaseResult<List<PublishJob>>.success(
      jobs.value!
          .where(
            (job) =>
                job.publishStatus == PublishStatus.scheduled &&
                (DateTime.tryParse(job.scheduledAtIso) ?? now).isBefore(now),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<ReleaseResult<List<PublishAuditEvent>>> listAuditEvents(
    String jobId,
  ) async {
    try {
      return ReleaseResult<List<PublishAuditEvent>>.success(
        _loadAudit().where((event) => event.jobId == jobId).toList(growable: false),
      );
    } catch (error) {
      return ReleaseResult<List<PublishAuditEvent>>.failure(
        errorCode: 'publish.storage_failed',
        userMessage: 'Unable to load publish audit history.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<PublishAuditEvent>> appendAuditEvent(
    PublishAuditEvent event,
  ) async {
    try {
      final items = _loadAudit()..add(event);
      await _persistAudit(items);
      return ReleaseResult<PublishAuditEvent>.success(event);
    } catch (error) {
      return ReleaseResult<PublishAuditEvent>.failure(
        errorCode: 'publish.storage_failed',
        userMessage: 'Unable to save publish audit history.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  List<PublishJob> _loadJobs() {
    final encoded = _preferences.getString(_jobsKey);
    if (encoded == null || encoded.isEmpty) {
      return <PublishJob>[];
    }
    final decoded = jsonDecode(encoded) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map((item) => PublishJob.fromJson(item))
        .toList(growable: true);
  }

  List<PublishAuditEvent> _loadAudit() {
    final encoded = _preferences.getString(_auditKey);
    if (encoded == null || encoded.isEmpty) {
      return <PublishAuditEvent>[];
    }
    final decoded = jsonDecode(encoded) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map((item) => PublishAuditEvent.fromJson(item))
        .toList(growable: true);
  }

  Future<void> _persistJobs(List<PublishJob> items) async {
    await _preferences.setString(
      _jobsKey,
      jsonEncode(items.map((entry) => entry.toJson()).toList()),
    );
  }

  Future<void> _persistAudit(List<PublishAuditEvent> items) async {
    await _preferences.setString(
      _auditKey,
      jsonEncode(items.map((entry) => entry.toJson()).toList()),
    );
  }
}
