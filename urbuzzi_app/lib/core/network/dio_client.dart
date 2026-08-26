import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
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
              print('Erro ao ler token do SecureStorage: $e');
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
            // Limpa o token expirado
            currentToken = null;
            _storage.delete(key: 'jwt_token');
            
            // Redireciona para a página de login
            if (context != null) {
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Sessão expirada. Faça login novamente.'),
                  backgroundColor: AppColors.vendido,
                  behavior: SnackBarBehavior.floating,
                ),
              );
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
  }
}
