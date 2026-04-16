import 'package:flutter/material.dart';

class PolicyVersionCard extends StatelessWidget {
  const PolicyVersionCard({
    required this.title,
    required this.version,
    required this.loadedAtLabel,
    super.key,
  });

  final String title;
  final String version;
  final String loadedAtLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              const SizedBox(height: 8),
              Text(version, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(loadedAtLabel, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
