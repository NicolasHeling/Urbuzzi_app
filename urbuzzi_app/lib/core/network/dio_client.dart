import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        // URL do API Gateway (rodando no emulador usa 10.0.2.2, na web/desktop usa localhost)
        baseUrl: 'http://localhost:3010',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Interceptor para adicionar Token JWT automaticamente
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Lê o token armazenado de forma segura
          final token = await _storage.read(key: 'jwt_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Se receber 401, o token expirou — pode redirecionar para login
          if (error.response?.statusCode == 401) {
            // Limpa o token expirado
            _storage.delete(key: 'jwt_token');
          }
          return handler.next(error);
        },
      ),
    );
  }
}
