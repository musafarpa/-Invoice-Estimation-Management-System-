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
}
