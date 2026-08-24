import '../../../../core/auth/user_role.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String roleStr;

  UserRole get role => UserRole.fromString(roleStr);

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.roleStr,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      roleStr: json['role'] ?? 'consulta',
    );
  }
}
