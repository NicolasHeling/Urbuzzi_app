import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PipelineStage } from './pipeline-stage.entity';

@Injectable()
export class PipelineService {
  constructor(
    @InjectRepository(PipelineStage)
    private readonly stageRepository: Repository<PipelineStage>,
  ) {}

  async findAll(projectId?: string): Promise<PipelineStage[]> {
    const where: any = { isActive: true };
    if (projectId) where.projectId = projectId;
    return this.stageRepository.find({ where, order: { order: 'ASC' } });
  }

  async create(data: Partial<PipelineStage>): Promise<PipelineStage> {
    const stage = this.stageRepository.create(data);
    return this.stageRepository.save(stage);
  }

  async update(id: string, data: Partial<PipelineStage>): Promise<PipelineStage> {
    await this.stageRepository.update(id, data);
    return this.stageRepository.findOne({ where: { id } });
  }

  async remove(id: string): Promise<void> {
    await this.stageRepository.update(id, { isActive: false });
  }

  async reorder(stages: { id: string; order: number }[]): Promise<void> {
    for (const stage of stages) {
      await this.stageRepository.update(stage.id, { order: stage.order });
    }
  }

  async seedDefaults(projectId: string): Promise<PipelineStage[]> {
    const existing = await this.stageRepository.find({ where: { projectId } });
    if (existing.length > 0) return existing;

    const defaults = [
      { name: 'Nova', order: 0, color: '#C2650A', projectId, isFinal: false, isCancellation: false },
      { name: 'Em Análise', order: 1, color: '#9A6B28', projectId, isFinal: false, isCancellation: false },
      { name: 'Aprovada', order: 2, color: '#1B7A3D', projectId, isFinal: false, isCancellation: false },
      { name: 'Concluída', order: 3, color: '#2952A3', projectId, isFinal: true, isCancellation: false },
      { name: 'Rejeitada', order: 4, color: '#3A3A42', projectId, isFinal: false, isCancellation: true },
    ];

    const stages = this.stageRepository.create(defaults);
    return this.stageRepository.save(stages);
  }
}
