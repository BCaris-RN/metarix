import 'package:flutter/material.dart';

import '../shared/domain/core_models.dart';

class ConnectorPosturePanel extends StatelessWidget {
  const ConnectorPosturePanel({
    required this.rows,
    super.key,
  });

  final List<({SocialChannel channel, bool schedule, bool publish, bool analytics})> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Connector posture', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            DataTable(
              columns: const [
                DataColumn(label: Text('Channel')),
                DataColumn(label: Text('Schedule')),
                DataColumn(label: Text('Publish')),
                DataColumn(label: Text('Analytics')),
              ],
              rows: rows
                  .map(
                    (row) => DataRow(
                      cells: [
                        DataCell(Text(row.channel.label)),
                        DataCell(Text(row.schedule ? 'Yes' : 'No')),
                        DataCell(Text(row.publish ? 'Yes' : 'No')),
                        DataCell(Text(row.analytics ? 'Yes' : 'No')),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
