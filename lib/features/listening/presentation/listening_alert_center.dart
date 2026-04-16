import 'package:flutter/material.dart';

import '../domain/listening_alert_rule.dart';
import '../domain/listening_models.dart';

class ListeningAlertCenter extends StatelessWidget {
  const ListeningAlertCenter({
    required this.rules,
    required this.triggeredSpikes,
    super.key,
  });

  final List<ListeningAlertRule> rules;
  final List<SpikeEvent> triggeredSpikes;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alert center', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...rules.map(
              (rule) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(rule.name),
                subtitle: Text(
                  'Threshold ${rule.threshold} • ${rule.smartThresholdPlaceholder ? 'Smart-threshold placeholder' : 'Fixed threshold'}',
                ),
              ),
            ),
            const Divider(),
            if (triggeredSpikes.isEmpty)
              const Text('No spikes crossed an active threshold.')
            else
              ...triggeredSpikes.map(
                (spike) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(spike.headline),
                  subtitle: Text('${spike.mentionCount} mentions • ${spike.sentimentLabel}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
