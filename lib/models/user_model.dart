class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String? avatar;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.avatar,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    String? avatar,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle role from API (SUPERADMIN, ADMIN, USER, etc.)
    String role = 'user';
    if (json['role'] != null) {
      final apiRole = json['role'].toString().toUpperCase();
      if (apiRole == 'SUPERADMIN' || apiRole == 'SUPER_ADMIN') {
        role = 'super_admin';
      } else if (apiRole == 'ADMIN') {
        role = 'admin';
      } else {
        role = apiRole.toLowerCase();
      }
    } else if (json['is_superuser'] == true) {
      role = 'super_admin';
    } else if (json['is_staff'] == true) {
      role = 'admin';
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      password: '',
      role: role,
      avatar: json['avatar'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': name,
      'email': email,
      'role': role,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
