import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../models/task.dart';
import '../providers/project_provider.dart';
import '../theme/app_theme.dart';

class CreateTaskDialog extends StatefulWidget {
  final TaskStatus initialStatus;
  final Task? initialParentTask;

  const CreateTaskDialog({
    super.key,
    this.initialStatus = TaskStatus.todo,
    this.initialParentTask,
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
  String _selectedAssignee = 'Ahmet Selim';
  Task? _selectedParentTask;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProjectProvider>();
    _selectedAssignee = provider.currentUserName;
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _tagsController = TextEditingController();
    _selectedStatus = widget.initialStatus;
    _selectedParentTask = widget.initialParentTask;
    if (_selectedParentTask != null) {
      _selectedType = TaskType.subtask;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _insertFormatting(String prefix, [String suffix = '']) {
    final text = _descController.text;
    final selection = _descController.selection;
    if (selection.start < 0 || selection.end < 0) {
      _descController.text = '$text$prefix$suffix';
      return;
    }
    final selectedText = selection.textInside(text);
    final replacement = '$prefix$selectedText$suffix';
    final newText = selection.textBefore(text) + replacement + selection.textAfter(text);

    _descController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + prefix.length + selectedText.length + (suffix.isEmpty ? 0 : suffix.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProjectProvider>();
    final activeProject = provider.selectedProject;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 880,
        height: MediaQuery.of(context).size.height * 0.82,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Remix.add_box_fill, color: primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yeni Görev Ekleyin',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Proje: ${activeProject?.name ?? ''} (${activeProject?.key ?? ''})',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Remix.close_line, size: 20),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Kapat',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.lightBorder),
            const SizedBox(height: 16),

            // Modal Body: 2 Columns
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT COLUMN: Title & Rich Text Description (62% width)
                  Expanded(
                    flex: 62,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Input Section
                          Text(
                            'GÖREV BAŞLIĞI *',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _titleController,
                            autofocus: true,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: 'Örn: Sürükle bırak özelliğini test et',
                              filled: true,
                              fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Rich Text Header & Toolbar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'AÇIKLAMA (ZENGİN METİN)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Text(
                                'Markdown Destekli',
                                style: TextStyle(fontSize: 10, color: AppColors.accent),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Rich Text Formatting Bar
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightCard,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                            ),
                            child: Wrap(
                              spacing: 2,
                              children: [
                                _FormatIconButton(
                                  icon: Remix.bold,
                                  tooltip: 'Kalın (**metin**)',
                                  onPressed: () => _insertFormatting('**', '**'),
                                ),
                                _FormatIconButton(
                                  icon: Remix.italic,
                                  tooltip: 'İtalik (*metin*)',
                                  onPressed: () => _insertFormatting('*', '*'),
                                ),
                                _FormatIconButton(
                                  icon: Remix.h_1,
                                  tooltip: 'Başlık (# Başlık)',
                                  onPressed: () => _insertFormatting('# '),
                                ),
                                _FormatIconButton(
                                  icon: Remix.code_line,
                                  tooltip: 'Kod Satırı (`kod`)',
                                  onPressed: () => _insertFormatting('`', '`'),
                                ),
                                _FormatIconButton(
                                  icon: Remix.list_unordered,
                                  tooltip: 'Liste (- madde)',
                                  onPressed: () => _insertFormatting('\n- '),
                                ),
                                _FormatIconButton(
                                  icon: Remix.double_quotes_l,
                                  tooltip: 'Alıntı (> metin)',
                                  onPressed: () => _insertFormatting('\n> '),
                                ),
                                _FormatIconButton(
                                  icon: Remix.link,
                                  tooltip: 'Bağlantı ([Metin](url))',
                                  onPressed: () => _insertFormatting('[Bağlantı Metni](https://)'),
                                ),
                                _FormatIconButton(
                                  icon: Remix.code_box_line,
                                  tooltip: 'Kod Bloğu (```)',
                                  onPressed: () => _insertFormatting('\n```\n', '\n```\n'),
                                ),
                              ],
                            ),
                          ),

                          // Description TextArea
                          TextField(
                            controller: _descController,
                            maxLines: 12,
                            minLines: 8,
                            style: const TextStyle(fontSize: 13, height: 1.4),
                            decoration: InputDecoration(
                              hintText: 'Detaylı görev açıklamasını buraya yazabilirsiniz...\n- Markdown biçimlendirmesi desteklenmektedir.\n- Kod blokları, listeler ve alıntılar kullanabilirsiniz.',
                              filled: true,
                              fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                              contentPadding: const EdgeInsets.all(12),
                              border: OutlineInputBorder(
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  VerticalDivider(width: 1, color: isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.lightBorder),
                  const SizedBox(width: 20),

                  // RIGHT COLUMN: Parameters & Attributes (38% width)
                  Expanded(
                    flex: 38,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Assignee Dropdown
                          const Text(
                            'ATANAN KİŞİ & POZİSYON',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          // Assignee Dropdown (Filtered by Project Team)
                          Builder(
                            builder: (context) {
                              final availableMembers = (activeProject != null && activeProject.memberNames.isNotEmpty)
                                  ? provider.teamMembers.where((m) => activeProject.memberNames.contains(m.name)).toList()
                                  : provider.teamMembers;
                              final memberList = availableMembers.isNotEmpty ? availableMembers : provider.teamMembers;

                              final currentAssignee = memberList.any((m) => m.name == _selectedAssignee)
                                  ? _selectedAssignee
                                  : memberList.first.name;

                              return DropdownButtonFormField<String>(
                                initialValue: currentAssignee,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                items: memberList.map((member) {
                                  return DropdownMenuItem(
                                    value: member.name,
                                    child: Text(
                                      '${member.name} — [${member.title.label}]',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedAssignee = val);
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Status Dropdown
                          const Text(
                            'GÖREV DURUMU',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<TaskStatus>(
                            initialValue: _selectedStatus,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
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
                          const SizedBox(height: 16),

                          // Priority Dropdown
                          const Text(
                            'ÖNCELİK SEVİYESİ',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<TaskPriority>(
                            initialValue: _selectedPriority,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedPriority = val);
                            },
                          ),
                          const SizedBox(height: 16),

                          // Type Dropdown
                          const Text(
                            'GÖREV TİPİ',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<TaskType>(
                            initialValue: _selectedType,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: TaskType.values.map((t) {
                              return DropdownMenuItem(
                                value: t,
                                child: Row(
                                  children: [
                                    Icon(t.icon, size: 14, color: t.color),
                                    const SizedBox(width: 6),
                                    Text(t.label, style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedType = val);
                            },
                          ),
                          const SizedBox(height: 16),

                          // Tags Input
                          const Text(
                            'ETİKETLER',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _tagsController,
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              hintText: 'Virgülle ayırın (Örn: ui, auth)',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Due Date Selector
                          const Text(
                            'BİTİŞ TARİHİ (DUE DATE)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          OutlinedButton.icon(
                            icon: const Icon(Remix.calendar_event_line, size: 16),
                            label: Text(
                              _dueDate == null
                                  ? 'Tarih Seçin'
                                  : DateFormat('dd MMMM yyyy', 'tr_TR').format(_dueDate!),
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 42),
                              alignment: Alignment.centerLeft,
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _dueDate ?? DateTime.now(),
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                              );
                              if (picked != null) {
                                setState(() => _dueDate = picked);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Divider(height: 1, color: isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.lightBorder),
            const SizedBox(height: 16),

            // Modal Footer Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Remix.add_line, size: 16),
                  label: const Text('Görev Oluştur'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
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
                      assignee: _selectedAssignee,
                      parentId: _selectedParentTask?.id,
                      parentKey: _selectedParentTask?.taskKey,
                      tags: tags,
                      dueDate: _dueDate,
                    );

                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _FormatIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 16),
      onPressed: onPressed,
      tooltip: tooltip,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
    );
  }
}
