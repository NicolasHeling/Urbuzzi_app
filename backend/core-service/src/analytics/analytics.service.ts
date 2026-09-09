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
    const lots = await this.lotRepository.find();
    
    let available = 0;
    let sold = 0;
    let reserved = 0;
    let vgv = 0;

    for (const lot of lots) {
      if (lot.status === 'Disponível') available++;
      else if (lot.status === 'Vendido') {
        sold++;
        vgv += Number(lot.price) || 0;
      }
      else if (lot.status === 'Reservado') reserved++;
    }

    const proposals = await this.proposalRepository.find({ relations: ['kanbanColumn'] });
    const proposalsPerColumn: { [key: string]: number } = {};

    for (const proposal of proposals) {
      const columnIdOrName = proposal.kanbanColumn?.name || proposal.kanbanColumn?.id || 'Sem Coluna';
      if (!proposalsPerColumn[columnIdOrName]) {
        proposalsPerColumn[columnIdOrName] = 0;
      }
      proposalsPerColumn[columnIdOrName]++;
    }

    return {
      lots: { available, sold, reserved },
      vgv,
      proposalsPerColumn
    };
  }
}
