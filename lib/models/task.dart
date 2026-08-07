import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

enum TaskStatus {
  backlog,
  todo,
  inProgress,
  inReview,
  done;

  String get label {
    switch (this) {
      case TaskStatus.backlog:
        return 'Backlog';
      case TaskStatus.todo:
        return 'Yapılacak';
      case TaskStatus.inProgress:
        return 'Devam Ediyor';
      case TaskStatus.inReview:
        return 'İncelemede';
      case TaskStatus.done:
        return 'Tamamlandı';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.backlog:
        return const Color(0xFF64748B);
      case TaskStatus.todo:
        return const Color(0xFF3B82F6);
      case TaskStatus.inProgress:
        return const Color(0xFFF59E0B);
      case TaskStatus.inReview:
        return const Color(0xFFA855F7);
      case TaskStatus.done:
        return const Color(0xFF10B981);
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Düşük';
      case TaskPriority.medium:
        return 'Orta';
      case TaskPriority.high:
        return 'Yüksek';
      case TaskPriority.urgent:
        return 'Acil';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF64748B);
      case TaskPriority.medium:
        return const Color(0xFFEAB308);
      case TaskPriority.high:
        return const Color(0xFFF97316);
      case TaskPriority.urgent:
        return const Color(0xFFEF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Remix.arrow_down_line;
      case TaskPriority.medium:
        return Remix.subtract_line;
      case TaskPriority.high:
        return Remix.arrow_up_line;
      case TaskPriority.urgent:
        return Remix.error_warning_fill;
    }
  }
}

enum TaskType {
  task,
  bug,
  feature,
  improvement;

  String get label {
    switch (this) {
      case TaskType.task:
        return 'Görev';
      case TaskType.bug:
        return 'Hata (Bug)';
      case TaskType.feature:
        return 'Yeni Özellik';
      case TaskType.improvement:
        return 'Geliştirme';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskType.task:
        return Remix.checkbox_line;
      case TaskType.bug:
        return Remix.bug_line;
      case TaskType.feature:
        return Remix.sparkling_fill;
      case TaskType.improvement:
        return Remix.line_chart_line;
    }
  }

  Color get color {
    switch (this) {
      case TaskType.task:
        return const Color(0xFF3B82F6);
      case TaskType.bug:
        return const Color(0xFFEF4444);
      case TaskType.feature:
        return const Color(0xFF10B981);
      case TaskType.improvement:
        return const Color(0xFF8B5CF6);
    }
  }
}

class SubTask {
  final String id;
  String title;
  bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
        id: json['id'],
        title: json['title'],
        isCompleted: json['isCompleted'] ?? false,
      );
}

class TaskComment {
  final String id;
  final String author;
  final String content;
  final DateTime createdAt;

  TaskComment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TaskComment.fromJson(Map<String, dynamic> json) => TaskComment(
        id: json['id'],
        author: json['author'] ?? 'Kullanıcı',
        content: json['content'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class Task {
  final String id;
  final String projectId;
  final String projectKey;
  final int taskNumber;
  String title;
  String description;
  TaskStatus status;
  TaskPriority priority;
  TaskType type;
  List<String> tags;
  List<SubTask> subtasks;
  List<TaskComment> comments;
  String assignee;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? dueDate;

  Task({
    required this.id,
    required this.projectId,
    required this.projectKey,
    required this.taskNumber,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.type = TaskType.task,
    List<String>? tags,
    List<SubTask>? subtasks,
    List<TaskComment>? comments,
    this.assignee = 'Ben',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.dueDate,
  })  : tags = tags ?? [],
        subtasks = subtasks ?? [],
        comments = comments ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get taskKey => '$projectKey-$taskNumber';

  double get subtaskProgress {
    if (subtasks.isEmpty) return 0.0;
    final completed = subtasks.where((s) => s.isCompleted).length;
    return completed / subtasks.length;
  }

  int get completedSubtasksCount => subtasks.where((s) => s.isCompleted).length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'projectKey': projectKey,
        'taskNumber': taskNumber,
        'title': title,
        'description': description,
        'status': status.name,
        'priority': priority.name,
        'type': type.name,
        'tags': tags,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'comments': comments.map((c) => c.toJson()).toList(),
        'assignee': assignee,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        projectId: json['projectId'],
        projectKey: json['projectKey'],
        taskNumber: json['taskNumber'],
        title: json['title'],
        description: json['description'] ?? '',
        status: TaskStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => TaskStatus.todo,
        ),
        priority: TaskPriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => TaskPriority.medium,
        ),
        type: TaskType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => TaskType.task,
        ),
        tags: List<String>.from(json['tags'] ?? []),
        subtasks: (json['subtasks'] as List? ?? [])
            .map((s) => SubTask.fromJson(s))
            .toList(),
        comments: (json['comments'] as List? ?? [])
            .map((c) => TaskComment.fromJson(c))
            .toList(),
        assignee: json['assignee'] ?? 'Ben',
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      );
}
