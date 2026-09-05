import { Controller, Get, Post, Body } from '@nestjs/common';
import { TasksService } from './tasks.service';
import { Task } from './task.entity';

@Controller('tasks')
export class TasksController {
  constructor(private readonly tasksService: TasksService) {}

  @Post()
  create(@Body() taskData: Partial<Task>) {
    return this.tasksService.create(taskData);
  }

  @Get()
  findAll() {
    return this.tasksService.findAll();
  }
}
