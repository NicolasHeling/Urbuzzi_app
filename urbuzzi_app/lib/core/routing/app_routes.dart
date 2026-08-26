import 'package:flutter/material.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/crm/presentation/client_form_page.dart';
import '../../features/vitrine/presentation/vitrine_page.dart';
import '../network/dio_client.dart';
import '../widgets/app_shell.dart';

class AppRoutes {
  AppRoutes._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String login = '/login';
  static const String register = '/register';
  static const String app = '/app';
  static const String clientForm = '/clients/new';
  static const String vitrine = '/vitrine';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final isAuthenticated = DioClient().currentToken != null && DioClient().currentToken!.isNotEmpty;

    if (!isAuthenticated && (settings.name == app || settings.name == clientForm)) {
      return _build(settings, const LoginPage());
    }

    switch (settings.name) {
      case login:
        return _build(settings, const LoginPage());
      case register:
        return _build(settings, const RegisterPage());
      case app:
        return _build(settings, const AppShell());
      case clientForm:
        return _build(settings, const ClientFormPage());
      case vitrine:
        return _build(settings, const VitrinePage());
      default:
        return _build(settings, const AppShell());
    }
  }

  static MaterialPageRoute<dynamic> _build(RouteSettings settings, Widget page) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
