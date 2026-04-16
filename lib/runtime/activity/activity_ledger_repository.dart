import 'activity_event.dart';
import 'activity_event_type.dart';

abstract interface class ActivityLedgerRepository {
  Future<void> recordActivityEvent(ActivityEvent event);

  Future<List<ActivityEvent>> queryActivityEvents({
    required String workspaceId,
    ActivityObjectType? objectType,
    String? objectId,
    DateTime? from,
    DateTime? to,
  });
}
