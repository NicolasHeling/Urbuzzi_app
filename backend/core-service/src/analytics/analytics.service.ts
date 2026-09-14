import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Lot } from '../lots/lot.entity';
import { Proposal } from '../proposals/proposal.entity';

@Injectable()
export class AnalyticsService {
  constructor(
    @InjectRepository(Lot)
    private readonly lotRepository: Repository<Lot>,
    @InjectRepository(Proposal)
    private readonly proposalRepository: Repository<Proposal>,
  ) {}

  async getSummary() {
    // Aggregate lot counts by status directly in SQL (avoids loading all rows into memory)
    const lotStats = await this.lotRepository
      .createQueryBuilder('lot')
      .select('lot.status', 'status')
      .addSelect('COUNT(*)', 'count')
      .addSelect('COALESCE(SUM(lot.price), 0)', 'totalPrice')
      .groupBy('lot.status')
      .getRawMany();

    let available = 0;
    let sold = 0;
    let reserved = 0;
    let vgv = 0;

    for (const row of lotStats) {
      const count = parseInt(row.count, 10);
      if (row.status === 'Disponível') available = count;
      else if (row.status === 'Vendido') {
        sold = count;
        vgv = parseFloat(row.totalPrice) || 0;
      }
      else if (row.status === 'Reservado') reserved = count;
    }

    // Aggregate proposals per kanban column directly in SQL
    const proposalStats = await this.proposalRepository
      .createQueryBuilder('proposal')
      .leftJoin('proposal.kanbanColumn', 'kanbanColumn')
      .select('COALESCE(kanbanColumn.name, \'Sem Coluna\')', 'columnName')
      .addSelect('COUNT(*)', 'count')
      .groupBy('kanbanColumn.name')
      .getRawMany();

    const proposalsPerColumn: { [key: string]: number } = {};
    for (const row of proposalStats) {
      proposalsPerColumn[row.columnName] = parseInt(row.count, 10);
    }

    return {
      lots: { available, sold, reserved },
      vgv,
      proposalsPerColumn,
    };
  }
}
