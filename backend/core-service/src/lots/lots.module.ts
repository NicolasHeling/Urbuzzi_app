import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Lot } from './lot.entity';
import { LotsService } from './lots.service';
import { LotsController } from './lots.controller';
import { AuditModule } from '../audit/audit.module';

@Module({
  imports: [TypeOrmModule.forFeature([Lot]), AuditModule],
  controllers: [LotsController],
  providers: [LotsService],
  exports: [LotsService, TypeOrmModule],
})
export class LotsModule {}
