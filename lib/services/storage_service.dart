import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';
import '../models/task.dart';

class StorageService {
  static const String _projectsKey = 'orion_projects';
  static const String _tasksKey = 'orion_tasks';
  static const String _isLoggedInKey = 'orion_is_logged_in';
  static const String _userEmailKey = 'orion_user_email';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  bool get isLoggedIn => _prefs.getBool(_isLoggedInKey) ?? false;
  String get currentUserEmail => _prefs.getString(_userEmailKey) ?? '';

  Future<void> setLoggedIn(bool value, {String email = ''}) async {
    await _prefs.setBool(_isLoggedInKey, value);
    await _prefs.setString(_userEmailKey, email);
  }

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  String _getProjectKey(String? userKey) {
    if (userKey != null && userKey.trim().isNotEmpty) {
      final safeKey = userKey.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      return '${_projectsKey}_$safeKey';
    }
    return _projectsKey;
  }

  String _getTaskKey(String? userKey) {
    if (userKey != null && userKey.trim().isNotEmpty) {
      final safeKey = userKey.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      return '${_tasksKey}_$safeKey';
    }
    return _tasksKey;
  }

  // Projects Storage
  List<Project> loadProjects({String? userKey}) {
    final rawJson = _prefs.getString(_getProjectKey(userKey));
    if (rawJson == null) return [];
    try {
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((item) => Project.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveProjects(List<Project> projects, {String? userKey}) async {
    final list = projects.map((p) => p.toJson()).toList();
    await _prefs.setString(_getProjectKey(userKey), jsonEncode(list));
  }

  // Tasks Storage
  List<Task> loadTasks({String? userKey}) {
    final rawJson = _prefs.getString(_getTaskKey(userKey));
    if (rawJson == null) return [];
    try {
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((item) => Task.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks, {String? userKey}) async {
    final list = tasks.map((t) => t.toJson()).toList();
    await _prefs.setString(_getTaskKey(userKey), jsonEncode(list));
  }
}
