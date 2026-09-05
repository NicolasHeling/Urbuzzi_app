import { Controller, Get, UseGuards } from '@nestjs/common';
import { DashboardService } from './dashboard.service';
import { RolesGuard } from '../guards/roles.guard';

@UseGuards(RolesGuard)
@Controller('dashboard')
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get('funnel')
  async getFunnelMetrics() {
    return this.dashboardService.getFunnelMetrics();
  }
}
