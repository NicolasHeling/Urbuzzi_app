import { Controller, Get, Post, Body, Param, Patch, Query, ParseUUIDPipe, Req, ForbiddenException, Res } from '@nestjs/common';
import { Request, Response } from 'express';
import { ProposalsService } from './proposals.service';
import { ContractsService } from './contracts.service';
import { Proposal } from './proposal.entity';
import { CreateProposalDto, UpdateProposalStatusDto } from './dto/proposal.dto';

@Controller('proposals')
export class ProposalsController {
  constructor(
    private readonly proposalsService: ProposalsService,
    private readonly contractsService: ContractsService,
  ) {}

  @Get()
  findAll(
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ): Promise<{ data: Proposal[]; total: number }> {
    const parsedLimit = limit ? parseInt(limit, 10) : 50;
    const parsedOffset = offset ? parseInt(offset, 10) : 0;
    return this.proposalsService.findAll(parsedLimit, parsedOffset);
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

    return this.proposalsService.updateStatus(id, updateStatusDto.status, userId, updateStatusDto.rejectionReason);
  }

  @Get(':id/contract')
  async getContract(@Param('id', ParseUUIDPipe) id: string, @Res() res: Response) {
    const pdfDoc = await this.contractsService.generateContract(id);
    res.set({
      'Content-Type': 'application/pdf',
      'Content-Disposition': `attachment; filename="contract-${id}.pdf"`,
    });
    pdfDoc.pipe(res);
  }
}
