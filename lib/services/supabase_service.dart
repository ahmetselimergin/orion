import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/user_profile.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://sjhbcziekyclafumgfpn.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqaGJjemlla3ljbGFmdW1nZnBuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYwODcwODUsImV4cCI6MjEwMTY2MzA4NX0.Fe3R1wAje3SBCEE1EJ8tW87GiyWddAAb3FPtyNwHQcU';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  }

  SupabaseClient get _client => Supabase.instance.client;
  User? get currentUser => _client.auth.currentUser;
  String? get currentUserId => _client.auth.currentUser?.id;
  String? get currentUserEmail => _client.auth.currentUser?.email;

  // --- AUTHENTICATION & PROFILES ---
  Future<AuthResponse?> signIn(String emailOrUsername, String password) async {
    final input = emailOrUsername.trim();
    AuthResponse? response;

    // 1. If input contains '@', try direct login with email
    if (input.contains('@')) {
      response = await _client.auth.signInWithPassword(
        email: input,
        password: password,
      );
    } else {
      // 2. If input is a username, query profiles table for matching email
      String targetEmail = '';
      try {
        final profile = await _client
            .from('profiles')
            .select('email')
            .eq('username', input)
            .maybeSingle();

        if (profile != null && profile['email'] != null) {
          targetEmail = profile['email'];
        }
      } catch (_) {}

      if (targetEmail.isNotEmpty) {
        response = await _client.auth.signInWithPassword(
          email: targetEmail,
          password: password,
        );
      } else {
        // Fallback: Try input directly or input@orion.app
        try {
          response = await _client.auth.signInWithPassword(
            email: input,
            password: password,
          );
        } catch (_) {
          response = await _client.auth.signInWithPassword(
            email: '$input@orion.app',
            password: password,
          );
        }
      }
    }

    // 3. Auto-sync user profile to profiles table if missing
    if (response.user != null) {
      _autoSyncUserProfile(response.user!, input);
    }

    return response;
  }

  Future<UserResponse> updatePassword(String newPassword) async {
    return await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email.trim());
  }

  Future<void> _autoSyncUserProfile(User user, String loginInput) async {
    try {
      final existing = await _client.from('profiles').select('id').eq('id', user.id).maybeSingle();
      if (existing == null) {
        final username = !loginInput.contains('@')
            ? loginInput
            : (user.email?.split('@').first ?? 'user');
        await _client.from('profiles').upsert({
          'id': user.id,
          'username': username,
          'email': user.email ?? '$username@orion.app',
          'full_name': username,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase _autoSyncUserProfile Error: $e');
      }
    }
  }

  Future<List<UserProfile>> fetchProfiles() async {
    try {
      final response = await _client.from('profiles').select();
      return (response as List).map((json) => UserProfile.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Supabase fetchProfiles Error: $e');
      }
      return [];
    }
  }

  Future<List<String>> fetchPositions() async {
    try {
      final response = await _client.from('positions').select('title');
      return (response as List).map((json) => json['title'].toString()).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Supabase fetchPositions Error: $e');
      }
      return [
        'Frontend Developer',
        'Backend Developer',
        'Fullstack Developer',
        'Mobile Developer',
        'UI/UX Designer',
        'DevOps Engineer',
        'QA / Tester',
        'Product Manager / PO',
      ];
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Supabase signOut Error: $e');
      }
    }
  }

  // --- PROJECTS ---
  Future<List<Project>> fetchProjects() async {
    try {
      final response = await _client.from('projects').select().order('createdAt', ascending: true);
      return (response as List).map((json) => Project.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Supabase fetchProjects Error: $e');
      }
      try {
        // Fallback without ordering if column differs
        final response = await _client.from('projects').select();
        return (response as List).map((json) => Project.fromJson(Map<String, dynamic>.from(json))).toList();
      } catch (_) {
        return [];
      }
    }
  }

  Future<void> upsertProject(Project project) async {
    try {
      await _client.from('projects').upsert(project.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Supabase upsertProject primary attempt error: $e');
      }
      try {
        // Fallback with base columns if table schema doesn't have ownerId/ownerEmail yet
        final baseJson = {
          'id': project.id,
          'key': project.key,
          'name': project.name,
          'description': project.description,
          'colorValue': project.colorValue,
          'nextTaskNumber': project.nextTaskNumber,
          'memberNames': project.memberNames,
          'createdAt': project.createdAt.toIso8601String(),
        };
        await _client.from('projects').upsert(baseJson);
      } catch (e2) {
        if (kDebugMode) {
          print('Supabase upsertProject fallback Error: $e2');
        }
      }
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _client.from('tasks').delete().eq('projectId', projectId);
      await _client.from('projects').delete().eq('id', projectId);
    } catch (e) {
      if (kDebugMode) {
        print('Supabase deleteProject Error: $e');
      }
    }
  }

  // --- TASKS ---
  Future<List<Task>> fetchTasks() async {
    try {
      final response = await _client.from('tasks').select().order('createdAt', ascending: true);
      return (response as List).map((json) => Task.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Supabase fetchTasks Error: $e');
      }
      try {
        final response = await _client.from('tasks').select();
        return (response as List).map((json) => Task.fromJson(Map<String, dynamic>.from(json))).toList();
      } catch (_) {
        return [];
      }
    }
  }

  Future<void> upsertTask(Task task) async {
    try {
      await _client.from('tasks').upsert(task.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Supabase upsertTask Error: $e');
      }
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _client.from('tasks').delete().eq('id', taskId);
    } catch (e) {
      if (kDebugMode) {
        print('Supabase deleteTask Error: $e');
      }
    }
  }
}
