import 'package:flutter/foundation.dart';

import '../../../data/local_metarix_gateway.dart';
import '../../../repositories/listening_query_repository.dart';
import '../../../runtime/activity/activity_event.dart';
import '../../../runtime/activity/activity_event_type.dart';
import '../domain/listening_models.dart';

class ListeningController extends ChangeNotifier {
  ListeningController(this._repository, this._gateway) {
    _gateway.addListener(notifyListeners);
  }

  final ListeningQueryRepository _repository;
  final LocalMetarixGateway _gateway;

  ListeningSnapshot get snapshot => ListeningSnapshot(
        queries: _gateway.snapshot.listeningQueries,
        mentions: _gateway.snapshot.mentions,
        spikes: _gateway.snapshot.spikes,
        resultGroups: _gateway.listeningResultGroups(),
        shareOfVoiceSnapshots: _gateway.snapshot.shareOfVoiceSnapshots,
        alertRules: _gateway.snapshot.listeningAlertRules,
        competitorWatch: _gateway.snapshot.competitorWatch,
        sentimentSummary: _gateway.snapshot.sentimentSummary,
      );

  Future<void> saveQuery(ListeningQuery query) async {
    final existing = snapshot.queries.any((entry) => entry.id == query.id);
    await _repository.saveListeningQuery(query);
    await _recordActivity(
      objectType: ActivityObjectType.listeningQuery,
      objectId: query.id,
      objectLabel: query.name,
      eventType: existing ? ActivityEventType.updated : ActivityEventType.created,
      reason: existing
          ? 'Listening query definition was updated.'
          : 'Listening query was created.',
      eventClass: ActivityEventClass.normalAction,
    );
  }

  Future<void> routeMention(Mention mention, InsightAction nextAction) async {
    await _repository.updateMention(
      mention.copyWith(recommendedAction: nextAction),
    );
    await _recordActivity(
      objectType: ActivityObjectType.mention,
      objectId: mention.id,
      objectLabel: mention.source,
      eventType: ActivityEventType.listeningAlert,
      reason: 'Mention routed to ${nextAction.label}.',
      detail: mention.excerpt,
      eventClass: ActivityEventClass.systemAction,
    );
  }

  Future<void> _recordActivity({
    required ActivityObjectType objectType,
    required String objectId,
    required String objectLabel,
    required ActivityEventType eventType,
    required String reason,
    required ActivityEventClass eventClass,
    String? detail,
  }) {
    return _gateway.recordActivityEvent(
      ActivityEvent(
        id: _gateway.createId('activity'),
        workspaceId: _gateway.workspace.id,
        objectType: objectType,
        objectId: objectId,
        objectLabel: objectLabel,
        eventType: eventType,
        eventClass: eventClass,
        actorUserId: _gateway.currentUser.id,
        actorName: _gateway.currentUser.name,
        reason: reason,
        detail: detail,
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
