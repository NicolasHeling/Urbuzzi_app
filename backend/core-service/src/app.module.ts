import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LotsModule } from './lots/lots.module';
import { ProposalsModule } from './proposals/proposals.module';
import { AuditModule } from './audit/audit.module';
import { HealthModule } from './health/health.module';
import { ClientsModule } from './clients/clients.module';
import { ReservationsModule } from './reservations/reservations.module';
import { ScheduleModule } from '@nestjs/schedule';
import { dataSourceOptions } from './data-source';

@Module({
  imports: [
    ScheduleModule.forRoot(),
    TypeOrmModule.forRoot({
      ...dataSourceOptions,
      autoLoadEntities: true,
    }),
    LotsModule,
    ProposalsModule,
    AuditModule,
    HealthModule,
    ClientsModule,
    ReservationsModule,
  ],
})
export class AppModule {}
