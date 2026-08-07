import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

enum AppViewMode { kanban, list, analytics, settings }

class ProjectProvider extends ChangeNotifier {
  final StorageService _storage;
  final Uuid _uuid = const Uuid();

  List<Project> _projects = [];
  List<Task> _tasks = [];
  
  String? _selectedProjectId;
  Task? _selectedTask;
  AppViewMode _currentViewMode = AppViewMode.kanban;

  // Theme & Search & Filters & Sidebar State
  ThemeMode _themeMode = ThemeMode.dark;
  bool _isSidebarCollapsed = false;
  String _searchQuery = '';
  TaskStatus? _filterStatus;
  TaskPriority? _filterPriority;
  TaskType? _filterType;
  String? _filterTag;

  ProjectProvider(this._storage) {
    _loadData();
  }

  // Getters
  List<Project> get projects => _projects;
  List<Task> get allTasks => _tasks;
  String? get selectedProjectId => _selectedProjectId;
  Task? get selectedTask => _selectedTask;
  AppViewMode get currentViewMode => _currentViewMode;
  ThemeMode get themeMode => _themeMode;
  bool get isSidebarCollapsed => _isSidebarCollapsed;

  String get searchQuery => _searchQuery;
  TaskStatus? get filterStatus => _filterStatus;
  TaskPriority? get filterPriority => _filterPriority;
  TaskType? get filterType => _filterType;
  String? get filterTag => _filterTag;

  Project? get selectedProject {
    if (_selectedProjectId == null) return null;
    return _projects.firstWhere(
      (p) => p.id == _selectedProjectId,
      orElse: () => _projects.first,
    );
  }

  List<Task> get currentProjectTasks {
    final projId = _selectedProjectId;
    if (projId == null) return [];
    
    return _tasks.where((t) {
      if (t.projectId != projId) return false;

      // Apply Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = t.title.toLowerCase().contains(query);
        final matchKey = t.taskKey.toLowerCase().contains(query);
        final matchDesc = t.description.toLowerCase().contains(query);
        final matchTags = t.tags.any((tag) => tag.toLowerCase().contains(query));
        if (!matchTitle && !matchKey && !matchDesc && !matchTags) {
          return false;
        }
      }

      // Apply Status filter
      if (_filterStatus != null && t.status != _filterStatus) return false;

      // Apply Priority filter
      if (_filterPriority != null && t.priority != _filterPriority) return false;

      // Apply Type filter
      if (_filterType != null && t.type != _filterType) return false;

      // Apply Tag filter
      if (_filterTag != null && !t.tags.contains(_filterTag)) return false;

      return true;
    }).toList();
  }

  // Actions: Data Initialization
  void _loadData() {
    _projects = _storage.loadProjects();
    _tasks = _storage.loadTasks();

    if (_projects.isNotEmpty) {
      _selectedProjectId = _projects.first.id;
    }
    notifyListeners();
  }

  // Navigation & View Actions
  void setViewMode(AppViewMode mode) {
    _currentViewMode = mode;
    notifyListeners();
  }

  void selectProject(String projectId) {
    _selectedProjectId = projectId;
    _selectedTask = null;
    notifyListeners();
  }

  void selectTask(Task? task) {
    _selectedTask = task;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void toggleSidebarCollapsed() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }

  // Filter & Search Actions
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(TaskStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setFilterPriority(TaskPriority? priority) {
    _filterPriority = priority;
    notifyListeners();
  }

  void setFilterType(TaskType? type) {
    _filterType = type;
    notifyListeners();
  }

  void setFilterTag(String? tag) {
    _filterTag = tag;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    _filterPriority = null;
    _filterType = null;
    _filterTag = null;
    notifyListeners();
  }

  // Project CRUD
  Future<Project> createProject({
    required String name,
    required String key,
    required String description,
    required int colorValue,
  }) async {
    final newProject = Project(
      id: _uuid.v4(),
      key: key.toUpperCase().trim(),
      name: name.trim(),
      description: description.trim(),
      colorValue: colorValue,
      nextTaskNumber: 1,
    );

    _projects.add(newProject);
    _selectedProjectId = newProject.id;
    await _storage.saveProjects(_projects);
    notifyListeners();
    return newProject;
  }

  Future<void> updateProject(Project project) async {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      await _storage.saveProjects(_projects);
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    _projects.removeWhere((p) => p.id == projectId);
    _tasks.removeWhere((t) => t.projectId == projectId);

    if (_selectedProjectId == projectId) {
      _selectedProjectId = _projects.isNotEmpty ? _projects.first.id : null;
      _selectedTask = null;
    }

    await _storage.saveProjects(_projects);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  // Task CRUD & Status Updates
  Future<Task> createTask({
    required String title,
    String description = '',
    TaskStatus status = TaskStatus.todo,
    TaskPriority priority = TaskPriority.medium,
    TaskType type = TaskType.task,
    List<String>? tags,
    String assignee = 'Ben',
    DateTime? dueDate,
  }) async {
    final project = selectedProject;
    if (project == null) throw Exception('Seçili bir proje yok');

    final taskNumber = project.nextTaskNumber;
    project.nextTaskNumber += 1;
    await updateProject(project);

    final newTask = Task(
      id: _uuid.v4(),
      projectId: project.id,
      projectKey: project.key,
      taskNumber: taskNumber,
      title: title.trim(),
      description: description.trim(),
      status: status,
      priority: priority,
      type: type,
      tags: tags ?? [],
      assignee: assignee,
      dueDate: dueDate,
    );

    _tasks.add(newTask);
    _selectedTask = newTask;
    await _storage.saveTasks(_tasks);
    notifyListeners();
    return newTask;
  }

  Future<void> updateTask(Task task) async {
    task.updatedAt = DateTime.now();
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      if (_selectedTask?.id == task.id) {
        _selectedTask = task;
      }
      await _storage.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index].status = newStatus;
      _tasks[index].updatedAt = DateTime.now();

      if (_selectedTask?.id == taskId) {
        _selectedTask = _tasks[index];
      }

      await _storage.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    if (_selectedTask?.id == taskId) {
      _selectedTask = null;
    }
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  // Subtask Management
  Future<void> addSubTask(String taskId, String title) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1 && title.trim().isNotEmpty) {
      _tasks[index].subtasks.add(SubTask(
        id: _uuid.v4(),
        title: title.trim(),
      ));
      await updateTask(_tasks[index]);
    }
  }

  Future<void> toggleSubTask(String taskId, String subTaskId) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final subIndex = _tasks[taskIndex].subtasks.indexWhere((s) => s.id == subTaskId);
      if (subIndex != -1) {
        final current = _tasks[taskIndex].subtasks[subIndex].isCompleted;
        _tasks[taskIndex].subtasks[subIndex].isCompleted = !current;
        await updateTask(_tasks[taskIndex]);
      }
    }
  }

  Future<void> deleteSubTask(String taskId, String subTaskId) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex].subtasks.removeWhere((s) => s.id == subTaskId);
      await updateTask(_tasks[taskIndex]);
    }
  }

  // Comment Management
  Future<void> addComment(String taskId, String content, {String author = 'Ben'}) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1 && content.trim().isNotEmpty) {
      _tasks[index].comments.add(TaskComment(
        id: _uuid.v4(),
        author: author,
        content: content.trim(),
        createdAt: DateTime.now(),
      ));
      await updateTask(_tasks[index]);
    }
  }
}
