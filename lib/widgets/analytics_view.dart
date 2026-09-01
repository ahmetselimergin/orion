import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/project_provider.dart';
import '../theme/app_theme.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final tasks = provider.currentProjectTasks;
    final project = provider.selectedProject;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'Analiz için henüz görev bulunmuyor',
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      );
    }

    final totalTasks = tasks.length;
    final doneTasks = tasks.where((t) => t.status == TaskStatus.done).length;
    final completionRate = totalTasks > 0 ? (doneTasks / totalTasks) : 0.0;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Header Project Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project?.name ?? 'Proje Analizi',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${project?.key} • Toplam $totalTasks görev takibi',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: completionRate,
                        minHeight: 10,
                        backgroundColor: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(AppColors.done),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Proje Tamamlanma Oranı: %${(completionRate * 100).toStringAsFixed(1)} ($doneTasks / $totalTasks)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Big Progress Circle Metric
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.done.withValues(alpha: 0.12),
                  border: Border.all(color: AppColors.done, width: 3),
                ),
                child: Center(
                  child: Text(
                    '%${(completionRate * 100).round()}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.done,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Metrics Grid (Status Breakdown)
        Text(
          'DURUM DAĞILIMI',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: TaskStatus.values.map((status) {
            final count = tasks.where((t) => t.status == status).length;
            final pct = totalTasks > 0 ? (count / totalTasks) : 0.0;

            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: status.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          status.label,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: status.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '%${(pct * 100).toStringAsFixed(0)} toplam',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Priority & Type Distribution Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority Breakdown
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ÖNCELİK DAĞILIMI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...TaskPriority.values.map((priority) {
                      final count = tasks.where((t) => t.priority == priority).length;
                      final pct = totalTasks > 0 ? (count / totalTasks) : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Icon(priority.icon, size: 16, color: priority.color),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Text(
                                priority.label,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                                  valueColor: AlwaysStoppedAnimation(priority.color),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$count',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Task Type Breakdown
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GÖREV TİPİ DAĞILIMI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...TaskType.values.map((type) {
                      final count = tasks.where((t) => t.type == type).length;
                      final pct = totalTasks > 0 ? (count / totalTasks) : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Icon(type.icon, size: 16, color: type.color),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Text(
                                type.label,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                                  valueColor: AlwaysStoppedAnimation(type.color),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$count',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
