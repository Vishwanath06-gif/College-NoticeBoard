enum UserRole { student, faculty, admin }

class AppUser {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final List<String> bookmarks;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.bookmarks = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.student,
      ),
      bookmarks: List<String>.from(data['bookmarks'] ?? []),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role.name,
      'bookmarks': bookmarks,
      'createdAt': createdAt,
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? name,
    UserRole? role,
    List<String>? bookmarks,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      bookmarks: bookmarks ?? this.bookmarks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
