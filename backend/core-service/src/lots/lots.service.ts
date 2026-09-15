import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Lot } from './lot.entity';
import { AuditService } from '../audit/audit.service';
import { Audit } from '../audit/audit.entity';
import { EventsGateway } from './events.gateway';

@Injectable()
export class LotsService {
  constructor(
    @InjectRepository(Lot)
    private readonly lotRepository: Repository<Lot>,
    private readonly auditService: AuditService,
    private readonly eventsGateway: EventsGateway,
  ) {}

  async findAll(limit: number = 50, offset: number = 0, search?: string, status?: string): Promise<{ data: Lot[]; total: number }> {
    const query = this.lotRepository.createQueryBuilder('lot')
      .orderBy('lot.block', 'ASC')
      .addOrderBy('lot.number', 'ASC')
      .take(limit)
      .skip(offset);

    if (status && status !== 'Todos') {
      query.andWhere('lot.status = :status', { status });
    }

    if (search) {
      const searchTerm = `%${search.toLowerCase()}%`;
      query.andWhere('(LOWER(lot.block) LIKE :search OR LOWER(lot.number) LIKE :search)', { search: searchTerm });
    }

    const [data, total] = await query.getManyAndCount();
    return { data, total };
  }

  async findPublic(): Promise<Lot[]> {
    return this.lotRepository.find({ where: { status: 'Disponível' } });
  }

  /**
   * Retorna dados de polígonos dos lotes para o mapa interativo.
   * Endpoint leve: seleciona apenas campos necessários para renderização.
   */
  async findMapPolygons(landName?: string): Promise<Partial<Lot>[]> {
    const query = this.lotRepository.createQueryBuilder('lot')
      .select(['lot.id', 'lot.block', 'lot.number', 'lot.status', 'lot.mapPolygons', 'lot.landName', 'lot.area', 'lot.price'])
      .orderBy('lot.block', 'ASC')
      .addOrderBy('lot.number', 'ASC');

    if (landName) {
      query.andWhere('lot.landName = :landName', { landName });
    }

    // Retorna apenas lotes que possuem polígonos definidos
    query.andWhere('lot."mapPolygons" IS NOT NULL');

    return query.getMany();
  }

  async findOne(id: string): Promise<Lot> {
    return this.lotRepository.findOne({ where: { id } });
  }

  async create(lotData: Partial<Lot>, userId?: string): Promise<Lot> {
    const lot = this.lotRepository.create(lotData);
    const savedLot = await this.lotRepository.save(lot);
    await this.auditService.logAction('CREATE_LOT', 'Lot', savedLot.id, userId, lotData);
    return savedLot;
  }

  async updateStatus(id: string, status: string, userId?: string, justification?: string): Promise<Lot> {
    const updatedLot = await this.lotRepository.manager.transaction(async (manager) => {
      const currentLot = await manager.findOne(Lot, { where: { id } });
      const oldStatus = currentLot?.status;

      await manager.update(Lot, id, { status });
      const lot = await manager.findOne(Lot, { where: { id } });

      const audit = manager.create(Audit, {
        action: 'UPDATE_LOT_STATUS',
        entityName: 'Lot',
        entityId: id,
        userId,
        details: {
          oldStatus,
          newStatus: status,
          lotNumber: lot?.number,
          lotBlock: lot?.block,
          landName: lot?.landName,
          justification,
        },
      });
      await manager.save(audit);

      return lot;
    });

    // Notificação WebSocket fora da transação (não acessa o banco)
    this.eventsGateway.notifyLotStatusUpdated(id, status);

    return updatedLot;
  }

  async updateBulkStatus(ids: string[], status: string, userId?: string, justification?: string): Promise<Lot[]> {
    if (!ids || ids.length === 0) return [];

    const updatedLots = await this.lotRepository.manager.transaction(async (manager) => {
      const currentLots = await manager.createQueryBuilder(Lot, 'lot').whereInIds(ids).getMany();
      if (currentLots.length === 0) return [];

      await manager.createQueryBuilder()
        .update(Lot)
        .set({ status })
        .whereInIds(ids)
        .execute();

      const audits = currentLots.map(lot => manager.create(Audit, {
        action: 'UPDATE_LOT_STATUS_BULK',
        entityName: 'Lot',
        entityId: lot.id,
        userId,
        details: {
          oldStatus: lot.status,
          newStatus: status,
          lotNumber: lot.number,
          lotBlock: lot.block,
          landName: lot.landName,
          justification,
        },
      }));
      await manager.save(audits);

      return manager.createQueryBuilder(Lot, 'lot').whereInIds(ids).getMany();
    });

    updatedLots.forEach(lot => {
      this.eventsGateway.notifyLotStatusUpdated(lot.id, status);
    });

    return updatedLots;
  }

  async uploadDocument(id: string, file: Express.Multer.File, userId?: string): Promise<Lot> {
    const lot = await this.findOne(id);
    if (!lot) throw new NotFoundException('Lote não encontrado');
    
    // Armazenamento local
    const publicUrl = `http://localhost:3002/uploads/${file.filename}`;

    const documents = lot.documents || [];
    documents.push(publicUrl);
    
    await this.lotRepository.update(id, { documents });
    const updatedLot = await this.findOne(id);
    await this.auditService.logAction('UPLOAD_DOCUMENT', 'Lot', id, userId, { file: file.filename });
    return updatedLot;
  }
}
