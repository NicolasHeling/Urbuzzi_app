import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/auth/user_role.dart';

part 'user.freezed.dart';

/// Modelo imutável de Usuário, gerado com Freezed.
@freezed
abstract class User with _$User {
  const User._(); // Permite getters customizados

  const factory User({
    @Default('') String id,
    @Default('') String name,
    @Default('') String email,
    @Default('consulta') String roleStr,
    String? avatarUrl,
    String? token, // Armazenar o token na sessão
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      roleStr: (json['role'] ?? 'consulta') as String,
      avatarUrl: json['avatarUrl'] as String?,
      token: json['token'] as String?,
    );
  }

  /// Converte a string do papel para o enum UserRole.
  UserRole get role => UserRole.fromString(roleStr);
}
