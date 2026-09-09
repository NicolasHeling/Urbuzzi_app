import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { VisitSchedule } from './entities/visit-schedule.entity';
import { CreateVisitScheduleDto, UpdateVisitScheduleDto } from './dto/visit-schedule.dto';
import { Lot } from '../lots/lot.entity';

@Injectable()
export class VisitsService {
  constructor(
    @InjectRepository(VisitSchedule)
    private readonly visitRepository: Repository<VisitSchedule>,
    @InjectRepository(Lot)
    private readonly lotRepository: Repository<Lot>,
  ) {}

  async findAll(): Promise<VisitSchedule[]> {
    return this.visitRepository.find({ relations: ['lot'] });
  }

  async create(createDto: CreateVisitScheduleDto): Promise<VisitSchedule> {
    const visit = this.visitRepository.create({
      customerName: createDto.customerName,
      date: new Date(createDto.date),
      responsibleUserName: createDto.responsibleUserName,
    });

    if (createDto.lotId) {
      const lot = await this.lotRepository.findOne({ where: { id: createDto.lotId } });
      if (lot) {
        visit.lot = lot;
      }
    }

    return this.visitRepository.save(visit);
  }

  async update(id: string, updateDto: UpdateVisitScheduleDto): Promise<VisitSchedule> {
    const visit = await this.visitRepository.findOne({ where: { id } });
    if (!visit) {
      throw new NotFoundException(`Visit with ID ${id} not found`);
    }

    if (updateDto.customerName) visit.customerName = updateDto.customerName;
    if (updateDto.date) visit.date = new Date(updateDto.date);
    if (updateDto.responsibleUserName) visit.responsibleUserName = updateDto.responsibleUserName;

    if (updateDto.lotId) {
      const lot = await this.lotRepository.findOne({ where: { id: updateDto.lotId } });
      if (lot) {
        visit.lot = lot;
      }
    }

    return this.visitRepository.save(visit);
  }

  async remove(id: string): Promise<void> {
    const result = await this.visitRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Visit with ID ${id} not found`);
    }
  }
}
