import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isSelected;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtask Parent Link Badge
              if (task.isSubtask) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.violet.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.violet.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Remix.corner_down_right_line, size: 10, color: AppColors.violet),
                      const SizedBox(width: 4),
                      Text(
                        '↳ ${task.parentKey ?? "Ana Görev"}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.violet,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Header: Task Key & Priority
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        task.type.icon,
                        size: 15,
                        color: task.type.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        task.taskKey,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),

                  // Priority Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: task.priority.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: task.priority.color.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          task.priority.icon,
                          size: 11,
                          color: task.priority.color,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          task.priority.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: task.priority.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Tags
              if (task.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: task.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2638) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              // Subtasks Progress Indicator
              if (task.subtasks.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: task.subtaskProgress,
                          backgroundColor: isDark ? const Color(0xFF1E2638) : Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            task.subtaskProgress == 1.0
                                ? AppColors.done
                                : AppColors.primary,
                          ),
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${task.completedSubtasksCount}/${task.subtasks.length}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 10),

              // Footer: Due Date & Assignee Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Due Date
                  if (task.dueDate != null) ...[
                    Row(
                      children: [
                        Icon(
                          Remix.calendar_line,
                          size: 12,
                          color: _getDueDateColor(task.dueDate!),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('d MMM', 'tr_TR').format(task.dueDate!),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getDueDateColor(task.dueDate!),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    const SizedBox.shrink(),

                  // Assignee Avatar
                  Row(
                    children: [
                      if (task.comments.isNotEmpty) ...[
                        Icon(
                          Remix.chat_3_line,
                          size: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${task.comments.length}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Tooltip(
                        message: task.assignee,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 11,
                              backgroundColor: primaryColor.withValues(alpha: 0.2),
                              child: Text(
                                task.assignee.isNotEmpty ? task.assignee[0].toUpperCase() : 'A',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.assignee.split(' ').first,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (due.isBefore(today)) {
      return const Color(0xFFEF4444);
    } else if (due.isAtSameMomentAs(today)) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF64748B);
  }
}
