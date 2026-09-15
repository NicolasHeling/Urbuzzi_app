import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CacheModule } from '@nestjs/cache-manager';
import { redisStore } from 'cache-manager-redis-yet';
import { LotsModule } from './lots/lots.module';
import { ProposalsModule } from './proposals/proposals.module';
import { AuditModule } from './audit/audit.module';
import { HealthModule } from './health/health.module';
import { ClientsModule } from './clients/clients.module';
import { ReservationsModule } from './reservations/reservations.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { TasksModule } from './tasks/tasks.module';
import { ProjectsModule } from './projects/projects.module';
import { NotificationsModule } from './notifications/notifications.module';
import { PipelineModule } from './pipeline/pipeline.module';
import { KanbanModule } from './kanban/kanban.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { VisitsModule } from './visits/visits.module';
import { CommissionsModule } from './commissions/commissions.module';
import { LeadsModule } from './leads/leads.module';
import { StorageModule } from './storage/storage.module';
import { ScheduleModule } from '@nestjs/schedule';
import { dataSourceOptions } from './data-source';
import { RolesGuard } from './guards/roles.guard';

@Module({
  imports: [
    CacheModule.register({
      isGlobal: true,
      store: redisStore,
      host: process.env.REDIS_HOST || 'localhost',
      port: 6379,
    }),
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
    DashboardModule,
    TasksModule,
    ProjectsModule,
    NotificationsModule,
    PipelineModule,
    KanbanModule,
    AnalyticsModule,
    VisitsModule,
    CommissionsModule,
    LeadsModule,
    StorageModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: RolesGuard,
    },
  ],
})
export class AppModule {}
