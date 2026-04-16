import '../features/schedule/domain/schedule_models.dart';

abstract interface class ScheduleRepository {
  Future<ScheduleRecord> saveScheduleRecord(ScheduleRecord record);

  Future<List<ScheduleRecord>> listScheduleRecords();
}
