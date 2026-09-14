import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Task } from './task.entity';

@Injectable()
export class TasksService {
  constructor(
    @InjectRepository(Task)
    private readonly taskRepository: Repository<Task>,
  ) {}

  async create(taskData: Partial<Task>): Promise<Task> {
    const task = this.taskRepository.create(taskData);
    return this.taskRepository.save(task);
  }

  async findAll(limit = 50, offset = 0): Promise<{ data: Task[]; total: number }> {
    const [data, total] = await this.taskRepository.findAndCount({
      order: {
        date: 'ASC',
        time: 'ASC',
      },
      take: limit,
      skip: offset,
    });
    return { data, total };
  }
}
