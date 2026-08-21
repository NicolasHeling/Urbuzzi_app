import { Controller, Get, Post, Body, Param, Patch, ParseUUIDPipe, Req } from '@nestjs/common';
import { Request } from 'express';
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
  create(@Body() createProposalDto: CreateProposalDto, @Req() req: Request): Promise<Proposal> {
    const userId = req.headers['x-user-id'] as string;
    return this.proposalsService.create(createProposalDto, userId);
  }

  @Patch(':id/status')
  updateStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateStatusDto: UpdateProposalStatusDto,
    @Req() req: Request,
  ): Promise<Proposal> {
    const userId = req.headers['x-user-id'] as string;
    return this.proposalsService.updateStatus(id, updateStatusDto.status, userId);
  }
}
