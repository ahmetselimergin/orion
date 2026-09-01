import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../providers/project_provider.dart';
import '../theme/app_theme.dart';

class ProjectSettingsDialog extends StatefulWidget {
  final Project project;

  const ProjectSettingsDialog({
    super.key,
    required this.project,
  });

  @override
  State<ProjectSettingsDialog> createState() => _ProjectSettingsDialogState();
}

class _ProjectSettingsDialogState extends State<ProjectSettingsDialog> {
  late TextEditingController _nameController;
  late TextEditingController _keyController;
  late TextEditingController _descController;

  final List<int> _colorOptions = [
    0xFF6366F1, // Indigo
    0xFF06B6D4, // Cyan
    0xFF10B981, // Emerald
    0xFFF59E0B, // Amber
    0xFFEF4444, // Red
    0xFF8B5CF6, // Purple
    0xFFEC4899, // Pink
  ];
  late int _selectedColor;
  late Set<String> _selectedMembers;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _keyController = TextEditingController(text: widget.project.key);
    _descController = TextEditingController(text: widget.project.description);
    _selectedColor = widget.project.colorValue;
    _selectedMembers = Set.from(widget.project.memberNames);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final projectTasks = provider.allTasks.where((t) => t.projectId == widget.project.id).toList();
    final completedTasks = projectTasks.where((t) => t.status == TaskStatus.done).length;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      constraints: const BoxConstraints(maxWidth: 640),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(_selectedColor).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Remix.settings_4_fill, color: Color(_selectedColor), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${widget.project.name} — Proje Ayarları',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Project Quick Stats
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBadge(
                      label: 'Ekip Üyeleri',
                      value: '${_selectedMembers.length} Kişi',
                      icon: Remix.team_line,
                    ),
                    _StatBadge(
                      label: 'Toplam Görev',
                      value: '${projectTasks.length} Görev',
                      icon: Remix.checkbox_circle_line,
                    ),
                    _StatBadge(
                      label: 'Tamamlanan',
                      value: '${projectTasks.isNotEmpty ? ((completedTasks / projectTasks.length) * 100).round() : 0}%',
                      icon: Remix.check_double_line,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Name & Key
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Proje Adı',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _keyController,
                      maxLength: 5,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Anahtar (Key)',
                        counterText: '',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Description
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                ),
              ),
              const SizedBox(height: 16),

              // Color Selection
              const Text(
                'PROJE TEMA RENGİ',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: _colorOptions.map((colorVal) {
                  final isSelected = _selectedColor == colorVal;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = colorVal),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Color(colorVal),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Team Member Assignment Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PROJE EKİBİ & KİŞİ ATAMA',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  Text(
                    '${_selectedMembers.length} Üye Seçildi',
                    style: const TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: provider.teamMembers.length,
                  separatorBuilder: (_, _) => Divider(height: 1, color: isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.lightBorder),
                  itemBuilder: (context, index) {
                    final member = provider.teamMembers[index];
                    final isChecked = _selectedMembers.contains(member.name);

                    return CheckboxListTile(
                      value: isChecked,
                      dense: true,
                      activeColor: Color(_selectedColor),
                      title: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Color(_selectedColor).withValues(alpha: 0.2),
                            child: Text(
                              member.name[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(_selectedColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            member.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              member.title.label,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accent),
                            ),
                          ),
                        ],
                      ),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedMembers.add(member.name);
                          } else {
                            if (_selectedMembers.length > 1) {
                              _selectedMembers.remove(member.name);
                            }
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Danger Zone: Delete Project
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    icon: const Icon(Remix.delete_bin_line, color: Colors.redAccent, size: 16),
                    label: const Text('Projeyi Sil', style: TextStyle(color: Colors.redAccent)),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Projeyi Sil'),
                          content: Text('${widget.project.name} projesini ve tüm görevlerini silmek istediğinize emin misiniz?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('İptal'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Sil'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        await provider.deleteProject(widget.project.id);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('İptal'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Remix.save_line, size: 16),
                        label: const Text('Ayarları Kaydet'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(_selectedColor),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          widget.project.name = _nameController.text.trim();
                          widget.project.key = _keyController.text.trim().toUpperCase();
                          widget.project.description = _descController.text.trim();
                          widget.project.colorValue = _selectedColor;
                          widget.project.memberNames = _selectedMembers.toList();

                          provider.updateProject(widget.project);
                          Navigator.pop(context);
                        },
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
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accent),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.darkTextSecondary)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
