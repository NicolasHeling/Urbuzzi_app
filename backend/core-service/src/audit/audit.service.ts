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

  async findAll(
    limit: number = 50,
    offset: number = 0,
    userId?: string,
    action?: string,
    startDate?: string,
    endDate?: string,
  ): Promise<Audit[]> {
    const query = this.auditRepository.createQueryBuilder('audit');

    if (userId) {
      query.andWhere('audit.userId = :userId', { userId });
    }
    if (action) {
      query.andWhere('audit.action = :action', { action });
    }
    if (startDate) {
      query.andWhere('audit.createdAt >= :startDate', { startDate });
    }
    if (endDate) {
      query.andWhere('audit.createdAt <= :endDate', { endDate });
    }

    return query
      .orderBy('audit.createdAt', 'DESC')
      .take(limit)
      .skip(offset)
      .getMany();
  }

  async findByLotId(lotId: string): Promise<Audit[]> {
    return this.auditRepository.find({
      where: { entityId: lotId },
      order: { createdAt: 'DESC' }
    });
  }
}
