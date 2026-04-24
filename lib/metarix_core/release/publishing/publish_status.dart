enum PublishStatus {
  draft,
  validationFailed,
  pendingApproval,
  approved,
  scheduled,
  queued,
  publishing,
  published,
  failed,
  canceled,
  unsupported,
}

extension PublishStatusX on PublishStatus {
  static PublishStatus fromName(String? value) {
    return PublishStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => PublishStatus.draft,
    );
  }
}


