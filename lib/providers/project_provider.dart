import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';

import '../models/user_profile.dart';

enum AppViewMode { kanban, list, analytics, settings }

class ProjectProvider extends ChangeNotifier {
  final StorageService _storage;
  final SupabaseService _supabase;
  final Uuid _uuid = const Uuid();

  List<Project> _projects = [];
  List<Task> _tasks = [];
  
  List<UserProfile> _teamMembers = [
    UserProfile(id: '1', name: 'Ahmet Selim', email: 'ahmet@orion.app', title: UserTitle.frontendDev),
    UserProfile(id: '2', name: 'Caner Yılmaz', email: 'caner@orion.app', title: UserTitle.backendDev),
    UserProfile(id: '3', name: 'Zeynep Kaya', email: 'zeynep@orion.app', title: UserTitle.uiUxDesigner),
    UserProfile(id: '4', name: 'Mert Demir', email: 'mert@orion.app', title: UserTitle.mobileDev),
    UserProfile(id: '5', name: 'Elif Çelik', email: 'elif@orion.app', title: UserTitle.qaTester),
    UserProfile(id: '6', name: 'Burak Şahin', email: 'burak@orion.app', title: UserTitle.devOpsEngineer),
  ];

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

  bool _isLoggedIn = false;
  String _currentUserEmail = '';

  ProjectProvider(this._storage, this._supabase) {
    _isLoggedIn = _storage.isLoggedIn;
    _currentUserEmail = _storage.currentUserEmail;
    _loadData();
  }

  // Getters
  List<Project> get projects => _projects;
  List<Task> get allTasks => _tasks;
  List<UserProfile> get teamMembers => _teamMembers;
  String? get selectedProjectId => _selectedProjectId;
  Task? get selectedTask => _selectedTask;
  AppViewMode get currentViewMode => _currentViewMode;
  ThemeMode get themeMode => _themeMode;
  bool get isSidebarCollapsed => _isSidebarCollapsed;
  bool get isLoggedIn => _isLoggedIn;
  String get currentUserEmail => _currentUserEmail;

  Future<void> login(String emailOrUsername, String password) async {
    try {
      final response = await _supabase.signIn(emailOrUsername, password);
      if (response?.user != null) {
        _isLoggedIn = true;
        _currentUserEmail = response?.user?.email ?? emailOrUsername;
        await _storage.setLoggedIn(true, email: _currentUserEmail);
        notifyListeners();
      } else {
        throw Exception('Giriş başarısız: Kullanıcı doğrulanamadı.');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _supabase.signOut();
    _isLoggedIn = false;
    _currentUserEmail = '';
    await _storage.setLoggedIn(false);
    notifyListeners();
  }

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

  // Actions: Data Initialization & Supabase Sync
  Future<void> _loadData() async {
    // 1. Load local storage first for instant UI response
    _projects = _storage.loadProjects();
    _tasks = _storage.loadTasks();

    if (_projects.isNotEmpty) {
      _selectedProjectId = _projects.first.id;
    }
    notifyListeners();

    // 2. Fetch remote Supabase data and sync
    try {
      final remoteProjects = await _supabase.fetchProjects();
      final remoteTasks = await _supabase.fetchTasks();
      final remoteProfiles = await _supabase.fetchProfiles();

      if (remoteProfiles.isNotEmpty) {
        _teamMembers = remoteProfiles;
      }

      if (remoteProjects.isNotEmpty) {
        _projects = remoteProjects;
        await _storage.saveProjects(_projects);
      } else if (_projects.isNotEmpty) {
        // Initial sync of existing local projects to Supabase
        for (final p in _projects) {
          await _supabase.upsertProject(p);
        }
      }

      if (remoteTasks.isNotEmpty) {
        _tasks = remoteTasks;
        await _storage.saveTasks(_tasks);
      } else if (_tasks.isNotEmpty) {
        // Initial sync of existing local tasks to Supabase
        for (final t in _tasks) {
          await _supabase.upsertTask(t);
        }
      }

      if (_projects.isNotEmpty && _selectedProjectId == null) {
        _selectedProjectId = _projects.first.id;
      }
      notifyListeners();
    } catch (_) {}
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
    List<String>? memberNames,
  }) async {
    final newProject = Project(
      id: _uuid.v4(),
      key: key.toUpperCase().trim(),
      name: name.trim(),
      description: description.trim(),
      colorValue: colorValue,
      nextTaskNumber: 1,
      memberNames: memberNames,
    );

    _projects.add(newProject);
    _selectedProjectId = newProject.id;
    await _storage.saveProjects(_projects);
    await _supabase.upsertProject(newProject);
    notifyListeners();
    return newProject;
  }

  Future<void> updateProject(Project project) async {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      await _storage.saveProjects(_projects);
      await _supabase.upsertProject(project);
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
    await _supabase.deleteProject(projectId);
    notifyListeners();
  }

  // Task CRUD & Status Updates
  List<Task> getSubtasksOf(String parentId) {
    return _tasks.where((t) => t.parentId == parentId).toList();
  }

  Future<Task> createTask({
    required String title,
    String description = '',
    TaskStatus status = TaskStatus.todo,
    TaskPriority priority = TaskPriority.medium,
    TaskType type = TaskType.task,
    List<String>? tags,
    String assignee = 'Ben',
    String? parentId,
    String? parentKey,
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
      parentId: parentId,
      parentKey: parentKey,
      dueDate: dueDate,
    );

    _tasks.add(newTask);
    _selectedTask = newTask;
    await _storage.saveTasks(_tasks);
    await _supabase.upsertTask(newTask);
    notifyListeners();
    return newTask;
  }

  Future<Task> createSubtask({
    required Task parentTask,
    required String title,
    String assignee = 'Ben',
    TaskPriority priority = TaskPriority.medium,
  }) async {
    return createTask(
      title: title,
      parentId: parentTask.id,
      parentKey: parentTask.taskKey,
      assignee: assignee,
      priority: priority,
      type: TaskType.subtask,
    );
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
      await _supabase.upsertTask(task);
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
      await _supabase.upsertTask(_tasks[index]);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    if (_selectedTask?.id == taskId) {
      _selectedTask = null;
    }
    await _storage.saveTasks(_tasks);
    await _supabase.deleteTask(taskId);
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
