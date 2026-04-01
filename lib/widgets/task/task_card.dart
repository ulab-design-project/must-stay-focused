// File: lib/widgets/task/task_card.dart
// TODO: Implement Reusable Task Card Item
// Requirements:
// 1. `class TaskCard extends StatelessWidget`:
//    - Properties: `final Task task`, `final ValueChanged<bool> onComplete`, `final VoidCallback onTap`, `final VoidCallback onLongPress`.
//    - UI: 
//      - Checkbox leading icon for quick complete (FR-17).
//      - Title and short description (expanding on tap).
//      - Visual flair: Add a distinct color glow or bold border if `task.priority == TaskPriority.critical` (FR-15).
//      - Trailing icons: edit/delete actions, or priority indicator.

import 'package:flutter/material.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({super.key});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: false,
        onChanged: (value) {
          // Handle completion logic
        },
      ),
      title: Text('Task Title'),
      subtitle: Text('Short description of the task. Tap to expand.'),
      trailing: Text('priority')
    );
  }
}