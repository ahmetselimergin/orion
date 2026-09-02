import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../models/task.dart';
import '../providers/project_provider.dart';
import '../theme/app_theme.dart';

class TaskDetailPanel extends StatefulWidget {
  final Task task;

  const TaskDetailPanel({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailPanel> createState() => _TaskDetailPanelState();
}

class _TaskDetailPanelState extends State<TaskDetailPanel> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _newSubtaskController;
  late TextEditingController _newTagController;
  late TextEditingController _newCommentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _newSubtaskController = TextEditingController();
    _newTagController = TextEditingController();
    _newCommentController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant TaskDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id) {
      _titleController.text = widget.task.title;
      _descController.text = widget.task.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _newSubtaskController.dispose();
    _newTagController.dispose();
    _newCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          left: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Top Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(widget.task.type.icon, color: widget.task.type.color, size: 18),
                const SizedBox(width: 8),
                Text(
                  widget.task.taskKey,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Remix.delete_bin_line, color: Colors.redAccent, size: 18),
                  onPressed: () => _confirmDeleteTask(context, provider),
                  tooltip: 'Görevi Sil',
                ),
                IconButton(
                  icon: const Icon(Remix.close_line, size: 18),
                  onPressed: () => provider.selectTask(null),
                  tooltip: 'Kapat',
                ),
              ],
            ),
          ),

          // Body Content (Scrollable)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Parent Task Banner (If task is a subtask)
                if (widget.task.isSubtask) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.violet.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.violet.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Remix.corner_down_right_line, size: 16, color: AppColors.violet),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ana Görev: ${widget.task.parentKey ?? ""}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.violet),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            final parent = provider.currentProjectTasks.firstWhere(
                              (t) => t.id == widget.task.parentId,
                              orElse: () => widget.task,
                            );
                            provider.selectTask(parent);
                          },
                          child: const Text(
                            'Ana Göreve Git ➔',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Title Field
                TextField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Görev başlığı...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) {
                    widget.task.title = val;
                    provider.updateTask(widget.task);
                  },
                ),
                const SizedBox(height: 16),

                // Status & Priority Grid
                Row(
                  children: [
                    // Status Dropdown
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DURUM',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<TaskStatus>(
                            initialValue: widget.task.status,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            items: TaskStatus.values.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(s.label, style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                provider.updateTaskStatus(widget.task.id, newStatus);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Priority Dropdown
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ÖNCELİK',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<TaskPriority>(
                            initialValue: widget.task.priority,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            items: TaskPriority.values.map((p) {
                              return DropdownMenuItem(
                                value: p,
                                child: Row(
                                  children: [
                                    Icon(p.icon, size: 14, color: p.color),
                                    const SizedBox(width: 6),
                                    Text(p.label, style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newPriority) {
                              if (newPriority != null) {
                                widget.task.priority = newPriority;
                                provider.updateTask(widget.task);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Assignee & Title Row
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATANAN KİŞİ & POZİSYON (ROLE)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: provider.teamMembers.any((m) => m.name == widget.task.assignee)
                          ? widget.task.assignee
                          : provider.teamMembers.first.name,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: provider.teamMembers.map((member) {
                        return DropdownMenuItem(
                          value: member.name,
                          child: Text(
                            '${member.name} — [${member.title.label}]',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                      onChanged: (newAssignee) {
                        if (newAssignee != null) {
                          widget.task.assignee = newAssignee;
                          provider.updateTask(widget.task);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Description
                Text(
                  'AÇIKLAMA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _descController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Detaylı bir açıklama yazın...',
                  ),
                  onChanged: (val) {
                    widget.task.description = val;
                    provider.updateTask(widget.task);
                  },
                ),
                const SizedBox(height: 20),

                // Subtasks (Checklist)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ALT GÖREVLER (${widget.task.completedSubtasksCount}/${widget.task.subtasks.length})',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    if (widget.task.subtasks.isNotEmpty)
                      Text(
                        '${(widget.task.subtaskProgress * 100).round()}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                  ],
                ),
                if (widget.task.subtasks.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: widget.task.subtaskProgress,
                      minHeight: 6,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                ...widget.task.subtasks.map((st) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Checkbox(
                          value: st.isCompleted,
                          onChanged: (_) {
                            provider.toggleSubTask(widget.task.id, st.id);
                          },
                        ),
                        Expanded(
                          child: Text(
                            st.title,
                            style: TextStyle(
                              fontSize: 13,
                              decoration:
                                  st.isCompleted ? TextDecoration.lineThrough : null,
                              color: st.isCompleted
                                  ? (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary)
                                  : null,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Remix.close_line, size: 14, color: Colors.grey),
                          onPressed: () {
                            provider.deleteSubTask(widget.task.id, st.id);
                          },
                        ),
                      ],
                    ),
                  );
                }),
                // Child Subtasks List (Linked Tasks)
                Builder(
                  builder: (context) {
                    final childTasks = provider.getSubtasksOf(widget.task.id);
                    if (childTasks.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        ...childTasks.map((ct) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Remix.corner_down_right_line, size: 14, color: AppColors.violet),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ct.title,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          decoration: ct.status == TaskStatus.done ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      Text(
                                        '${ct.taskKey} • ${ct.status.label} • ${ct.assignee}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: ct.status.color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => provider.selectTask(ct),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Aç ➔',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newSubtaskController,
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          hintText: 'Yeni alt görev yazıp Enter\'a basın...',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            provider.addSubTask(widget.task.id, val);
                            provider.createSubtask(parentTask: widget.task, title: val);
                            _newSubtaskController.clear();
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Remix.add_line, size: 18),
                      onPressed: () {
                        final val = _newSubtaskController.text;
                        if (val.trim().isNotEmpty) {
                          provider.addSubTask(widget.task.id, val);
                          provider.createSubtask(parentTask: widget.task, title: val);
                          _newSubtaskController.clear();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tags Section
                Text(
                  'ETİKETLER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...widget.task.tags.map((tag) {
                      return Chip(
                        label: Text('#$tag', style: const TextStyle(fontSize: 11)),
                        onDeleted: () {
                          widget.task.tags.remove(tag);
                          provider.updateTask(widget.task);
                        },
                        deleteIcon: const Icon(Remix.close_line, size: 12),
                        visualDensity: VisualDensity.compact,
                      );
                    }),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _newTagController,
                        style: const TextStyle(fontSize: 11),
                        decoration: const InputDecoration(
                          hintText: '+ Etiket',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        ),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty && !widget.task.tags.contains(val.trim())) {
                            widget.task.tags.add(val.trim());
                            provider.updateTask(widget.task);
                            _newTagController.clear();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Comments & Activity Section
                Text(
                  'YORUMLAR (${widget.task.comments.length})',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                ...widget.task.comments.map((comment) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              comment.author,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat('HH:mm - dd MMM', 'tr_TR').format(comment.createdAt),
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment.content,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newCommentController,
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          hintText: 'Bir yorum ekleyin...',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            provider.addComment(widget.task.id, val, author: provider.currentUserName);
                            _newCommentController.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Remix.send_plane_fill, size: 16, color: AppColors.primary),
                      onPressed: () {
                        if (_newCommentController.text.trim().isNotEmpty) {
                          provider.addComment(widget.task.id, _newCommentController.text, author: provider.currentUserName);
                          _newCommentController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTask(BuildContext context, ProjectProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Görevi Sil'),
        content: Text('${widget.task.taskKey} kodlu görevi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.deleteTask(widget.task.id);
              Navigator.pop(context);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
