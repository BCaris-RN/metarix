import 'package:flutter/foundation.dart';

import '../../../data/local_metarix_gateway.dart';
import '../../../runtime/activity/activity_event.dart';
import '../../../runtime/activity/activity_event_type.dart';

class ActivityController extends ChangeNotifier {
  ActivityController(this._gateway) {
    _gateway.addListener(notifyListeners);
  }

  final LocalMetarixGateway _gateway;

  List<ActivityEvent> workspaceEvents({
    ActivityObjectType? objectType,
    DateTime? from,
    DateTime? to,
  }) {
    return _gateway.viewActivityEvents(
      workspaceId: _gateway.workspace.id,
      objectType: objectType,
      from: from,
      to: to,
    );
  }

  List<ActivityEvent> objectEvents(
    ActivityObjectType objectType,
    String objectId, {
    DateTime? from,
    DateTime? to,
  }) {
    return _gateway.viewActivityEvents(
      workspaceId: _gateway.workspace.id,
      objectType: objectType,
      objectId: objectId,
      from: from,
      to: to,
    );
  }

  @override
  void dispose() {
    _gateway.removeListener(notifyListeners);
    super.dispose();
  }
}
