import 'package:flutter/material.dart';
import '../../data/models/task.dart';

/// Displays detailed task information
class TaskDetailView extends StatelessWidget {
  final Task task;

  const TaskDetailView({
    super.key,
    required this.task,
  });

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Task title
        Text(
          task.title,
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        // Task description
        if (task.description != null && task.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              task.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        // Info rows
        _buildInfoRow(
          context,
          icon: Icons.list,
          label: 'List',
          value: task.taskList.value?.name ?? 'Unknown',
        ),
        _buildInfoRow(
          context,
          icon: Icons.priority_high,
          label: 'Priority',
          value: task.priority.name.toUpperCase(),
        ),
        if (task.startTime != null)
          _buildInfoRow(
            context,
            icon: Icons.schedule,
            label: 'Start Time',
            value: _formatDateTime(task.startTime),
          ),
        if (task.endTime != null)
          _buildInfoRow(
            context,
            icon: Icons.timelapse,
            label: 'End Time',
            value: _formatDateTime(task.endTime),
          ),
        if (task.days != null && task.days!.isNotEmpty)
          _buildInfoRow(
            context,
            icon: Icons.repeat,
            label: 'Repeats',
            value: task.days!.map((d) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1]).join(', '),
          ),
        _buildInfoRow(
          context,
          icon: Icons.create,
          label: 'Created',
          value: _formatDateTime(task.creationTime),
        ),
        if (task.completionTime != null)
          _buildInfoRow(
            context,
            icon: Icons.check_circle,
            label: 'Completed',
            value: _formatDateTime(task.completionTime),
          ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}