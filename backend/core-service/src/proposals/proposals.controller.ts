import { Controller, Get, Post, Body, Param, Patch, ParseUUIDPipe, Req, ForbiddenException } from '@nestjs/common';
import { Request } from 'express';
import { ProposalsService } from './proposals.service';
import { Proposal } from './proposal.entity';
import { CreateProposalDto, UpdateProposalStatusDto } from './dto/proposal.dto';

@Controller('proposals')
export class ProposalsController {
  constructor(private readonly proposalsService: ProposalsService) {}

  @Get()
  findAll(): Promise<Proposal[]> {
    return this.proposalsService.findAll();
  }

  @Get(':id/history')
  getHistory(@Param('id', ParseUUIDPipe) id: string) {
    return this.proposalsService.getHistory(id);
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
    const userRole = (req.headers['x-user-role'] as string) || '';

    const restrictedStatuses = ['Aprovada', 'Rejeitada', 'Concluída'];
    if (restrictedStatuses.includes(updateStatusDto.status)) {
      if (userRole !== 'gestor' && userRole !== 'administrador') {
        throw new ForbiddenException(`O papel '${userRole}' não tem permissão para mover a proposta para o status '${updateStatusDto.status}'.`);
      }
    }

    return this.proposalsService.updateStatus(id, updateStatusDto.status, userId);
  }
}
