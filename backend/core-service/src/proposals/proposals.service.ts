import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Proposal } from './proposal.entity';
import { AuditService } from '../audit/audit.service';

@Injectable()
export class ProposalsService {
  constructor(
    @InjectRepository(Proposal)
    private readonly proposalRepository: Repository<Proposal>,
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
    await this.auditService.logAction('UPDATE_PROPOSAL_STATUS', 'Proposal', id, userId, { status });
    return updatedProposal;
  }
}
