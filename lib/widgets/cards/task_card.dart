import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../core/constants/app_colors.dart';

/// Carte affichant une tâche
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final void Function(TaskStatus)? onStatusChanged;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusChanged,
  });

  Color get _statusColor {
    return switch (task.status) {
      TaskStatus.todo => AppColors.statusTodo,
      TaskStatus.inProgress => AppColors.statusInProgress,
      TaskStatus.done => AppColors.statusDone,
    };
  }

  Color get _statusBgColor {
    return switch (task.status) {
      TaskStatus.todo => AppColors.statusTodoBg,
      TaskStatus.inProgress => AppColors.statusInProgressBg,
      TaskStatus.done => AppColors.statusDoneBg,
    };
  }

  Color get _priorityColor {
    return switch (task.priority) {
      TaskPriority.high => AppColors.priorityHigh,
      TaskPriority.medium => AppColors.priorityMedium,
      TaskPriority.low => AppColors.priorityLow,
    };
  }

  IconData get _priorityIcon {
    return switch (task.priority) {
      TaskPriority.high => Icons.arrow_upward_rounded,
      TaskPriority.medium => Icons.remove_rounded,
      TaskPriority.low => Icons.arrow_downward_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == TaskStatus.done;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox rapide
              GestureDetector(
                onTap: () {
                  final next = isDone ? TaskStatus.todo : TaskStatus.done;
                  onStatusChanged?.call(next);
                },
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? AppColors.statusDone : Colors.transparent,
                    border: Border.all(
                      color: isDone ? AppColors.statusDone : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDone
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                        decoration:
                            isDone ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Badge statut
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            task.status.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _statusColor,
                            ),
                          ),
                        ),
                        // Badge priorité
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: _priorityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_priorityIcon,
                                  size: 10, color: _priorityColor),
                              const SizedBox(width: 3),
                              Text(
                                task.priority.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _priorityColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Date d'échéance
                        if (task.dueDate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: task.isOverdue
                                  ? AppColors.error.withOpacity(0.1)
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 10,
                                  color: task.isOverdue
                                      ? AppColors.error
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  DateFormat('dd/MM').format(task.dueDate!),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: task.isOverdue
                                        ? AppColors.error
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
