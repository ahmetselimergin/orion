class Project {
  final String id;
  String key; // e.g. "ORI", "APP"
  String name;
  String description;
  int colorValue;
  int nextTaskNumber;
  List<String> memberNames;
  DateTime createdAt;
  String ownerId;
  String ownerEmail;

  Project({
    required this.id,
    required this.key,
    required this.name,
    this.description = '',
    this.colorValue = 0xFF6366F1, // Indigo default
    this.nextTaskNumber = 1,
    List<String>? memberNames,
    DateTime? createdAt,
    this.ownerId = '',
    this.ownerEmail = '',
  })  : memberNames = memberNames ?? [],
        createdAt = createdAt ?? DateTime.now();

  bool isAccessibleBy({String? userId, String? userEmail, String? userName}) {
    // 1. Direct owner match by user ID
    if (userId != null && userId.isNotEmpty && ownerId.isNotEmpty && ownerId == userId) {
      return true;
    }

    // 2. Direct owner match by email
    if (userEmail != null && userEmail.isNotEmpty && ownerEmail.isNotEmpty) {
      if (ownerEmail.trim().toLowerCase() == userEmail.trim().toLowerCase()) {
        return true;
      }
    }

    // 3. Member list match by full name or username
    if (userName != null && userName.isNotEmpty) {
      final match = memberNames.any((m) => m.trim().toLowerCase() == userName.trim().toLowerCase());
      if (match) return true;
    }

    // 4. Member list match by email or email prefix
    if (userEmail != null && userEmail.isNotEmpty) {
      final emailLower = userEmail.trim().toLowerCase();
      final prefix = emailLower.split('@').first;
      final match = memberNames.any((m) {
        final mLower = m.trim().toLowerCase();
        return mLower == emailLower || mLower == prefix;
      });
      if (match) return true;
    }

    // 5. Legacy fallback: If project has no owner information at all, check if user is in member list
    if (ownerId.isEmpty && ownerEmail.isEmpty) {
      if (memberNames.isEmpty) return true;
    }

    return false;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'name': name,
        'description': description,
        'colorValue': colorValue,
        'nextTaskNumber': nextTaskNumber,
        'memberNames': memberNames,
        'createdAt': createdAt.toIso8601String(),
        if (ownerId.isNotEmpty) 'ownerId': ownerId,
        if (ownerEmail.isNotEmpty) 'ownerEmail': ownerEmail,
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id']?.toString() ?? '',
        key: json['key']?.toString() ?? 'PRJ',
        name: json['name']?.toString() ?? 'İsimsiz Proje',
        description: json['description']?.toString() ?? '',
        colorValue: json['colorValue'] is int ? json['colorValue'] : 0xFF6366F1,
        nextTaskNumber: json['nextTaskNumber'] is int ? json['nextTaskNumber'] : 1,
        memberNames: (json['memberNames'] as List?)?.map((e) => e.toString()).toList() ?? [],
        createdAt: json['createdAt'] != null
            ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
            : DateTime.now(),
        ownerId: json['ownerId']?.toString() ?? json['owner_id']?.toString() ?? '',
        ownerEmail: json['ownerEmail']?.toString() ?? json['owner_email']?.toString() ?? '',
      );
}
