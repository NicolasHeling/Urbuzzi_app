import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';
import 'dio_client.dart';

/// Modelo de uma notificação recebida via WebSocket.
class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? projectId;
  final String? userId;
  final DateTime createdAt;
  bool read;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.projectId,
    this.userId,
    required this.createdAt,
    this.read = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? 'unknown-${DateTime.now().millisecondsSinceEpoch}',
      type: json['type'] ?? 'general',
      title: json['title'] ?? 'Notificação',
      body: json['body'] ?? '',
      projectId: json['projectId'],
      userId: json['userId'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Serviço singleton de WebSocket para notificações em tempo real e eventos de lotes.
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _lotSocket;
  io.Socket? _notifSocket;

  // Callbacks
  Function(String lotId, String newStatus)? _onLotStatusUpdated;
  Function(AppNotification notification)? _onNotification;

  /// Inicializa o socket de eventos de lotes (namespace padrão "/").
  void initSocket({required Function(String lotId, String newStatus) onLotStatusUpdated}) {
    _onLotStatusUpdated = onLotStatusUpdated;

    if (_lotSocket != null && _lotSocket!.connected) return;

    final url = _getSocketUrl();

    _lotSocket = io.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _lotSocket!.connect();

    _lotSocket!.onConnect((_) {
      if (kDebugMode) print('[Socket] Conectado ao WebSocket de Lotes');
    });

    _lotSocket!.on('lotStatusUpdated', (data) {
      if (data != null && data['lotId'] != null && data['newStatus'] != null) {
        _onLotStatusUpdated?.call(data['lotId'], data['newStatus']);
      }
    });

    _lotSocket!.onDisconnect((_) {
      if (kDebugMode) print('[Socket] Desconectado do WebSocket de Lotes');
    });
  }

  /// Inicializa o socket de notificações (namespace "/notifications").
  void initNotifications({
    required Function(AppNotification notification) onNotification,
    String? projectId,
    String? userId,
  }) {
    _onNotification = onNotification;

    if (_notifSocket != null && _notifSocket!.connected) return;

    final url = '${_getSocketUrl()}/notifications';

    _notifSocket = io.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': true,
    });

    _notifSocket!.connect();

    _notifSocket!.onConnect((_) {
      if (kDebugMode) print('[Socket] Conectado ao WebSocket de Notificações');

      // Registrar no room do projeto ativo
      if (projectId != null) {
        _notifSocket!.emit('joinProject', {'projectId': projectId});
      }
      // Registrar no room do usuário
      if (userId != null) {
        _notifSocket!.emit('joinUser', {'userId': userId});
      }
    });

    _notifSocket!.on('notification', (data) {
      if (data != null) {
        final notification = AppNotification.fromJson(Map<String, dynamic>.from(data));
        _onNotification?.call(notification);
      }
    });

    _notifSocket!.onDisconnect((_) {
      if (kDebugMode) print('[Socket] Desconectado do WebSocket de Notificações');
    });
  }

  /// Troca o room do projeto sem reconectar.
  void switchProject(String projectId) {
    _notifSocket?.emit('joinProject', {'projectId': projectId});
  }

  /// Desconecta todos os sockets.
  void disconnect() {
    _lotSocket?.disconnect();
    _notifSocket?.disconnect();
  }

  String _getSocketUrl() {
    // Usa a porta do core-service diretamente (3002)
    final baseUrl = getBaseUrl();
    return baseUrl.replaceFirst(':3000', ':3002');
  }
}
