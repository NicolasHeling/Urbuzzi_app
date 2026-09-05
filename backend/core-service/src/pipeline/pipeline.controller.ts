import { Controller, Get, Post, Patch, Delete, Body, Param, Query, ParseUUIDPipe } from '@nestjs/common';
import { PipelineService } from './pipeline.service';
import { PipelineStage } from './pipeline-stage.entity';

@Controller('pipeline')
export class PipelineController {
  constructor(private readonly pipelineService: PipelineService) {}

  @Get()
  findAll(@Query('projectId') projectId?: string): Promise<PipelineStage[]> {
    return this.pipelineService.findAll(projectId);
  }

  @Post()
  create(@Body() data: Partial<PipelineStage>): Promise<PipelineStage> {
    return this.pipelineService.create(data);
  }

  @Post('seed')
  seed(@Body() body: { projectId: string }): Promise<PipelineStage[]> {
    return this.pipelineService.seedDefaults(body.projectId);
  }

  @Patch(':id')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() data: Partial<PipelineStage>,
  ): Promise<PipelineStage> {
    return this.pipelineService.update(id, data);
  }

  @Patch('reorder/batch')
  reorder(@Body() stages: { id: string; order: number }[]): Promise<void> {
    return this.pipelineService.reorder(stages);
  }

  @Delete(':id')
  remove(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.pipelineService.remove(id);
  }
}
