import 'dart:io' show Platform;
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, debugPrint;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../routing/app_routes.dart';
import '../theme/app_colors.dart';

String getBaseUrl() {
  if (kIsWeb) return 'http://localhost:3000';
  if (Platform.isAndroid) return 'http://10.0.2.2:3000';
  return 'http://localhost:3000';
}

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
        // URL do API Gateway adaptada para emulador e web
        baseUrl: getBaseUrl(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Interceptor para adicionar Token JWT automaticamente e tratar erros globais
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.path.contains('/auth/login') || options.path.contains('/auth/register')) return handler.next(options);

          // Tenta ler da memória primeiro
          String? token = currentToken;

          // Se não estiver na memória, tenta do storage seguro com try-catch
          if (token == null || token.isEmpty) {
            try {
              token = await _storage.read(key: 'jwt_token');
              if (token != null) currentToken = token; // Sincroniza
            } catch (e) {
              if (kDebugMode) {
                debugPrint('Erro ao ler token do SecureStorage: $e');
              }
            }
          }

          if (token != null && token.isNotEmpty) {
            options.headers['authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (error, handler) {
          final context = AppRoutes.navigatorKey.currentContext;
          
          if (error.response?.statusCode == 401) {
            final hasAuthHeader = error.requestOptions.headers.containsKey('authorization');
            
            // Limpa o token expirado
            currentToken = null;
            _storage.delete(key: 'jwt_token');
            
            // Redireciona para a página de login
            if (context != null) {
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              
              if (hasAuthHeader) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sessão expirada. Faça login novamente.'),
                    backgroundColor: AppColors.vendido,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          } else if (error.response?.statusCode != null && error.response!.statusCode! >= 400 && context != null) {
             // Exibe feedback visual de erros globalmente
             final String errorMsg = error.response?.data['error'] ?? error.response?.data['message'] ?? 'Erro na operação';
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text(errorMsg),
                 backgroundColor: AppColors.vendido,
                 behavior: SnackBarBehavior.floating,
               ),
             );
          }
          return handler.next(error);
        },
      ),
    );

    // Retry interceptor para requests GET com backoff exponencial
    dio.interceptors.add(_RetryInterceptor(dio: dio));
  }
}

/// Interceptor de retry com backoff exponencial para requests idempotentes (GET).
class _RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration initialDelay;

  _RetryInterceptor({
    required this.dio,
  }) : maxRetries = 3, initialDelay = const Duration(milliseconds: 500);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Só faz retry em GET (idempotente) e erros de rede/timeout
    final isRetryable = err.requestOptions.method == 'GET' &&
        (err.type == DioExceptionType.connectionTimeout ||
         err.type == DioExceptionType.receiveTimeout ||
         err.type == DioExceptionType.connectionError ||
         err.type == DioExceptionType.unknown);

    if (!isRetryable) {
      return handler.next(err);
    }

    // Busca ou inicializa o contador de tentativas
    final retryCount = (err.requestOptions.extra['_retryCount'] as int?) ?? 0;

    if (retryCount >= maxRetries) {
      if (kDebugMode) {
        debugPrint('[DioRetry] Max retries ($maxRetries) exceeded for ${err.requestOptions.path}');
      }
      return handler.next(err);
    }

    final delay = initialDelay * (1 << retryCount); // Exponential backoff: 500ms, 1s, 2s
    if (kDebugMode) {
      debugPrint('[DioRetry] Retry ${retryCount + 1}/$maxRetries for ${err.requestOptions.path} in ${delay.inMilliseconds}ms');
    }

    await Future.delayed(delay);

    // Incrementa o contador e tenta de novo
    err.requestOptions.extra['_retryCount'] = retryCount + 1;

    try {
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }
}
