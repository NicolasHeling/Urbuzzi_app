import { Controller, Get, Post, Body, Param, Patch, ParseUUIDPipe, Req, Query } from '@nestjs/common';
import { Request } from 'express';
import { LotsService } from './lots.service';
import { Lot } from './lot.entity';
import { CreateLotDto, UpdateLotStatusDto } from './dto/lot.dto';
import { Roles } from '../guards/roles.guard';
import { Public } from '../decorators/public.decorator';

@Controller('lots')
export class LotsController {
  constructor(private readonly lotsService: LotsService) {}

  @Public()
  @Get()
  findAll(
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
    @Query('search') search?: string,
    @Query('status') status?: string,
  ) {
    const parsedLimit = limit ? parseInt(limit, 10) : 50;
    const parsedOffset = offset ? parseInt(offset, 10) : 0;
    return this.lotsService.findAll(parsedLimit, parsedOffset, search, status);
  }

  @Get('public')
  findPublic() {
    return this.lotsService.findPublic();
  }

  @Get(':id')
  findOne(@Param('id', ParseUUIDPipe) id: string): Promise<Lot> {
    return this.lotsService.findOne(id);
  }

  @Post()
  @Roles('gestor', 'administrador')
  create(@Body() createLotDto: CreateLotDto, @Req() req: Request): Promise<Lot> {
    const userId = req.headers['x-user-id'] as string;
    return this.lotsService.create(createLotDto, userId);
  }

  @Patch(':id/status')
  @Roles('gestor', 'administrador')
  updateStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateStatusDto: UpdateLotStatusDto,
    @Req() req: Request,
  ): Promise<Lot> {
    const userId = req.headers['x-user-id'] as string;
    return this.lotsService.updateStatus(id, updateStatusDto.status, userId, updateStatusDto.justification);
  }
}
