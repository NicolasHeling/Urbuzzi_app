import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import '../domain/models/user.dart';

class AuthRepository {
  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  AuthRepository(this._dio);

  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final String token = response.data['accessToken'];
      final Map<String, dynamic> userData = response.data['user'];

      if (kDebugMode) {
        debugPrint('DEBUG LOGIN: Token recebido do backend: $token');
      }

      // Armazena o token de forma segura
      await _storage.write(key: 'jwt_token', value: token);

      return User.fromJson(userData).copyWith(token: token);
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionError || 
            e.type == DioExceptionType.connectionTimeout || 
            (e.type == DioExceptionType.unknown && e.response == null)) {
          throw Exception('Não foi possível conectar ao servidor local. Verifique se a API está rodando na porta 3000!');
        }
        final msg = e.response?.data['message'] ?? 'Email ou senha inválidos.';
        throw Exception(msg);
      }
      throw Exception('Erro inesperado: $e');
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

      await _storage.write(key: 'jwt_token', value: token);
      return User.fromJson(userData).copyWith(token: token);
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionError || 
            e.type == DioExceptionType.connectionTimeout || 
            (e.type == DioExceptionType.unknown && e.response == null)) {
          throw Exception('Não foi possível conectar ao servidor local. Verifique se a API está rodando na porta 3000!');
        }
        final msg = e.response?.data['message'] ?? 'Erro ao registrar. Verifique os dados.';
        throw Exception(msg);
      }
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<User?> fetchMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return User.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post('/auth/forgot-password', data: {'email': email});
    } catch (e) {
      if (e is DioException) {
        final msg = e.response?.data['message'] ?? 'Erro ao solicitar recuperação de senha.';
        throw Exception(msg);
      }
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _dio.post('/auth/reset-password', data: {
        'token': token,
        'newPassword': newPassword,
      });
    } catch (e) {
      if (e is DioException) {
        final msg = e.response?.data['message'] ?? 'Erro ao redefinir senha. O token pode ser inválido ou estar expirado.';
        throw Exception(msg);
      }
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }
}
