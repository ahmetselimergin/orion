import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../providers/project_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedColor = _colorOptions.first;
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
    return Dialog(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Remix.folder_add_line, color: Color(0xFF6366F1), size: 20),
                SizedBox(width: 10),
                Text(
                  'Yeni Proje Oluştur',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name
            TextField(
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
            const SizedBox(height: 12),

            // Key
            TextField(
              controller: _keyController,
              maxLength: 5,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Proje Anahtarı (Key) *',
                hintText: 'Örn: MOB, APP, ORI',
                helperText: 'Görevler MOB-1, MOB-2 şeklinde numaralandırılır.',
              ),
            ),
            const SizedBox(height: 12),

            // Description
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                hintText: 'Proje hedefleri...',
              ),
            ),
            const SizedBox(height: 16),

            // Color selection
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
            const SizedBox(height: 24),

            // Buttons
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
                    final name = _nameController.text.trim();
                    final key = _keyController.text.trim().toUpperCase();

                    if (name.isEmpty || key.isEmpty) return;

                    context.read<ProjectProvider>().createProject(
                          name: name,
                          key: key,
                          description: _descController.text,
                          colorValue: _selectedColor,
                        );

                    Navigator.pop(context);
                  },
                  child: const Text('Proje Oluştur'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
