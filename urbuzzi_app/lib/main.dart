import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/network/dio_client.dart';
import 'core/routing/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tenta restaurar a sessão anterior
  const storage = FlutterSecureStorage();
  String? savedToken;
  try {
    savedToken = await storage.read(key: 'jwt_token');
    if (savedToken != null && savedToken.isNotEmpty) {
      DioClient().currentToken = savedToken;
      print('Sessão restaurada no boot. Token carregado em memória.');
    }
  } catch (e) {
    print('Nenhuma sessão anterior válida ou erro ao ler storage: $e');
  }

  runApp(
    ProviderScope(
      child: UrbuzziApp(initialRoute: savedToken != null && savedToken.isNotEmpty ? '/app' : AppRoutes.login),
    ),
  );
}

class UrbuzziApp extends ConsumerWidget {
  final String initialRoute;
  const UrbuzziApp({super.key, this.initialRoute = AppRoutes.login});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Urbuzzi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
