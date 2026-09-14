import { Module } from '@nestjs/common';
import { LeadsController } from './leads.controller';
import { ProposalsModule } from '../proposals/proposals.module';

@Module({
  imports: [ProposalsModule],
  controllers: [LeadsController],
})
export class LeadsModule {}
