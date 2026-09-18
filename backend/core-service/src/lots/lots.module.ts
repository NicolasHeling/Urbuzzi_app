import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Lot } from './lot.entity';
import { LotsService } from './lots.service';
import { LotsController } from './lots.controller';
import { AuditModule } from '../audit/audit.module';

import { EventsGateway } from './events.gateway';

import { StorageModule } from '../storage/storage.module';

@Module({
  imports: [TypeOrmModule.forFeature([Lot]), AuditModule, StorageModule],
  controllers: [LotsController],
  providers: [LotsService, EventsGateway],
  exports: [LotsService, TypeOrmModule],
})
export class LotsModule {}
