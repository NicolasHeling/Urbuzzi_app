import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? currentToken;

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
          // Tenta ler da memória primeiro
          String? token = currentToken;

          // Se não estiver na memória, tenta do storage seguro com try-catch
          if (token == null || token.isEmpty) {
            try {
              token = await _storage.read(key: 'jwt_token');
              if (token != null) currentToken = token; // Sincroniza
            } catch (e) {
              print('Erro ao ler token do SecureStorage: $e');
            }
          }

          print('=== INTERCEPTOR DIO ===');
          print('URL: ${options.uri}');
          print('Token em memoria: $currentToken');
          print('Token que será enviado: $token');

          if (token != null && token.isNotEmpty) {
            options.headers['authorization'] = 'Bearer $token';
          } else {
            print('AVISO: Nenhum token encontrado! Requisição vai sem Auth.');
          }

          return handler.next(options);
        },
        onError: (error, handler) {
          // Se receber 401, o token expirou — pode redirecionar para login
          if (error.response?.statusCode == 401) {
            // Limpa o token expirado
            currentToken = null;
            _storage.delete(key: 'jwt_token');
          }
          return handler.next(error);
        },
      ),
    );
  }
}
