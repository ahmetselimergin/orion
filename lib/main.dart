import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'models/task.dart';
import 'providers/project_provider.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'widgets/analytics_view.dart';
import 'widgets/create_task_dialog.dart';
import 'widgets/kanban_board.dart';
import 'widgets/project_dialog.dart';
import 'widgets/sidebar.dart';
import 'widgets/task_detail_panel.dart';
import 'widgets/task_list_table.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ProjectProvider(storageService),
      child: const OrionApp(),
    ),
  );
}

class OrionApp extends StatelessWidget {
  const OrionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();

    return MaterialApp(
      title: 'Orion Jira Desktop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: provider.themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreateTaskDialog(BuildContext context, {TaskStatus initialStatus = TaskStatus.todo}) {
    showDialog(
      context: context,
      builder: (context) => CreateTaskDialog(initialStatus: initialStatus),
    );
  }

  void _openCreateProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ProjectDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final isDark = provider.themeMode == ThemeMode.dark;
    final selectedTask = provider.selectedTask;

    return Scaffold(
      body: Row(
        children: [
          // Left Navigation Sidebar
          Sidebar(
            onCreateTaskPressed: () => _openCreateTaskDialog(context),
            onCreateProjectPressed: () => _openCreateProjectDialog(context),
          ),

          // Center Main Workspace
          Expanded(
            child: Column(
              children: [
                // Top Search & Filter Bar
                _buildTopFilterBar(context, provider, isDark),

                // View Content (Kanban / List / Analytics)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildMainView(context, provider),
                  ),
                ),
              ],
            ),
          ),

          // Right Inspector Task Detail Panel (If task selected)
          if (selectedTask != null)
            TaskDetailPanel(task: selectedTask),
        ],
      ),
    );
  }

  Widget _buildTopFilterBar(BuildContext context, ProjectProvider provider, bool isDark) {
    final hasActiveFilter = provider.searchQuery.isNotEmpty ||
        provider.filterStatus != null ||
        provider.filterPriority != null ||
        provider.filterType != null;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Modern Raycast / Linear Style Command Palette Search Box
            Container(
              width: 320,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : Colors.black12,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    Remix.search_2_line,
                    size: 16,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Görevlerde ara veya filtrelere yaz...',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        isDense: true,
                      ),
                      onChanged: (val) => provider.setSearchQuery(val),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Remix.close_line, size: 14),
                      onPressed: () {
                        _searchController.clear();
                        provider.setSearchQuery('');
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0B0F19) : Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Text(
                        '⌘K',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Status Filter Dropdown Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 40,
              decoration: BoxDecoration(
                color: provider.filterStatus != null
                    ? provider.filterStatus!.color.withValues(alpha: 0.15)
                    : (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: provider.filterStatus != null
                      ? provider.filterStatus!.color.withValues(alpha: 0.4)
                      : (isDark ? AppColors.darkBorder : Colors.black12),
                ),
              ),
              child: DropdownButton<TaskStatus?>(
                value: provider.filterStatus,
                hint: Text('Tüm Durumlar', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                underline: const SizedBox.shrink(),
                icon: const Icon(Remix.arrow_down_s_line, size: 16),
                items: [
                  const DropdownMenuItem<TaskStatus?>(
                    value: null,
                    child: Text('Tüm Durumlar', style: TextStyle(fontSize: 12)),
                  ),
                  ...TaskStatus.values.map((s) => DropdownMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(s.label, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      )),
                ],
                onChanged: (val) => provider.setFilterStatus(val),
              ),
            ),
            const SizedBox(width: 10),

            // Priority Filter Dropdown Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 40,
              decoration: BoxDecoration(
                color: provider.filterPriority != null
                    ? provider.filterPriority!.color.withValues(alpha: 0.15)
                    : (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: provider.filterPriority != null
                      ? provider.filterPriority!.color.withValues(alpha: 0.4)
                      : (isDark ? AppColors.darkBorder : Colors.black12),
                ),
              ),
              child: DropdownButton<TaskPriority?>(
                value: provider.filterPriority,
                hint: Text('Tüm Öncelikler', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                underline: const SizedBox.shrink(),
                icon: const Icon(Remix.arrow_down_s_line, size: 16),
                items: [
                  const DropdownMenuItem<TaskPriority?>(
                    value: null,
                    child: Text('Tüm Öncelikler', style: TextStyle(fontSize: 12)),
                  ),
                  ...TaskPriority.values.map((p) => DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Icon(p.icon, size: 14, color: p.color),
                            const SizedBox(width: 6),
                            Text(p.label, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      )),
                ],
                onChanged: (val) => provider.setFilterPriority(val),
              ),
            ),
            const SizedBox(width: 10),

            // Type Filter Dropdown Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 40,
              decoration: BoxDecoration(
                color: provider.filterType != null
                    ? provider.filterType!.color.withValues(alpha: 0.15)
                    : (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: provider.filterType != null
                      ? provider.filterType!.color.withValues(alpha: 0.4)
                      : (isDark ? AppColors.darkBorder : Colors.black12),
                ),
              ),
              child: DropdownButton<TaskType?>(
                value: provider.filterType,
                hint: Text('Tüm Tipler', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                underline: const SizedBox.shrink(),
                icon: const Icon(Remix.arrow_down_s_line, size: 16),
                items: [
                  const DropdownMenuItem<TaskType?>(
                    value: null,
                    child: Text('Tüm Tipler', style: TextStyle(fontSize: 12)),
                  ),
                  ...TaskType.values.map((t) => DropdownMenuItem(
                        value: t,
                        child: Row(
                          children: [
                            Icon(t.icon, size: 14, color: t.color),
                            const SizedBox(width: 6),
                            Text(t.label, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      )),
                ],
                onChanged: (val) => provider.setFilterType(val),
              ),
            ),

            // Clear Filters Button Pill
            if (hasActiveFilter) ...[
              const SizedBox(width: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _searchController.clear();
                    provider.clearFilters();
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Remix.filter_off_line, size: 14, color: Colors.orange),
                        SizedBox(width: 6),
                        Text(
                          'Temizle',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(width: 20),

            // Task Count Badge Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${provider.currentProjectTasks.length} Görev',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainView(BuildContext context, ProjectProvider provider) {
    switch (provider.currentViewMode) {
      case AppViewMode.kanban:
        return KanbanBoard(
          onQuickAddTask: (status) => _openCreateTaskDialog(context, initialStatus: status),
        );
      case AppViewMode.list:
        return const TaskListTable();
      case AppViewMode.analytics:
        return const AnalyticsView();
      case AppViewMode.settings:
        return const Center(child: Text('Ayarlar'));
    }
  }
}
