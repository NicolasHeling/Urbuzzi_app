import { Controller, Get, Post, Patch, Delete, Body, Param, Query } from '@nestjs/common';
import { KanbanService } from './kanban.service';

@Controller('kanban')
export class KanbanController {
  constructor(private readonly kanbanService: KanbanService) {}

  @Get()
  findAll(@Query('projectId') projectId?: string) {
    return this.kanbanService.findAll(projectId);
  }

  @Post()
  create(@Body() data: any) {
    return this.kanbanService.create(data);
  }

  @Patch('reorder/batch')
  reorder(@Body() batch: { id: string; order: number }[]) {
    return this.kanbanService.reorder(batch);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() data: any) {
    return this.kanbanService.update(id, data);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.kanbanService.remove(id);
  }

  @Post('seed')
  seedDefaults(@Body('projectId') projectId?: string) {
    return this.kanbanService.seedDefaults(projectId);
  }
}
