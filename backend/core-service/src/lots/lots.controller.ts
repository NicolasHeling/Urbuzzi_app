import { Controller, Get, Post, Body, Param, Patch, ParseUUIDPipe, Req } from '@nestjs/common';
import { Request } from 'express';
import { LotsService } from './lots.service';
import { Lot } from './lot.entity';
import { CreateLotDto } from './dto/create-lot.dto';
import { UpdateLotStatusDto } from './dto/update-lot-status.dto';

@Controller('lots')
export class LotsController {
  constructor(private readonly lotsService: LotsService) {}

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
  create(@Body() createLotDto: CreateLotDto, @Req() req: Request): Promise<Lot> {
    const userId = req.headers['x-user-id'] as string;
    return this.lotsService.create(createLotDto, userId);
  }

  @Patch(':id/status')
  updateStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateStatusDto: UpdateLotStatusDto,
    @Req() req: Request,
  ): Promise<Lot> {
    const userId = req.headers['x-user-id'] as string;
    return this.lotsService.updateStatus(id, updateStatusDto.status, userId);
  }
}
