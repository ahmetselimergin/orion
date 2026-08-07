import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../models/task.dart';
import '../providers/project_provider.dart';
import '../theme/app_theme.dart';
import 'task_card.dart';

class KanbanBoard extends StatelessWidget {
  final Function(TaskStatus status) onQuickAddTask;

  const KanbanBoard({
    super.key,
    required this.onQuickAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final tasks = provider.currentProjectTasks;
    const double minColumnWidth = 270.0;
    final totalStatuses = TaskStatus.values.length;
    final totalNeededWidth = minColumnWidth * totalStatuses;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        if (availableWidth >= totalNeededWidth) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: TaskStatus.values.map((status) {
              final columnTasks = tasks.where((t) => t.status == status).toList();
              return Expanded(
                child: _KanbanColumn(
                  status: status,
                  tasks: columnTasks,
                  selectedTaskId: provider.selectedTask?.id,
                  onTaskTap: (task) => provider.selectTask(task),
                  onTaskDropped: (task) => provider.updateTaskStatus(task.id, status),
                  onQuickAddTask: () => onQuickAddTask(status),
                ),
              );
            }).toList(),
          );
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: totalNeededWidth,
              height: constraints.maxHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: TaskStatus.values.map((status) {
                  final columnTasks = tasks.where((t) => t.status == status).toList();
                  return SizedBox(
                    width: minColumnWidth,
                    child: _KanbanColumn(
                      status: status,
                      tasks: columnTasks,
                      selectedTaskId: provider.selectedTask?.id,
                      onTaskTap: (task) => provider.selectTask(task),
                      onTaskDropped: (task) => provider.updateTaskStatus(task.id, status),
                      onQuickAddTask: () => onQuickAddTask(status),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }
      },
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final TaskStatus status;
  final List<Task> tasks;
  final String? selectedTaskId;
  final Function(Task task) onTaskTap;
  final Function(Task task) onTaskDropped;
  final VoidCallback onQuickAddTask;

  const _KanbanColumn({
    required this.status,
    required this.tasks,
    required this.selectedTaskId,
    required this.onTaskTap,
    required this.onTaskDropped,
    required this.onQuickAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) => onTaskDropped(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: isHovered
                ? (isDark ? AppColors.darkCard : AppColors.lightCard)
                : (isDark ? AppColors.darkBackground.withValues(alpha: 0.5) : AppColors.lightCard.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHovered
                  ? status.color
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isHovered ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            children: [
              // Column Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: status.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: status.color.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Remix.add_line, size: 16),
                      onPressed: onQuickAddTask,
                      tooltip: '${status.label} Görevi Ekle',
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              // Cards List
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Görev yok',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(10),
                        itemCount: tasks.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Draggable<Task>(
                            data: task,
                            feedback: SizedBox(
                              width: 230,
                              child: Material(
                                elevation: 12,
                                borderRadius: BorderRadius.circular(12),
                                child: TaskCard(
                                  task: task,
                                  isSelected: true,
                                  onTap: () {},
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: TaskCard(
                                task: task,
                                isSelected: selectedTaskId == task.id,
                                onTap: () => onTaskTap(task),
                              ),
                            ),
                            child: TaskCard(
                              task: task,
                              isSelected: selectedTaskId == task.id,
                              onTap: () => onTaskTap(task),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
