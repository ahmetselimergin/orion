import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../models/task.dart';

class StorageService {
  static const String _projectsKey = 'orion_projects';
  static const String _tasksKey = 'orion_tasks';

  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = StorageService(prefs);
    await service._seedSampleDataIfNeeded();
    return service;
  }

  // Projects Storage
  List<Project> loadProjects() {
    final rawJson = _prefs.getString(_projectsKey);
    if (rawJson == null) return [];
    try {
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((item) => Project.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveProjects(List<Project> projects) async {
    final list = projects.map((p) => p.toJson()).toList();
    await _prefs.setString(_projectsKey, jsonEncode(list));
  }

  // Tasks Storage
  List<Task> loadTasks() {
    final rawJson = _prefs.getString(_tasksKey);
    if (rawJson == null) return [];
    try {
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((item) => Task.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final list = tasks.map((t) => t.toJson()).toList();
    await _prefs.setString(_tasksKey, jsonEncode(list));
  }

  // Seed sample project and tasks on first launch
  Future<void> _seedSampleDataIfNeeded() async {
    final existingProjects = loadProjects();
    if (existingProjects.isNotEmpty) return;

    final sampleProject = Project(
      id: _uuid.v4(),
      key: 'ORI',
      name: 'Orion Masaüstü Projesi',
      description: 'Kişisel Jira-benzeri masaüstü görev takip uygulaması',
      colorValue: 0xFF6366F1,
      nextTaskNumber: 6,
    );

    final now = DateTime.now();

    final sampleTasks = [
      Task(
        id: _uuid.v4(),
        projectId: sampleProject.id,
        projectKey: sampleProject.key,
        taskNumber: 1,
        title: 'Masaüstü Arayüz Tasarımı ve Cam Efekti',
        description: 'Masaüstü ekranı için şık sol menü, Kanban panosu ve detay paneli tasarımı.',
        status: TaskStatus.done,
        priority: TaskPriority.high,
        type: TaskType.feature,
        tags: ['UI', 'Desktop', 'Design'],
        assignee: 'Ahmet Selim',
        subtasks: [
          SubTask(id: _uuid.v4(), title: 'Sol navigasyon menüsü', isCompleted: true),
          SubTask(id: _uuid.v4(), title: 'Kanban kart tasarımı', isCompleted: true),
          SubTask(id: _uuid.v4(), title: 'Karanlık & Aydınlık tema desteği', isCompleted: true),
        ],
        comments: [
          TaskComment(
            id: _uuid.v4(),
            author: 'Ahmet Selim',
            content: 'Tasarımlar tamamlandı, canlıya alındı.',
            createdAt: now.subtract(const Duration(days: 1)),
          ),
        ],
      ),
      Task(
        id: _uuid.v4(),
        projectId: sampleProject.id,
        projectKey: sampleProject.key,
        taskNumber: 2,
        title: 'Kanban Panosuna Sürükle & Bırak Desteği',
        description: 'Görev kartlarını sütunlar arasında sürükleyip bırakarak durum güncelleyebilme.',
        status: TaskStatus.inProgress,
        priority: TaskPriority.urgent,
        type: TaskType.feature,
        tags: ['Kanban', 'DragDrop'],
        assignee: 'Ahmet Selim',
        dueDate: now.add(const Duration(days: 2)),
        subtasks: [
          SubTask(id: _uuid.v4(), title: 'DragAndDropListener entegrasyonu', isCompleted: true),
          SubTask(id: _uuid.v4(), title: 'Sütun içi kart sıralaması', isCompleted: false),
        ],
      ),
      Task(
        id: _uuid.v4(),
        projectId: sampleProject.id,
        projectKey: sampleProject.key,
        taskNumber: 3,
        title: 'Görev Detay Inspector Paneli',
        description: 'Seçili görevin açıklama, alt görevler (checklist) ve yorumlarını sağ panelde gösterme.',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        type: TaskType.improvement,
        tags: ['Inspector', 'Detail'],
        assignee: 'Ahmet Selim',
        subtasks: [
          SubTask(id: _uuid.v4(), title: 'Alt görev ekleme & tamamlama', isCompleted: true),
          SubTask(id: _uuid.v4(), title: 'Yorum yazma modülü', isCompleted: false),
        ],
      ),
      Task(
        id: _uuid.v4(),
        projectId: sampleProject.id,
        projectKey: sampleProject.key,
        taskNumber: 4,
        title: 'Performans Metrikleri ve Grafikler',
        description: 'Projenin tamamlanma oranı, öncelik ve durum dağılımını gösteren özet paneli.',
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        type: TaskType.feature,
        tags: ['Analytics', 'Charts'],
        assignee: 'Ahmet Selim',
        dueDate: now.add(const Duration(days: 5)),
        subtasks: [
          SubTask(id: _uuid.v4(), title: 'Öncelik dağılım grafiği', isCompleted: false),
          SubTask(id: _uuid.v4(), title: 'Durum çubuğu istatistikleri', isCompleted: false),
        ],
      ),
      Task(
        id: _uuid.v4(),
        projectId: sampleProject.id,
        projectKey: sampleProject.key,
        taskNumber: 5,
        title: 'Yerel JSON Dışa / İça Aktarma Desteği',
        description: 'Tüm projeyi ve görevleri JSON formatında dosyaya yedekleme.',
        status: TaskStatus.backlog,
        priority: TaskPriority.low,
        type: TaskType.improvement,
        tags: ['Backup', 'JSON'],
        assignee: 'Ahmet Selim',
      ),
    ];

    await saveProjects([sampleProject]);
    await saveTasks(sampleTasks);
  }
}
