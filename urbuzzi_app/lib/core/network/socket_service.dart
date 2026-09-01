import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';

class SocketService {
  late io.Socket _socket;

  void initSocket({required Function(String lotId, String newStatus) onLotStatusUpdated}) {
    // URL do core-service
    const url = 'http://localhost:3002';
    
    _socket = io.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.connect();

    _socket.onConnect((_) {
      if (kDebugMode) {
        print('Conectado ao WebSocket do Core Service');
      }
    });

    _socket.on('lotStatusUpdated', (data) {
      if (data != null && data['lotId'] != null && data['newStatus'] != null) {
        onLotStatusUpdated(data['lotId'], data['newStatus']);
      }
    });

    _socket.onDisconnect((_) {
      if (kDebugMode) {
        print('Desconectado do WebSocket');
      }
    });
  }

  void disconnect() {
    _socket.disconnect();
  }
}
