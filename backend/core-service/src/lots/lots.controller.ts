import { Controller, Get, Post, Body, Param, Patch, ParseUUIDPipe, Req, Query, UseInterceptors, UploadedFile } from '@nestjs/common';
import { CacheInterceptor, CacheTTL } from '@nestjs/cache-manager';
import { Request } from 'express';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { LotsService } from './lots.service';
import { Lot } from './lot.entity';
import { CreateLotDto, UpdateLotStatusDto, UpdateLotBulkStatusDto } from './dto/lot.dto';
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

  /**
   * Retorna os dados de polígonos de todos os lotes para renderizar o mapa interativo.
   * Endpoint leve: retorna apenas id, block, number, status, mapPolygons e landName.
   */
  @Public()
  @UseInterceptors(CacheInterceptor)
  @CacheTTL(60000)
  @Get('map-polygons')
  findMapPolygons(@Query('landName') landName?: string) {
    return this.lotsService.findMapPolygons(landName);
  }

  @Public()
  @UseInterceptors(CacheInterceptor)
  @CacheTTL(60000)
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

  @Patch('bulk-status')
  updateBulkStatus(
    @Body() updateBulkStatusDto: UpdateLotBulkStatusDto,
    @Req() req: Request,
  ): Promise<Lot[]> {
    const userId = req.headers['x-user-id'] as string;
    return this.lotsService.updateBulkStatus(updateBulkStatusDto.ids, updateBulkStatusDto.status, userId, updateBulkStatusDto.justification);
  }

  @Patch(':id/status')
  // @Roles('gestor', 'administrador') — removido para permitir edição por todos os usuários autenticados
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
    limits: {
      fileSize: 10 * 1024 * 1024, // 10MB max
    },
    fileFilter: (req, file, cb) => {
      const allowedMimes = [
        'application/pdf',
        'image/jpeg',
        'image/png',
        'image/webp',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      ];
      if (allowedMimes.includes(file.mimetype)) {
        cb(null, true);
      } else {
        cb(new Error(`Tipo de arquivo não permitido: ${file.mimetype}. Permitidos: PDF, JPEG, PNG, WEBP, DOC, DOCX`), false);
      }
    },
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
