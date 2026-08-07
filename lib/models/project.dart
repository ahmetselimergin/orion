class Project {
  final String id;
  String key; // e.g. "ORI", "APP"
  String name;
  String description;
  int colorValue;
  int nextTaskNumber;
  DateTime createdAt;

  Project({
    required this.id,
    required this.key,
    required this.name,
    this.description = '',
    this.colorValue = 0xFF6366F1, // Indigo default
    this.nextTaskNumber = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'name': name,
        'description': description,
        'colorValue': colorValue,
        'nextTaskNumber': nextTaskNumber,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'],
        key: json['key'],
        name: json['name'],
        description: json['description'] ?? '',
        colorValue: json['colorValue'] ?? 0xFF6366F1,
        nextTaskNumber: json['nextTaskNumber'] ?? 1,
        createdAt: DateTime.parse(json['createdAt']),
      );
}
