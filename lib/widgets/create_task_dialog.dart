import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../models/task.dart';
import '../providers/project_provider.dart';

class CreateTaskDialog extends StatefulWidget {
  final TaskStatus initialStatus;

  const CreateTaskDialog({
    super.key,
    this.initialStatus = TaskStatus.todo,
  });

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _tagsController;
  late TaskStatus _selectedStatus;
  TaskPriority _selectedPriority = TaskPriority.medium;
  TaskType _selectedType = TaskType.task;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _tagsController = TextEditingController();
    _selectedStatus = widget.initialStatus;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProjectProvider>();
    final activeProject = provider.selectedProject;

    return Dialog(
      constraints: const BoxConstraints(maxWidth: 540),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Remix.add_circle_fill, color: Color(0xFF6366F1), size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Yeni Görev Ekleyin (${activeProject?.key ?? ''})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Remix.close_line, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title Input
            TextField(
              controller: _titleController,
              autofocus: true,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                labelText: 'Görev Başlığı *',
                hintText: 'Örn: Sürükle bırak özelliğini test et',
              ),
            ),
            const SizedBox(height: 14),

            // Description Input
            TextField(
              controller: _descController,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                hintText: 'Görev hakkında detaylar...',
              ),
            ),
            const SizedBox(height: 16),

            // Status, Priority & Type Grid
            Row(
              children: [
                // Status
                Expanded(
                  child: DropdownButtonFormField<TaskStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Durum'),
                    items: TaskStatus.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.label, style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Priority
                Expanded(
                  child: DropdownButtonFormField<TaskPriority>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(labelText: 'Öncelik'),
                    items: TaskPriority.values.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Icon(p.icon, size: 14, color: p.color),
                            const SizedBox(width: 4),
                            Text(p.label, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPriority = val);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Type
                Expanded(
                  child: DropdownButtonFormField<TaskType>(
                    value: _selectedType,
                    decoration: const InputDecoration(labelText: 'Görev Tipi'),
                    items: TaskType.values.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Row(
                          children: [
                            Icon(t.icon, size: 14, color: t.color),
                            const SizedBox(width: 4),
                            Text(t.label, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tags & Due Date Row
            Row(
              children: [
                // Tags
                Expanded(
                  child: TextField(
                    controller: _tagsController,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Etiketler (Virgülle ayırın)',
                      hintText: 'UI, Bug, Critical',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Due Date Selector
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _dueDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade600),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Remix.calendar_line, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _dueDate != null
                              ? DateFormat('dd.MM.yyyy').format(_dueDate!)
                              : 'Teslim Tarihi',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    if (title.isEmpty) return;

                    final tags = _tagsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

                    provider.createTask(
                      title: title,
                      description: _descController.text,
                      status: _selectedStatus,
                      priority: _selectedPriority,
                      type: _selectedType,
                      tags: tags,
                      dueDate: _dueDate,
                    );

                    Navigator.pop(context);
                  },
                  child: const Text('Görev Oluştur'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
