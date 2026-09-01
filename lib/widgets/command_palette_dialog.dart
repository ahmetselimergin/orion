import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../models/task.dart';
import '../providers/project_provider.dart';
import '../theme/app_theme.dart';
import 'create_task_dialog.dart';
import 'project_dialog.dart';

class CommandPaletteDialog extends StatefulWidget {
  const CommandPaletteDialog({super.key});

  @override
  State<CommandPaletteDialog> createState() => _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends State<CommandPaletteDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final isDark = provider.themeMode == ThemeMode.dark;

    final matchingTasks = provider.currentProjectTasks.where((t) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return t.title.toLowerCase().contains(q) ||
          t.projectKey.toLowerCase().contains(q) ||
          t.assignee.toLowerCase().contains(q) ||
          t.tags.any((tag) => tag.toLowerCase().contains(q));
    }).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: Container(
        width: 640,
        constraints: const BoxConstraints(maxHeight: 520),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder.withValues(alpha: 0.8) : AppColors.lightBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Input Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Remix.search_2_line, size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Komut yazın veya görevlerde arayın...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: (val) => setState(() => _query = val),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Text(
                      'ESC',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Command Options & Results List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Quick Actions Section
                  if (_query.isEmpty) ...[
                    _buildSectionHeader('HIZLI AKSİYONLAR', isDark),
                    _buildActionItem(
                      icon: Remix.add_circle_line,
                      iconColor: AppColors.primary,
                      title: 'Yeni Görev Ekle',
                      subtitle: 'Aktif projede yeni görev kartı açın',
                      shortcut: '⌘N',
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => const CreateTaskDialog(),
                        );
                      },
                    ),
                    _buildActionItem(
                      icon: Remix.folder_add_line,
                      iconColor: AppColors.accent,
                      title: 'Yeni Proje Oluştur',
                      subtitle: 'Yeni bir çalışma alanı veya proje ekleyin',
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => const ProjectDialog(),
                        );
                      },
                    ),
                    _buildActionItem(
                      icon: isDark ? Remix.sun_line : Remix.moon_line,
                      iconColor: Colors.amber,
                      title: isDark ? 'Açık Temaya Geç' : 'Koyu Temaya Geç',
                      subtitle: 'Uygulama renk modunu değiştirin',
                      isDark: isDark,
                      onTap: () {
                        provider.toggleTheme();
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(height: 16),
                    _buildSectionHeader('GÖRÜNÜM MODLARI', isDark),
                    _buildActionItem(
                      icon: Remix.kanban_view,
                      iconColor: AppColors.todo,
                      title: 'Kanban Pano Görünümüne Geç',
                      subtitle: 'Sürükle-bırak sütunlu pano',
                      isDark: isDark,
                      onTap: () {
                        provider.setViewMode(AppViewMode.kanban);
                        Navigator.pop(context);
                      },
                    ),
                    _buildActionItem(
                      icon: Remix.list_check_2,
                      iconColor: AppColors.done,
                      title: 'Liste Tablo Görünümüne Geç',
                      subtitle: 'Detaylı satır görünümü',
                      isDark: isDark,
                      onTap: () {
                        provider.setViewMode(AppViewMode.list);
                        Navigator.pop(context);
                      },
                    ),
                    _buildActionItem(
                      icon: Remix.bar_chart_grouped_line,
                      iconColor: AppColors.violet,
                      title: 'Analiz & Raporlar Görünümüne Geç',
                      subtitle: 'Proje metrikleri ve istatistikler',
                      isDark: isDark,
                      onTap: () {
                        provider.setViewMode(AppViewMode.analytics);
                        Navigator.pop(context);
                      },
                    ),
                  ],

                  // Task Search Results Section
                  if (matchingTasks.isNotEmpty) ...[
                    if (_query.isNotEmpty) ...[
                      _buildSectionHeader('EŞLEŞEN GÖREVLER (${matchingTasks.length})', isDark),
                      ...matchingTasks.map((task) => _buildTaskItem(task, isDark, provider, context)),
                    ],
                  ] else if (_query.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          '"$_query" ile eşleşen sonuç bulunamadı.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? shortcut,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (shortcut != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Text(
                  shortcut,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task, bool isDark, ProjectProvider provider, BuildContext context) {
    return InkWell(
      onTap: () {
        provider.selectTask(task);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: task.status.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(task.type.icon, size: 16, color: task.status.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${task.projectKey}-${task.taskNumber}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.title,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        task.status.label,
                        style: TextStyle(fontSize: 11, color: task.status.color, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${task.assignee}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Remix.arrow_right_s_line, size: 16),
          ],
        ),
      ),
    );
  }
}
