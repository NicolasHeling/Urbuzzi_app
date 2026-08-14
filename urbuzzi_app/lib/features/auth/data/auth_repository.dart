import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/dio_client.dart';
import '../domain/models/user.dart';

class AuthRepository {
  final _dio = DioClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final String token = response.data['accessToken'];
      final Map<String, dynamic> userData = response.data['user'];

      // Armazena o token de forma segura e na memória
      DioClient().currentToken = token;
      await _storage.write(key: 'jwt_token', value: token);

      // (Em um cenário real, você configuraria o DioClient para ler esse token a partir de agora)

      return User.fromJson(userData);
    } catch (e) {
      throw Exception('Email ou senha inválidos.');
    }
  }

  Future<User> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      final String token = response.data['accessToken'];
      final Map<String, dynamic> userData = response.data['user'];

      DioClient().currentToken = token;
      await _storage.write(key: 'jwt_token', value: token);
      return User.fromJson(userData);
    } catch (e) {
      throw Exception('Erro ao registrar. Email pode já estar em uso.');
    }
  }

  Future<void> logout() async {
    DioClient().currentToken = null;
    await _storage.delete(key: 'jwt_token');
  }
}
