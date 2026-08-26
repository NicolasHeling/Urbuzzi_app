import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/network/dio_client.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_colors.dart';

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
    // Inter como fonte base, Plus Jakarta Sans como fonte de display
    final baseTextTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);
    final displayTextTheme = GoogleFonts.plusJakartaSansTextTheme(baseTextTheme).copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
      displayMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
      displaySmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
      headlineSmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
    );

    return MaterialApp(
      title: 'Urbizzi',
      navigatorKey: AppRoutes.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: displayTextTheme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.surface,
          primary: AppColors.primary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          surfaceTintColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      initialRoute: initialRoute,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
