import { Controller, Get, Post, Put, Delete, Body, Param, ParseUUIDPipe } from '@nestjs/common';
import { VisitsService } from './visits.service';
import { CreateVisitScheduleDto, UpdateVisitScheduleDto } from './dto/visit-schedule.dto';

@Controller('visits')
export class VisitsController {
  constructor(private readonly visitsService: VisitsService) {}

  @Get()
  findAll() {
    return this.visitsService.findAll();
  }

  @Post()
  create(@Body() createDto: CreateVisitScheduleDto) {
    return this.visitsService.create(createDto);
  }

  @Put(':id')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateDto: UpdateVisitScheduleDto,
  ) {
    return this.visitsService.update(id, updateDto);
  }

  @Delete(':id')
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.visitsService.remove(id);
  }
}
