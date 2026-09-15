import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import * as jwt from 'jsonwebtoken';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class EventsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  handleConnection(client: Socket) {
    try {
      // Tenta pegar o token do header de autorização (enviado via polling/ws upgrade)
      const authHeader = client.handshake.headers.authorization;
      if (!authHeader) {
        throw new Error('No authorization header found');
      }

      const token = authHeader.split(' ')[1];
      const secret = process.env.JWT_SECRET || 'urbuzzi_super_secret';
      
      // Valida o token
      const decoded = jwt.verify(token, secret);
      
      // Anexa o usuário ao socket caso precise depois
      (client as any).user = decoded;
      
      Logger.log(`Client authenticated and connected: ${client.id}`);
    } catch (error) {
      Logger.warn(`Unauthorized WebSocket connection attempt: ${client.id} - ${error.message}`);
      client.disconnect(); // Derruba a conexão se for inválido
    }
  }

  handleDisconnect(client: Socket) {
    Logger.log(`Client disconnected: ${client.id}`);
  }

  notifyLotStatusUpdated(lotId: string, newStatus: string) {
    this.server.emit('lotStatusUpdated', { lotId, newStatus });
  }
}
