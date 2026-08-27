import { Controller, Get, Post, Body, Param, Patch, ParseUUIDPipe, Req } from '@nestjs/common';
import { Request } from 'express';
import { LotsService } from './lots.service';
import { Lot } from './lot.entity';
import { CreateLotDto } from './dto/create-lot.dto';
import { UpdateLotStatusDto } from './dto/update-lot-status.dto';
import { Roles } from '../guards/roles.guard';
import { Public } from '../decorators/public.decorator';

@Controller('lots')
export class LotsController {
  constructor(private readonly lotsService: LotsService) {}

  @Public()
  @Get()
  findAll(): Promise<Lot[]> {
    return this.lotsService.findAll();
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
