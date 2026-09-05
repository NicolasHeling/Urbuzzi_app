import { Controller, Get, Post, Body } from '@nestjs/common';
import { ProjectsService } from './projects.service';
import { Project } from './project.entity';

@Controller('projects')
export class ProjectsController {
  constructor(private readonly projectsService: ProjectsService) {}

  @Post()
  create(@Body() projectData: Partial<Project>) {
    return this.projectsService.create(projectData);
  }

  @Get()
  findAll() {
    return this.projectsService.findAll();
  }
}
