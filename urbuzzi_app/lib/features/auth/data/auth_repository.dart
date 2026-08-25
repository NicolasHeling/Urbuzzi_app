import 'package:dio/dio.dart';
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

      print('DEBUG LOGIN: Token recebido do backend: $token');

      // Armazena o token de forma segura e na memória
      DioClient().currentToken = token;
      await _storage.write(key: 'jwt_token', value: token);

      final tokenSalvo = await _storage.read(key: 'jwt_token');
      print('DEBUG LOGIN: Token salvo no SecureStorage e lido com sucesso? ${tokenSalvo == token}');

      return User.fromJson(userData);
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

      DioClient().currentToken = token;
      await _storage.write(key: 'jwt_token', value: token);
      return User.fromJson(userData);
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

  Future<void> logout() async {
    DioClient().currentToken = null;
    await _storage.delete(key: 'jwt_token');
  }
}
