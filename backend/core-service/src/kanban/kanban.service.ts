import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { KanbanColumn } from './kanban-column.entity';

@Injectable()
export class KanbanService {
  constructor(
    @InjectRepository(KanbanColumn)
    private readonly columnRepo: Repository<KanbanColumn>,
  ) {}

  async findAll(projectId?: string): Promise<KanbanColumn[]> {
    const where = projectId ? { projectId } : {};
    return this.columnRepo.find({ where, order: { order: 'ASC' } });
  }

  async create(data: Partial<KanbanColumn>): Promise<KanbanColumn> {
    const newCol = this.columnRepo.create(data);
    return this.columnRepo.save(newCol);
  }

  async update(id: string, data: Partial<KanbanColumn>): Promise<KanbanColumn> {
    await this.columnRepo.update(id, data);
    return this.columnRepo.findOneOrFail({ where: { id } });
  }

  async remove(id: string): Promise<void> {
    await this.columnRepo.delete(id);
  }

  async reorder(batch: { id: string; order: number }[]): Promise<void> {
    await this.columnRepo.manager.transaction(async (manager) => {
      for (const item of batch) {
        await manager.update(KanbanColumn, item.id, { order: item.order });
      }
    });
  }

  async seedDefaults(projectId?: string): Promise<KanbanColumn[]> {
    const defaults = [
      { name: 'Nova', order: 0, color: '#C2650A', projectId, isFinal: false, isCancellation: false },
      { name: 'Em Análise', order: 1, color: '#2952A3', projectId, isFinal: false, isCancellation: false },
      { name: 'Aprovada', order: 2, color: '#1B7A3D', projectId, isFinal: false, isCancellation: false },
      { name: 'Rejeitada', order: 3, color: '#C62828', projectId, isFinal: false, isCancellation: true },
      { name: 'Concluída', order: 4, color: '#6B6B73', projectId, isFinal: true, isCancellation: false },
    ];
    const columns = this.columnRepo.create(defaults);
    return this.columnRepo.save(columns);
  }
}
