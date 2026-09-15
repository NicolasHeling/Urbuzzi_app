import '../../../../core/auth/user_role.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String roleStr;
  final String? avatarUrl;
  final String? token; // Adicionado para armazenar o token na sessão

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.roleStr,
    this.avatarUrl,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roleStr: json['role'] ?? 'consulta',
      avatarUrl: json['avatarUrl'],
      token: json['token'],
    );
  }

  User copyWithToken(String newToken) {
    return User(
      id: id,
      name: name,
      email: email,
      roleStr: roleStr,
      avatarUrl: avatarUrl,
      token: newToken,
    );
  }

  UserRole get role => UserRole.fromString(roleStr);
}
