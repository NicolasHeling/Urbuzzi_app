import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Not } from 'typeorm';
import { Proposal } from './proposal.entity';
import { ProposalHistory } from './proposal-history.entity';
import { Lot } from '../lots/lot.entity';
import { Reservation } from '../reservations/entities/reservation.entity';
import { AuditService } from '../audit/audit.service';
import { Audit } from '../audit/audit.entity';

@Injectable()
export class ProposalsService {
  constructor(
    @InjectRepository(Proposal)
    private readonly proposalRepository: Repository<Proposal>,
    @InjectRepository(ProposalHistory)
    private readonly proposalHistoryRepository: Repository<ProposalHistory>,
    @InjectRepository(Lot)
    private readonly lotRepository: Repository<Lot>,
    @InjectRepository(Reservation)
    private readonly reservationRepository: Repository<Reservation>,
    private readonly auditService: AuditService,
  ) {}

  async findAll(): Promise<Proposal[]> {
    return this.proposalRepository.find({ relations: ['lot'] });
  }

  async getHistory(id: string): Promise<ProposalHistory[]> {
    return this.proposalHistoryRepository.find({
      where: { proposalId: id },
      order: { createdAt: 'DESC' },
    });
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
    return await this.proposalRepository.manager.transaction(async (manager) => {
      await manager.update(Proposal, id, { status });
      const updatedProposal = await manager.findOne(Proposal, { where: { id }, relations: ['lot'] });

      if (status === 'Rejeitada' && updatedProposal?.lot) {
        const lotId = updatedProposal.lot.id;

        const otherActiveProposal = await manager.findOne(Proposal, {
          where: [
            { lot: { id: lotId }, status: 'Nova', id: Not(id) },
            { lot: { id: lotId }, status: 'Em Análise', id: Not(id) },
          ],
        });

        const activeReservation = await manager.findOne(Reservation, {
          where: [
            { lot: { id: lotId }, status: 'PENDING' },
            { lot: { id: lotId }, status: 'APPROVED' },
          ],
        });

        if (!otherActiveProposal && !activeReservation) {
          await manager.update(Lot, lotId, { status: 'Disponível' });
        }
      } else if (status === 'Concluída' && updatedProposal?.lot) {
        const lotId = updatedProposal.lot.id;
        await manager.update(Lot, lotId, { status: 'Vendido' });
        const lotSoldAudit = manager.create(Audit, {
          action: 'LOT_SOLD',
          entityName: 'Lot',
          entityId: lotId,
          userId,
          details: { proposalId: id, trigger: 'PROPOSAL_CONCLUDED' },
        });
        await manager.save(lotSoldAudit);
      }

      const statusAudit = manager.create(Audit, {
        action: 'UPDATE_PROPOSAL_STATUS',
        entityName: 'Proposal',
        entityId: id,
        userId,
        details: { status },
      });
      await manager.save(statusAudit);

      return updatedProposal;
    });
  }
}
