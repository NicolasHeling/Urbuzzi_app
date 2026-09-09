import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { KanbanColumn } from './kanban-column.entity';
import { KanbanController } from './kanban.controller';
import { KanbanService } from './kanban.service';

@Module({
  imports: [TypeOrmModule.forFeature([KanbanColumn])],
  controllers: [KanbanController],
  providers: [KanbanService],
  exports: [KanbanService],
})
export class KanbanModule {}
