import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Proposal } from './proposal.entity';
import { ProposalHistory } from './proposal-history.entity';
import { Lot } from '../lots/lot.entity';
import { Reservation } from '../reservations/entities/reservation.entity';
import { ProposalsService } from './proposals.service';
import { ProposalsController } from './proposals.controller';
import { AuditModule } from '../audit/audit.module';
import { ProposalSubscriber } from './proposal.subscriber';

@Module({
  imports: [TypeOrmModule.forFeature([Proposal, ProposalHistory, Lot, Reservation]), AuditModule],
  controllers: [ProposalsController],
  providers: [ProposalsService, ProposalSubscriber],
})
export class ProposalsModule {}
