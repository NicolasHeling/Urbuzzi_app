import { Module } from '@nestjs/common';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { AuthProxyModule } from './auth/auth-proxy.module';
import { CoreProxyModule } from './core/core-proxy.module';
import { HealthModule } from './health/health.module';

@Module({
  imports: [
    // Rate Limiting global: max 60 requisições por minuto por IP
    ThrottlerModule.forRoot([{
      ttl: 60000,
      limit: 60,
    }]),
    AuthProxyModule,
    CoreProxyModule,
    HealthModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}
