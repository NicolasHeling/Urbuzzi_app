import { Controller, Post, Body } from '@nestjs/common';
import { ProposalsService } from '../proposals/proposals.service';
import { Public } from '../decorators/public.decorator';

@Controller('leads')
export class LeadsController {
  constructor(private readonly proposalsService: ProposalsService) {}

  @Public()
  @Post()
  async createLead(@Body() body: { name: string; phone: string; email: string; lotId: string }) {
    const proposalData = {
      customerName: body.name,
      customerDocument: 'LEAD',
      lotId: body.lotId,
      status: 'Nova',
      offeredPrice: 0,
      responsibleUserName: 'Lead Publico',
    };
    return this.proposalsService.create(proposalData, 'system-lead');
  }
}
