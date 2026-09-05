import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/socket_service.dart';
import '../../projects/presentation/projects_provider.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';

/// Provider que gerencia a lista de notificações em tempo real.
final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier(ref);
});

/// Provider derivado que retorna a contagem de não-lidas.
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.read).length;
});

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  final Ref ref;
  final SocketService _socketService = SocketService();
  bool _initialized = false;

  NotificationsNotifier(this.ref) : super([]) {
    _init();
  }

  void _init() {
    if (_initialized) return;
    _initialized = true;

    final projectId = ref.read(selectedProjectIdProvider);
    final user = ref.read(authControllerProvider).value;

    _socketService.initNotifications(
      onNotification: _handleNotification,
      projectId: projectId,
      userId: user?.id,
    );

    // Reage a mudanças de projeto
    ref.listen<String?>(selectedProjectIdProvider, (prev, next) {
      if (next != null && next != prev) {
        _socketService.switchProject(next);
      }
    });
  }

  void _handleNotification(AppNotification notification) {
    // Insere no topo da lista
    state = [notification, ...state];

    // Exibe um SnackBar visual
    final context = AppRoutes.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(_iconForType(notification.type), color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(notification.body, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.sidebarBg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Ver',
            textColor: AppColors.primary,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void markAsRead(String notificationId) {
    state = [
      for (final n in state)
        if (n.id == notificationId)
          AppNotification(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            projectId: n.projectId,
            userId: n.userId,
            createdAt: n.createdAt,
            read: true,
          )
        else
          n,
    ];
  }

  void markAllAsRead() {
    state = [
      for (final n in state)
        AppNotification(
          id: n.id,
          type: n.type,
          title: n.title,
          body: n.body,
          projectId: n.projectId,
          userId: n.userId,
          createdAt: n.createdAt,
          read: true,
        ),
    ];
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'lead_interaction':
        return Icons.person_add_alt_1;
      case 'reservation':
        return Icons.event_available;
      case 'proposal':
        return Icons.description_outlined;
      case 'sla_expiring':
        return Icons.warning_amber_rounded;
      case 'lot_status':
        return Icons.map_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
