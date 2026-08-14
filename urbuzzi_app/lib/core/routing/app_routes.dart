import 'package:flutter/material.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/crm/presentation/client_form_page.dart';
import '../widgets/app_shell.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String app = '/app';
  static const String clientForm = '/clients/new';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _build(settings, const LoginPage());
      case register:
        return _build(settings, const RegisterPage());
      case app:
        return _build(settings, const AppShell());
      case clientForm:
        return _build(settings, const ClientFormPage());
      default:
        return _build(settings, const AppShell());
    }
  }

  static MaterialPageRoute<dynamic> _build(RouteSettings settings, Widget page) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
