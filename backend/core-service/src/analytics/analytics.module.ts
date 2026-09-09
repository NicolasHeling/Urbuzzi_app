import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AnalyticsService } from './analytics.service';
import { AnalyticsController } from './analytics.controller';
import { Lot } from '../lots/lot.entity';
import { Proposal } from '../proposals/proposal.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Lot, Proposal])],
  controllers: [AnalyticsController],
  providers: [AnalyticsService],
})
export class AnalyticsModule {}
