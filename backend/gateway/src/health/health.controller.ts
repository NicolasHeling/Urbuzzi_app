import { Controller, Get } from '@nestjs/common';
import { HealthCheckService, HttpHealthIndicator, HealthCheck } from '@nestjs/terminus';

@Controller('health')
export class HealthController {
  private readonly authUrl = process.env.AUTH_SERVICE_URL || 'http://auth-service:3001';
  private readonly coreUrl = process.env.CORE_SERVICE_URL || 'http://core-service:3002';

  constructor(
    private health: HealthCheckService,
    private http: HttpHealthIndicator,
  ) {}

  @Get()
  @HealthCheck()
  check() {
    return this.health.check([
      () => this.http.pingCheck('auth-service', `${this.authUrl}/health`),
      () => this.http.pingCheck('core-service', `${this.coreUrl}/health`),
    ]);
  }
}
