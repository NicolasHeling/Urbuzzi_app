import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Lot } from './lot.entity';
import { AuditService } from '../audit/audit.service';

@Injectable()
export class LotsService {
  constructor(
    @InjectRepository(Lot)
    private readonly lotRepository: Repository<Lot>,
    private readonly auditService: AuditService,
  ) {}

  async findAll(): Promise<Lot[]> {
    return this.lotRepository.find();
  }

  async findPublic(): Promise<Lot[]> {
    return this.lotRepository.find({ where: { status: 'AVAILABLE' } });
  }

  async findOne(id: string): Promise<Lot> {
    return this.lotRepository.findOne({ where: { id } });
  }

  async create(lotData: Partial<Lot>): Promise<Lot> {
    const lot = this.lotRepository.create(lotData);
    const savedLot = await this.lotRepository.save(lot);
    await this.auditService.logAction('CREATE_LOT', 'Lot', savedLot.id, undefined, lotData);
    return savedLot;
  }

  async updateStatus(id: string, status: string): Promise<Lot> {
    await this.lotRepository.update(id, { status });
    const updatedLot = await this.findOne(id);
    await this.auditService.logAction('UPDATE_LOT_STATUS', 'Lot', id, undefined, { status });
    return updatedLot;
  }
}
