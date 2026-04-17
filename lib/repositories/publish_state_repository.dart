import '../features/publish/domain/publish_models.dart';

abstract interface class PublishStateRepository {
  Future<ScheduledPostRecord> saveScheduledPostRecord(
    ScheduledPostRecord record,
  );

  Future<List<ScheduledPostRecord>> listScheduledPostRecords();
}
