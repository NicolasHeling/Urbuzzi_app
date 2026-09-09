import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VisitsService } from './visits.service';
import { VisitsController } from './visits.controller';
import { VisitSchedule } from './entities/visit-schedule.entity';
import { Lot } from '../lots/lot.entity';

@Module({
  imports: [TypeOrmModule.forFeature([VisitSchedule, Lot])],
  controllers: [VisitsController],
  providers: [VisitsService],
})
export class VisitsModule {}
