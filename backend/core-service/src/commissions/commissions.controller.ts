import { Controller, Get } from '@nestjs/common';
import { CommissionsService } from './commissions.service';
import { Commission } from './commission.entity';

@Controller('commissions')
export class CommissionsController {
  constructor(private readonly commissionsService: CommissionsService) {}

  @Get('summary')
  getSummary(): Promise<Commission[]> {
    return this.commissionsService.findAll();
  }
}
