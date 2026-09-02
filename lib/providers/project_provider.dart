import 'package:flutter/foundation.dart';
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
  bool _isSyncing = false;

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
  String? get currentUserId => _supabase.currentUserId;
  bool get isSyncing => _isSyncing;

  Future<void> refresh() async {
    _isSyncing = true;
    notifyListeners();
    await _loadData();
    _isSyncing = false;
    notifyListeners();
  }

  String get currentUserName {
    if (_currentUserEmail.isEmpty) return 'Kullanıcı';
    // 1. Check if matching profile in teamMembers by email
    final match = _teamMembers.where((m) => m.email.toLowerCase() == _currentUserEmail.toLowerCase()).firstOrNull;
    if (match != null && match.name.isNotEmpty) {
      return match.name;
    }
    // 2. Check by email prefix matching username
    final prefix = _currentUserEmail.split('@').first;
    final matchByPrefix = _teamMembers.where((m) => m.name.toLowerCase() == prefix.toLowerCase()).firstOrNull;
    if (matchByPrefix != null) {
      return matchByPrefix.name;
    }
    // 3. Fallback: Capitalize prefix
    return prefix.isNotEmpty ? '${prefix[0].toUpperCase()}${prefix.substring(1)}' : _currentUserEmail;
  }

  Future<void> login(String emailOrUsername, String password) async {
    try {
      final response = await _supabase.signIn(emailOrUsername, password);
      if (response?.user != null) {
        _isLoggedIn = true;
        _currentUserEmail = response?.user?.email ?? emailOrUsername;
        await _storage.setLoggedIn(true, email: _currentUserEmail);
        await _loadData();
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
    _projects = [];
    _tasks = [];
    _selectedProjectId = null;
    _selectedTask = null;
    await _storage.setLoggedIn(false);
    notifyListeners();
  }

  Future<void> updatePassword(String newPassword) async {
    await _supabase.updatePassword(newPassword);
  }

  Future<void> resetPassword(String email) async {
    await _supabase.resetPassword(email);
  }

  String get searchQuery => _searchQuery;
  TaskStatus? get filterStatus => _filterStatus;
  TaskPriority? get filterPriority => _filterPriority;
  TaskType? get filterType => _filterType;
  String? get filterTag => _filterTag;

  Project? get selectedProject {
    if (_selectedProjectId == null) return null;
    return _projects.where((p) => p.id == _selectedProjectId).firstOrNull ?? (_projects.isNotEmpty ? _projects.first : null);
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
    if (!_isLoggedIn || _currentUserEmail.isEmpty) {
      _projects = [];
      _tasks = [];
      _selectedProjectId = null;
      _selectedTask = null;
      notifyListeners();
      return;
    }

    // 1. Load local storage cache for this user
    final localProjects = _storage.loadProjects(userKey: _currentUserEmail);
    final localTasks = _storage.loadTasks(userKey: _currentUserEmail);

    _projects = localProjects;
    _tasks = localTasks;

    if (_projects.isNotEmpty && _selectedProjectId == null) {
      _selectedProjectId = _projects.first.id;
    }
    notifyListeners();

    // 2. Fetch remote Supabase data and filter accessible items
    try {
      final remoteProfiles = await _supabase.fetchProfiles();
      if (remoteProfiles.isNotEmpty) {
        _teamMembers = remoteProfiles;
      }

      final remoteProjects = await _supabase.fetchProjects();
      final remoteTasks = await _supabase.fetchTasks();

      final userId = _supabase.currentUserId;
      final userName = currentUserName;

      // Filter only projects created by or shared with current user
      final accessibleProjects = remoteProjects.where((p) {
        return p.isAccessibleBy(
          userId: userId,
          userEmail: _currentUserEmail,
          userName: userName,
        );
      }).toList();

      if (accessibleProjects.isNotEmpty) {
        _projects = accessibleProjects;
        final accessibleProjectIds = _projects.map((p) => p.id).toSet();
        _tasks = remoteTasks.where((t) => accessibleProjectIds.contains(t.projectId)).toList();

        await _storage.saveProjects(_projects, userKey: _currentUserEmail);
        await _storage.saveTasks(_tasks, userKey: _currentUserEmail);
      } else if (remoteProjects.isNotEmpty && accessibleProjects.isEmpty) {
        // Other users have projects, but this user doesn't have access to any yet
        _projects = [];
        _tasks = [];
        _selectedProjectId = null;
        _selectedTask = null;
        await _storage.saveProjects([], userKey: _currentUserEmail);
        await _storage.saveTasks([], userKey: _currentUserEmail);
      }

      if (_projects.isNotEmpty) {
        if (_selectedProjectId == null || !_projects.any((p) => p.id == _selectedProjectId)) {
          _selectedProjectId = _projects.first.id;
        }
      } else {
        _selectedProjectId = null;
        _selectedTask = null;
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('ProjectProvider _loadData error: $e');
      }
    }
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
    final members = memberNames != null ? List<String>.from(memberNames) : <String>[];
    final creator = currentUserName;
    if (creator.isNotEmpty && !members.contains(creator)) {
      members.insert(0, creator);
    }

    final newProject = Project(
      id: _uuid.v4(),
      key: key.toUpperCase().trim(),
      name: name.trim(),
      description: description.trim(),
      colorValue: colorValue,
      nextTaskNumber: 1,
      memberNames: members,
      ownerId: _supabase.currentUserId ?? '',
      ownerEmail: _currentUserEmail,
    );

    _projects.add(newProject);
    _selectedProjectId = newProject.id;
    await _storage.saveProjects(_projects, userKey: _currentUserEmail);
    await _supabase.upsertProject(newProject);
    notifyListeners();
    return newProject;
  }

  Future<void> updateProject(Project project) async {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      await _storage.saveProjects(_projects, userKey: _currentUserEmail);
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

    await _storage.saveProjects(_projects, userKey: _currentUserEmail);
    await _storage.saveTasks(_tasks, userKey: _currentUserEmail);
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
    await _storage.saveTasks(_tasks, userKey: _currentUserEmail);
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
      await _storage.saveTasks(_tasks, userKey: _currentUserEmail);
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

      await _storage.saveTasks(_tasks, userKey: _currentUserEmail);
      await _supabase.upsertTask(_tasks[index]);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    if (_selectedTask?.id == taskId) {
      _selectedTask = null;
    }
    await _storage.saveTasks(_tasks, userKey: _currentUserEmail);
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
