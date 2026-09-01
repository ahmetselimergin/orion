import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../providers/project_provider.dart';
import '../theme/app_theme.dart';

class ProjectDialog extends StatefulWidget {
  const ProjectDialog({super.key});

  @override
  State<ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<ProjectDialog> {
  final _nameController = TextEditingController();
  final _keyController = TextEditingController();
  final _descController = TextEditingController();

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
  final Set<String> _selectedMembers = {};

  @override
  void initState() {
    super.initState();
    _selectedColor = _colorOptions.first;
    // Default select current user or first team member
    final provider = context.read<ProjectProvider>();
    if (provider.teamMembers.isNotEmpty) {
      _selectedMembers.add(provider.teamMembers.first.name);
    }
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

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      constraints: const BoxConstraints(maxWidth: 580),
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
                  const Row(
                    children: [
                      Icon(Remix.folder_add_fill, color: Color(0xFF6366F1), size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Yeni Proje Oluştur',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

              // Project Name & Key Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _nameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Proje Adı *',
                        hintText: 'Örn: Mobil Uygulama v2',
                      ),
                      onChanged: (val) {
                        if (val.trim().isNotEmpty && _keyController.text.isEmpty) {
                          final words = val.trim().split(' ');
                          if (words.length >= 2) {
                            _keyController.text = (words[0][0] + words[1][0]).toUpperCase();
                          } else if (val.trim().length >= 3) {
                            _keyController.text = val.trim().substring(0, 3).toUpperCase();
                          }
                        }
                      },
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
                        labelText: 'Anahtar (Key) *',
                        hintText: 'Örn: MOB',
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
                  hintText: 'Proje hedefleri ve detayları...',
                ),
              ),
              const SizedBox(height: 16),

              // Color Selection
              const Text(
                'PROJE RENGİ',
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
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(colorVal).withValues(alpha: 0.5),
                                  blurRadius: 6,
                                )
                              ]
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Team Members Selection Section
              const Text(
                'PROJE EKİBİ & KİŞİ ATAMA (MEMBERS)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              const Text(
                'Projeye dahil edilecek ekip üyelerini ve pozisyonlarını seçin:',
                style: TextStyle(fontSize: 11, color: AppColors.darkTextSecondary),
              ),
              const SizedBox(height: 10),

              Container(
                constraints: const BoxConstraints(maxHeight: 180),
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

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Remix.check_line, size: 16),
                    label: const Text('Proje Oluştur'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(_selectedColor),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      final name = _nameController.text.trim();
                      final key = _keyController.text.trim().toUpperCase();

                      if (name.isEmpty || key.isEmpty) return;

                      provider.createProject(
                        name: name,
                        key: key,
                        description: _descController.text,
                        colorValue: _selectedColor,
                        memberNames: _selectedMembers.toList(),
                      );

                      Navigator.pop(context);
                    },
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
