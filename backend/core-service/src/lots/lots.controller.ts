import { Controller, Get, Post, Body, Param, Patch, ParseUUIDPipe, Req, Query, UseInterceptors, UploadedFile } from '@nestjs/common';
import { Request } from 'express';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
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

  @Post(':id/documents')
  @Roles('gestor', 'administrador')
  @UseInterceptors(FileInterceptor('file', {
    storage: diskStorage({
      destination: './uploads',
      filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        const ext = extname(file.originalname);
        const name = file.originalname.split('.')[0].replace(/\s+/g, '-');
        cb(null, `${name}-${uniqueSuffix}${ext}`);
      },
    }),
  }))
  uploadDocument(
    @Param('id', ParseUUIDPipe) id: string,
    @UploadedFile() file: Express.Multer.File,
    @Req() req: Request,
  ): Promise<Lot> {
    const userId = req.headers['x-user-id'] as string;
    // We pass the filename to the service instead of the whole file
    return this.lotsService.uploadDocument(id, file, userId);
  }
}
