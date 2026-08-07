import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../providers/project_provider.dart';
import '../theme/app_theme.dart';

class Sidebar extends StatelessWidget {
  final VoidCallback onCreateTaskPressed;
  final VoidCallback onCreateProjectPressed;

  const Sidebar({
    super.key,
    required this.onCreateTaskPressed,
    required this.onCreateProjectPressed,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final isDark = provider.themeMode == ThemeMode.dark;
    final isCollapsed = provider.isSidebarCollapsed;
    final selectedProject = provider.selectedProject;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOutCubic,
      width: isCollapsed ? 68 : 260,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header Bar (Logo & App Title & Collapse Toggle)
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 12 : 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
            ),
            child: isCollapsed
                ? Center(
                    child: IconButton(
                      icon: Icon(
                        Remix.menu_unfold_line,
                        size: 20,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      onPressed: () => provider.toggleSidebarCollapsed(),
                      tooltip: 'Menüyü Genişlet',
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withValues(alpha: 0.75),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Remix.layout_4_fill,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ORION JIRA',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Masaüstü Proje Takibi',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Remix.menu_fold_line,
                          size: 18,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        onPressed: () => provider.toggleSidebarCollapsed(),
                        tooltip: 'Menüyü Daralt',
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
          ),

          // Project Selector Section
          Padding(
            padding: EdgeInsets.all(isCollapsed ? 10 : 14),
            child: isCollapsed
                ? PopupMenuButton<String>(
                    onSelected: (projId) => provider.selectProject(projId),
                    tooltip: selectedProject != null ? '${selectedProject.name} (${selectedProject.key})' : 'Proje Seç',
                    itemBuilder: (context) => provider.projects.map((p) {
                      return PopupMenuItem<String>(
                        value: p.id,
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Color(p.colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${p.name} (${p.key})'),
                          ],
                        ),
                      );
                    }).toList(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: selectedProject != null
                            ? Color(selectedProject.colorValue).withValues(alpha: 0.2)
                            : (isDark ? AppColors.darkCard : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selectedProject != null
                              ? Color(selectedProject.colorValue)
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          selectedProject?.key.substring(0, 2) ?? 'PR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: selectedProject != null
                                ? Color(selectedProject.colorValue)
                                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'AKTİF PROJE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Remix.folder_add_line, size: 16),
                              onPressed: onCreateProjectPressed,
                              tooltip: 'Yeni Proje Oluştur',
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        PopupMenuButton<String>(
                          onSelected: (projId) => provider.selectProject(projId),
                          tooltip: 'Proje Değiştir',
                          itemBuilder: (context) => provider.projects.map((p) {
                            return PopupMenuItem<String>(
                              value: p.id,
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Color(p.colorValue),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${p.name} (${p.key})'),
                                ],
                              ),
                            );
                          }).toList(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (selectedProject != null) ...[
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Color(selectedProject.colorValue),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${selectedProject.name} (${selectedProject.key})',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Remix.arrow_up_down_line, size: 14),
                                ] else
                                  const Text('Proje Seçilmedi'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Main Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 10 : 12, vertical: 4),
              children: [
                _buildNavItem(
                  context: context,
                  icon: Remix.dashboard_line,
                  activeIcon: Remix.dashboard_fill,
                  label: 'Kanban Pano',
                  mode: AppViewMode.kanban,
                  isCollapsed: isCollapsed,
                ),
                _buildNavItem(
                  context: context,
                  icon: Remix.list_check,
                  activeIcon: Remix.list_check,
                  label: 'Liste Görünümü',
                  mode: AppViewMode.list,
                  isCollapsed: isCollapsed,
                ),
                _buildNavItem(
                  context: context,
                  icon: Remix.bar_chart_box_line,
                  activeIcon: Remix.bar_chart_box_fill,
                  label: 'Analiz & Grafikler',
                  mode: AppViewMode.analytics,
                  isCollapsed: isCollapsed,
                ),
              ],
            ),
          ),

          // Quick Create Task Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 10 : 14, vertical: 8),
            child: isCollapsed
                ? IconButton(
                    onPressed: onCreateTaskPressed,
                    style: IconButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Remix.add_line, size: 20),
                    tooltip: 'Yeni Görev Oluştur',
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: onCreateTaskPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        shadowColor: primaryColor.withValues(alpha: 0.4),
                      ),
                      icon: const Icon(Remix.add_line, size: 18),
                      label: const Text(
                        'Yeni Görev Oluştur',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
          ),

          // Bottom Theme & User Toolbar
          Container(
            padding: EdgeInsets.all(isCollapsed ? 10 : 14),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
            ),
            child: isCollapsed
                ? Column(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: primaryColor.withValues(alpha: 0.2),
                        child: Text(
                          'AS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        icon: Icon(
                          isDark ? Remix.sun_line : Remix.moon_line,
                          size: 18,
                        ),
                        onPressed: () => provider.toggleTheme(),
                        tooltip: isDark ? 'Aydınlık Mod' : 'Karanlık Mod',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: primaryColor.withValues(alpha: 0.2),
                            child: Text(
                              'AS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Ahmet Selim',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          isDark ? Remix.sun_line : Remix.moon_line,
                          size: 18,
                        ),
                        onPressed: () => provider.toggleTheme(),
                        tooltip: isDark ? 'Aydınlık Mod' : 'Karanlık Mod',
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required AppViewMode mode,
    required bool isCollapsed,
  }) {
    final provider = context.watch<ProjectProvider>();
    final isSelected = provider.currentViewMode == mode;
    final isDark = provider.themeMode == ThemeMode.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final navContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 12 : 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(color: primaryColor.withValues(alpha: 0.3))
            : Border.all(color: Colors.transparent),
      ),
      child: Row(
        mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            size: 18,
            color: isSelected
                ? primaryColor
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.darkTextPrimary : primaryColor)
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => provider.setViewMode(mode),
          child: isCollapsed
              ? Tooltip(
                  message: label,
                  child: navContent,
                )
              : navContent,
        ),
      ),
    );
  }
}
