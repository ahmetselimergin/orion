enum UserTitle {
  frontendDev('Frontend Developer'),
  backendDev('Backend Developer'),
  fullstackDev('Fullstack Developer'),
  mobileDev('Mobile Developer'),
  uiUxDesigner('UI/UX Designer'),
  devOpsEngineer('DevOps Engineer'),
  qaTester('QA / Tester'),
  productManager('Product Manager / PO');

  final String label;
  const UserTitle(this.label);
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final UserTitle title;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.title = UserTitle.frontendDev,
  });

  String get displayName => '$name (${title.label})';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'title': title.name,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final titleStr = (json['title'] ?? json['position'] ?? '').toString();
    UserTitle parsedTitle = UserTitle.frontendDev;

    for (var val in UserTitle.values) {
      if (val.name == titleStr || val.label.toLowerCase() == titleStr.toLowerCase()) {
        parsedTitle = val;
        break;
      }
    }

    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      title: parsedTitle,
    );
  }
}
