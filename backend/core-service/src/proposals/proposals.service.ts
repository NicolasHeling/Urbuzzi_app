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

  async create(proposalData: any): Promise<Proposal> {
    const proposal = this.proposalRepository.create({
      ...proposalData,
      lot: { id: proposalData.lotId } as any,
    } as Partial<Proposal>);
    const savedProposal: Proposal = await this.proposalRepository.save(proposal as Proposal);
    await this.auditService.logAction('CREATE_PROPOSAL', 'Proposal', savedProposal.id, undefined, proposalData);
    return savedProposal;
  }

  async updateStatus(id: string, status: string): Promise<Proposal> {
    await this.proposalRepository.update(id, { status });
    const updatedProposal = await this.proposalRepository.findOne({ where: { id }, relations: ['lot'] });
    await this.auditService.logAction('UPDATE_PROPOSAL_STATUS', 'Proposal', id, undefined, { status });
    return updatedProposal;
  }
}
