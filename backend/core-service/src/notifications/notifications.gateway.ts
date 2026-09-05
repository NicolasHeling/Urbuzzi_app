import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

export interface NotificationPayload {
  id: string;
  type: 'lead_interaction' | 'reservation' | 'proposal' | 'sla_expiring' | 'lot_status' | 'general';
  title: string;
  body: string;
  projectId?: string;
  userId?: string;
  metadata?: Record<string, any>;
  createdAt: string;
}

@WebSocketGateway({
  cors: {
    origin: '*',
  },
  namespace: '/notifications',
})
export class NotificationsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private connectedClients = new Map<string, Socket>();

  handleConnection(client: Socket) {
    console.log(`[Notifications] Client connected: ${client.id}`);
    this.connectedClients.set(client.id, client);
  }

  handleDisconnect(client: Socket) {
    console.log(`[Notifications] Client disconnected: ${client.id}`);
    this.connectedClients.delete(client.id);
  }

  /**
   * Cliente se registra para receber notificações de um projeto específico.
   */
  @SubscribeMessage('joinProject')
  handleJoinProject(@ConnectedSocket() client: Socket, @MessageBody() data: { projectId: string }) {
    if (data?.projectId) {
      client.join(`project:${data.projectId}`);
      console.log(`[Notifications] Client ${client.id} joined project:${data.projectId}`);
    }
  }

  /**
   * Cliente se registra com seu userId para notificações pessoais.
   */
  @SubscribeMessage('joinUser')
  handleJoinUser(@ConnectedSocket() client: Socket, @MessageBody() data: { userId: string }) {
    if (data?.userId) {
      client.join(`user:${data.userId}`);
      console.log(`[Notifications] Client ${client.id} joined user:${data.userId}`);
    }
  }

  /**
   * Envia uma notificação para TODOS os clientes conectados.
   */
  sendGlobalNotification(notification: NotificationPayload) {
    this.server.emit('notification', notification);
  }

  /**
   * Envia uma notificação apenas para os clientes de um projeto específico.
   */
  sendProjectNotification(projectId: string, notification: NotificationPayload) {
    this.server.to(`project:${projectId}`).emit('notification', notification);
  }

  /**
   * Envia uma notificação apenas para um usuário específico.
   */
  sendUserNotification(userId: string, notification: NotificationPayload) {
    this.server.to(`user:${userId}`).emit('notification', notification);
  }

  /**
   * Dispara notificação de lead interagindo (ex: acessou vitrine, pediu info).
   */
  notifyLeadInteraction(projectId: string, clientName: string, action: string) {
    this.sendProjectNotification(projectId, {
      id: `lead-${Date.now()}`,
      type: 'lead_interaction',
      title: 'Lead Interagiu',
      body: `${clientName} ${action}.`,
      projectId,
      createdAt: new Date().toISOString(),
    });
  }

  /**
   * Dispara notificação de nova reserva.
   */
  notifyReservation(projectId: string, lotNumber: string, clientName: string) {
    this.sendProjectNotification(projectId, {
      id: `reservation-${Date.now()}`,
      type: 'reservation',
      title: 'Nova Reserva',
      body: `${clientName} reservou o Lote ${lotNumber}.`,
      projectId,
      createdAt: new Date().toISOString(),
    });
  }

  /**
   * Dispara notificação de SLA prestes a expirar.
   */
  notifySlaExpiring(projectId: string, proposalId: string, daysLeft: number) {
    this.sendProjectNotification(projectId, {
      id: `sla-${Date.now()}`,
      type: 'sla_expiring',
      title: 'SLA Perto do Fim',
      body: `A proposta ${proposalId} expira em ${daysLeft} dia(s).`,
      projectId,
      metadata: { proposalId, daysLeft },
      createdAt: new Date().toISOString(),
    });
  }

  /**
   * Dispara notificação de mudança de status de lote.
   */
  notifyLotStatusChanged(projectId: string, lotNumber: string, block: string, newStatus: string) {
    this.sendProjectNotification(projectId, {
      id: `lot-${Date.now()}`,
      type: 'lot_status',
      title: 'Status de Lote Alterado',
      body: `Lote ${lotNumber} (Quadra ${block}) → ${newStatus}.`,
      projectId,
      metadata: { lotNumber, block, newStatus },
      createdAt: new Date().toISOString(),
    });
  }
}
