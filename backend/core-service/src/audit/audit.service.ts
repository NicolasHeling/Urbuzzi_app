import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Audit } from './audit.entity';

@Injectable()
export class AuditService {
  constructor(
    @InjectRepository(Audit)
    private readonly auditRepository: Repository<Audit>,
  ) {}

  async logAction(action: string, entityName: string, entityId: string, userId?: string, details?: any): Promise<Audit> {
    const audit = this.auditRepository.create({
      action,
      entityName,
      entityId,
      userId,
      details,
    });
    return this.auditRepository.save(audit);
  }

  async findAll(): Promise<Audit[]> {
    return this.auditRepository.find({ order: { createdAt: 'DESC' } });
  }
}
