import 'dart:io' show Platform;
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, debugPrint;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../routing/app_routes.dart';
import '../theme/app_colors.dart';
import '../../features/auth/presentation/auth_provider.dart';

String getBaseUrl() {
  if (kIsWeb) return const String.fromEnvironment('API_URL_WEB', defaultValue: 'http://localhost:3000');
  if (Platform.isAndroid) return const String.fromEnvironment('API_URL_ANDROID', defaultValue: 'http://10.0.2.2:3000');
  return const String.fromEnvironment('API_URL_IOS', defaultValue: 'http://localhost:3000');
}

final dioClientProvider = Provider<DioClient>((ref) {
  final authState = ref.watch(authControllerProvider);
  return DioClient(token: authState.valueOrNull?.token);
});

class DioClient {
  late final Dio dio;
  final String? token;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DioClient({this.token}) {
    dio = Dio(
      BaseOptions(
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

          // Usa o token injetado via Provider primeiro
          String? jwt = token;

          // Se não houver no provider, tenta do storage seguro
          if (jwt == null || jwt.isEmpty) {
            try {
              jwt = await _storage.read(key: 'jwt_token');
            } catch (e) {
              if (kDebugMode) {
                debugPrint('Erro ao ler token do SecureStorage: $e');
              }
            }
          }

          if (jwt != null && jwt.isNotEmpty) {
            options.headers['authorization'] = 'Bearer $jwt';
          }

          return handler.next(options);
        },
        onError: (error, handler) {
          final context = AppRoutes.navigatorKey.currentContext;
          
          if (error.response?.statusCode == 401) {
            final hasAuthHeader = error.requestOptions.headers.containsKey('authorization');
            
            // Limpa o token expirado do storage (o auth provider será atualizado via logout)
            _storage.delete(key: 'jwt_token');
            
            // Redireciona para a página de login
            if (context != null) {
              context.go(AppRoutes.login);
              
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
