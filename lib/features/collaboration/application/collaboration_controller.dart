import 'package:flutter/foundation.dart';

import '../../../data/local_metarix_gateway.dart';
import '../../../runtime/activity/activity_event.dart';
import '../../../runtime/activity/activity_event_type.dart';
import '../../admin/domain/admin_models.dart';
import '../domain/assignment_record.dart';
import '../domain/comment_record.dart';

class CollaborationController extends ChangeNotifier {
  CollaborationController(this._gateway) {
    _gateway.addListener(notifyListeners);
  }

  final LocalMetarixGateway _gateway;

  List<CommentRecord> commentsFor(String objectType, String objectId) =>
      _gateway.commentsFor(objectType, objectId);

  List<AssignmentRecord> assignmentsFor(String objectType, String objectId) =>
      _gateway.assignmentsFor(objectType, objectId);

  Future<void> addComment(CommentRecord record) async {
    await _gateway.saveCommentRecord(record);
    await _gateway.recordActivityEvent(
      ActivityEvent(
        id: _gateway.createId('activity'),
        workspaceId: _gateway.workspace.id,
        objectType: record.objectType == 'campaign'
            ? ActivityObjectType.campaign
            : ActivityObjectType.draft,
        objectId: record.objectId,
        objectLabel: record.text.split(' ').take(5).join(' '),
        eventType: ActivityEventType.updated,
        eventClass: record.type == CommentType.reviewNote
            ? ActivityEventClass.normalAction
            : ActivityEventClass.systemAction,
        actorUserId: _gateway.currentUser.id,
        actorName: _gateway.currentUser.name,
        reason: '${record.type.label} added to ${record.objectType}.',
        detail: record.text,
        occurredAt: DateTime.now(),
      ),
    );
  }

  Future<void> saveAssignment(AssignmentRecord record) async {
    await _gateway.saveAssignmentRecord(record);
    await _gateway.recordActivityEvent(
      ActivityEvent(
        id: _gateway.createId('activity'),
        workspaceId: _gateway.workspace.id,
        objectType: record.objectType == 'campaign'
            ? ActivityObjectType.campaign
            : ActivityObjectType.draft,
        objectId: record.objectId,
        objectLabel: record.label,
        eventType: ActivityEventType.updated,
        eventClass: ActivityEventClass.normalAction,
        actorUserId: _gateway.currentUser.id,
        actorName: _gateway.currentUser.name,
        reason: 'Assignment updated for ${record.objectType}.',
        detail: record.assigneeRole?.label ?? record.assigneeUserId ?? 'Unassigned',
        occurredAt: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _gateway.removeListener(notifyListeners);
    super.dispose();
  }
}
