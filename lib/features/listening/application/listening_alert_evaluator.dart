import '../domain/listening_alert_rule.dart';
import '../domain/listening_models.dart';

class ListeningAlertEvaluator {
  const ListeningAlertEvaluator();

  List<SpikeEvent> evaluate({
    required List<ListeningAlertRule> rules,
    required List<SpikeEvent> spikes,
  }) {
    final activeRules = rules.where((rule) => rule.active).toList();
    if (activeRules.isEmpty) {
      return const [];
    }

    return spikes.where((spike) {
      return activeRules.any(
        (rule) => rule.queryId == spike.queryId && spike.mentionCount >= rule.threshold,
      );
    }).toList();
  }
}
