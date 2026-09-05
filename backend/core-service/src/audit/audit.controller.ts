import { Controller, Get, Query, Param } from '@nestjs/common';
import { AuditService } from './audit.service';

@Controller('audit')
export class AuditController {
  constructor(private readonly auditService: AuditService) {}

  @Get()
  findAll(
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
    @Query('userId') userId?: string,
    @Query('action') action?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const parsedLimit = limit ? parseInt(limit, 10) : 50;
    const parsedOffset = offset ? parseInt(offset, 10) : 0;
    return this.auditService.findAll(parsedLimit, parsedOffset, userId, action, startDate, endDate);
  }

  @Get('lot/:id')
  findByLotId(@Param('id') id: string) {
    return this.auditService.findByLotId(id);
  }
}
