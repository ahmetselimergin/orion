import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../models/task.dart';
import '../models/user_profile.dart';
import '../providers/project_provider.dart';
import '../theme/app_theme.dart';

class TaskListTable extends StatelessWidget {
  const TaskListTable({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final tasks = provider.currentProjectTasks;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Remix.inbox_line,
              size: 40,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Gösterilecek görev bulunamadı',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                isDark ? AppColors.darkCard : AppColors.lightCard,
              ),
              dataRowMinHeight: 52,
              dataRowMaxHeight: 56,
              columnSpacing: 24,
              horizontalMargin: 16,
              columns: const [
                DataColumn(label: Text('KOD', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('BAŞLIK', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('DURUM', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('ÖNCELİK', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('TİP', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('ALT GÖREVLER', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('ATANAN', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('TESLİM TARİHİ', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: tasks.map((task) {
                final isSelected = provider.selectedTask?.id == task.id;

                return DataRow(
                  selected: isSelected,
                  onSelectChanged: (_) => provider.selectTask(task),
                  cells: [
                    // Key
                    DataCell(
                      Row(
                        children: [
                          Icon(task.type.icon, size: 16, color: task.type.color),
                          const SizedBox(width: 6),
                          Text(
                            task.taskKey,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // Title
                    DataCell(
                      SizedBox(
                        width: 250,
                        child: Text(
                          task.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    // Status Dropdown
                    DataCell(
                      DropdownButton<TaskStatus>(
                        value: task.status,
                        underline: const SizedBox.shrink(),
                        isDense: true,
                        onChanged: (newStatus) {
                          if (newStatus != null) {
                            provider.updateTaskStatus(task.id, newStatus);
                          }
                        },
                        items: TaskStatus.values.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: s.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                s.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: s.color,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Priority Dropdown
                    DataCell(
                      DropdownButton<TaskPriority>(
                        value: task.priority,
                        underline: const SizedBox.shrink(),
                        isDense: true,
                        onChanged: (newPriority) {
                          if (newPriority != null) {
                            task.priority = newPriority;
                            provider.updateTask(task);
                          }
                        },
                        items: TaskPriority.values.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Row(
                              children: [
                                Icon(p.icon, size: 14, color: p.color),
                                const SizedBox(width: 4),
                                Text(
                                  p.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: p.color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Type
                    DataCell(
                      Text(
                        task.type.label,
                        style: TextStyle(fontSize: 12, color: task.type.color),
                      ),
                    ),
                    // Subtasks Progress
                    DataCell(
                      task.subtasks.isNotEmpty
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: LinearProgressIndicator(
                                    value: task.subtaskProgress,
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: AlwaysStoppedAnimation(
                                      task.subtaskProgress == 1.0
                                          ? AppColors.done
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${task.completedSubtasksCount}/${task.subtasks.length}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            )
                          : const Text('-', style: TextStyle(color: Colors.grey)),
                    ),
                    // Assignee & Position Title
                    DataCell(
                      Builder(
                        builder: (context) {
                          final member = provider.teamMembers.firstWhere(
                            (m) => m.name == task.assignee,
                            orElse: () => UserProfile(
                              id: '0',
                              name: task.assignee,
                              email: '',
                              title: UserTitle.frontendDev,
                            ),
                          );

                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                child: Text(
                                  task.assignee.isNotEmpty ? task.assignee[0].toUpperCase() : 'A',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(task.assignee, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 0.5),
                                ),
                                child: Text(
                                  member.title.label,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    // Due Date
                    DataCell(
                      Text(
                        task.dueDate != null
                            ? DateFormat('dd.MM.yyyy').format(task.dueDate!)
                            : '-',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
