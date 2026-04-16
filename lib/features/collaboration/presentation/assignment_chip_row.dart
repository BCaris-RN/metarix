import 'package:flutter/material.dart';

import '../../admin/domain/admin_models.dart';
import '../domain/assignment_record.dart';

class AssignmentChipRow extends StatelessWidget {
  const AssignmentChipRow({
    required this.assignments,
    required this.onAssignRole,
    super.key,
  });

  final List<AssignmentRecord> assignments;
  final ValueChanged<UserRole> onAssignRole;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...assignments.map(
          (assignment) => Chip(
            label: Text(
              '${assignment.label}: ${assignment.assigneeRole?.label ?? assignment.assigneeUserId ?? 'User'}',
            ),
          ),
        ),
        PopupMenuButton<UserRole>(
          itemBuilder: (context) => UserRole.values
              .map(
                (role) => PopupMenuItem<UserRole>(
                  value: role,
                  child: Text('Assign ${role.label}'),
                ),
              )
              .toList(),
          onSelected: onAssignRole,
          child: const Chip(label: Text('Assign next step')),
        ),
      ],
    );
  }
}
