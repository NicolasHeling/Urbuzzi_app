import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Lot } from './lot.entity';
import { AuditService } from '../audit/audit.service';
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
    const currentLot = await this.findOne(id);
    const oldStatus = currentLot?.status;
    await this.lotRepository.update(id, { status });
    const updatedLot = await this.findOne(id);
    await this.auditService.logAction('UPDATE_LOT_STATUS', 'Lot', id, userId, { 
      oldStatus, 
      newStatus: status,
      lotNumber: updatedLot?.number,
      lotBlock: updatedLot?.block,
      landName: updatedLot?.landName,
      justification,
    });
    this.eventsGateway.notifyLotStatusUpdated(id, status);
    return updatedLot;
  }

  async uploadDocument(id: string, file: Express.Multer.File, userId?: string): Promise<Lot> {
    const lot = await this.findOne(id);
    if (!lot) throw new Error('Lot not found');
    
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
