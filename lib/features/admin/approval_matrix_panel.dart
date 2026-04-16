import 'package:flutter/material.dart';

class ApprovalMatrixPanel extends StatelessWidget {
  const ApprovalMatrixPanel({
    required this.rows,
    super.key,
  });

  final List<({String channel, String action, String requirement})> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Approval matrix', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...rows.map(
              (row) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${row.channel} - ${row.action}'),
                trailing: Text(row.requirement),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
