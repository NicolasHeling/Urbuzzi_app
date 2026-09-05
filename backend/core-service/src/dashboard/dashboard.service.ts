import { Injectable } from '@nestjs/common';
import { DataSource } from 'typeorm';

@Injectable()
export class DashboardService {
  constructor(private readonly dataSource: DataSource) {}

  async getFunnelMetrics() {
    const manager = this.dataSource.manager;

    // Total de Clientes Cadastrados (Topo do Funil)
    const [{ totalClients }] = await manager.query(
      `SELECT COUNT(*) as "totalClients" FROM clients`
    );

    // Total de Reservas (Meio do Funil)
    const [{ totalReservations }] = await manager.query(
      `SELECT COUNT(*) as "totalReservations" FROM reservations`
    );

    // Total de Propostas Concluídas / Lotes Vendidos (Fundo do Funil)
    // Considering 'Concluída' or 'Aprovada'
    const [{ totalSales }] = await manager.query(
      `SELECT COUNT(*) as "totalSales" FROM proposals WHERE status IN ('Concluída', 'Aprovada')`
    );

    return {
      totalClients: parseInt(totalClients, 10),
      totalReservations: parseInt(totalReservations, 10),
      totalSales: parseInt(totalSales, 10),
    };
  }
}
