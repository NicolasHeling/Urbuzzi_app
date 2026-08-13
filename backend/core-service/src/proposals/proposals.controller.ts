import { Controller, Get, Post, Body, Param, Patch, ParseUUIDPipe } from '@nestjs/common';
import { ProposalsService } from './proposals.service';
import { Proposal } from './proposal.entity';
import { CreateProposalDto } from './dto/create-proposal.dto';
import { UpdateProposalStatusDto } from './dto/update-proposal-status.dto';

@Controller('proposals')
export class ProposalsController {
  constructor(private readonly proposalsService: ProposalsService) {}

  @Get()
  findAll(): Promise<Proposal[]> {
    return this.proposalsService.findAll();
  }

  @Post()
  create(@Body() createProposalDto: CreateProposalDto): Promise<Proposal> {
    return this.proposalsService.create(createProposalDto);
  }

  @Patch(':id/status')
  updateStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateStatusDto: UpdateProposalStatusDto,
  ): Promise<Proposal> {
    return this.proposalsService.updateStatus(id, updateStatusDto.status);
  }
}
