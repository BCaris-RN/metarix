enum JobStatus {
  queued,
  running,
  completed,
  blocked,
  failed,
}

extension JobStatusX on JobStatus {
  String get label => switch (this) {
        JobStatus.queued => 'Queued',
        JobStatus.running => 'Running',
        JobStatus.completed => 'Completed',
        JobStatus.blocked => 'Blocked',
        JobStatus.failed => 'Failed',
      };
}
