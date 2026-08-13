import 'package:flutter/material.dart';

import '../../features/home/presentation/home_page.dart';
import '../../features/lots/presentation/lots_list_page.dart';
import '../../features/proposals/presentation/proposals_page.dart';
import '../../features/audit/presentation/audit_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/home';
  static const String lots = '/lots';
  static const String proposals = '/proposals';
  static const String audit = '/audit';
  static const String login = '/login';
  static const String register = '/register';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _build(settings, const LoginPage());
      case register:
        return _build(settings, const RegisterPage());
      case home:
        return _build(settings, const HomePage());
      case lots:
        return _build(settings, const LotsListPage());
      case proposals:
        return _build(settings, const ProposalsPage());
      case audit:
        return _build(settings, const AuditPage());
      default:
        return _build(settings, const HomePage());
    }
  }

  static MaterialPageRoute<dynamic> _build(RouteSettings settings, Widget page) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
