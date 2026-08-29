import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Not } from 'typeorm';
import { Proposal } from './proposal.entity';
import { Lot } from '../lots/lot.entity';
import { Reservation } from '../reservations/entities/reservation.entity';
import { AuditService } from '../audit/audit.service';

@Injectable()
export class ProposalsService {
  constructor(
    @InjectRepository(Proposal)
    private readonly proposalRepository: Repository<Proposal>,
    @InjectRepository(Lot)
    private readonly lotRepository: Repository<Lot>,
    @InjectRepository(Reservation)
    private readonly reservationRepository: Repository<Reservation>,
    private readonly auditService: AuditService,
  ) {}

  async findAll(): Promise<Proposal[]> {
    return this.proposalRepository.find({ relations: ['lot'] });
  }

  async create(proposalData: any, userId?: string): Promise<Proposal> {
    const slaDeadline = new Date();
    slaDeadline.setDate(slaDeadline.getDate() + 7);

    const proposal = this.proposalRepository.create({
      ...proposalData,
      lot: { id: proposalData.lotId } as any,
      slaDeadline,
    } as Partial<Proposal>);
    const savedProposal: Proposal = await this.proposalRepository.save(proposal as Proposal);
    await this.auditService.logAction('CREATE_PROPOSAL', 'Proposal', savedProposal.id, userId, proposalData);
    return savedProposal;
  }

  async updateStatus(id: string, status: string, userId?: string): Promise<Proposal> {
    await this.proposalRepository.update(id, { status });
    const updatedProposal = await this.proposalRepository.findOne({ where: { id }, relations: ['lot'] });

    // Ao rejeitar uma proposta, só libera o lote para 'Disponível' se não houver
    // outra negociação ativa (proposta ou reserva) para o mesmo lote.
    // Isso evita liberar indevidamente um lote que ainda está em negociação por outro canal.
    if (status === 'Rejeitada' && updatedProposal?.lot) {
      const lotId = updatedProposal.lot.id;

      const otherActiveProposal = await this.proposalRepository.findOne({
        where: [
          { lot: { id: lotId }, status: 'Nova', id: Not(id) },
          { lot: { id: lotId }, status: 'Em Análise', id: Not(id) },
        ],
      });

      const activeReservation = await this.reservationRepository.findOne({
        where: [
          { lot: { id: lotId }, status: 'PENDING' },
          { lot: { id: lotId }, status: 'APPROVED' },
        ],
      });

      if (!otherActiveProposal && !activeReservation) {
        await this.lotRepository.update(lotId, { status: 'Disponível' });
      }
    }

    await this.auditService.logAction('UPDATE_PROPOSAL_STATUS', 'Proposal', id, userId, { status });
    return updatedProposal;
  }
}
