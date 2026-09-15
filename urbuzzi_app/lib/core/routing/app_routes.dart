import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/crm/presentation/client_form_page.dart';
import '../../features/vitrine/presentation/vitrine_page.dart';
import '../widgets/app_shell.dart';

class AppRoutes {
  AppRoutes._();
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String login = '/login';
  static const String register = '/register';
  static const String app = '/app';
  static const String clientForm = '/clients/new';
  static const String vitrine = '/vitrine';
  static const String agenda = '/agenda';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: AppRoutes.navigatorKey,
    initialLocation: AppRoutes.app,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authState.value != null;
      final isLoginRoute = state.matchedLocation == '/login';
      final isRegisterRoute = state.matchedLocation == '/register';
      final isUnauthenticatedRoute = isLoginRoute || isRegisterRoute;

      if (!isAuthenticated && !isUnauthenticatedRoute) {
        return '/login';
      }

      if (isAuthenticated && isUnauthenticatedRoute) {
        return '/app';
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterPage();
        },
      ),
      GoRoute(
        path: '/app',
        builder: (BuildContext context, GoRouterState state) {
          return const AppShell();
        },
      ),
      GoRoute(
        path: '/clients/new',
        builder: (BuildContext context, GoRouterState state) {
          return const ClientFormPage();
        },
      ),
      GoRoute(
        path: '/vitrine',
        builder: (BuildContext context, GoRouterState state) {
          return const VitrinePage();
        },
      ),
      GoRoute(
        path: '/agenda',
        builder: (BuildContext context, GoRouterState state) {
          return const AppShell();
        },
      ),
    ],
  );
});
