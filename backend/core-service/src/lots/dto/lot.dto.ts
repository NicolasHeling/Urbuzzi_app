import { IsString, IsNumber, IsOptional, Min, MaxLength, IsIn } from 'class-validator';

export class CreateLotDto {
  @IsString()
  @MaxLength(10)
  block: string;

  @IsString()
  @MaxLength(20)
  number: string;

  @IsNumber()
  @Min(0)
  area: number;

  @IsNumber()
  @Min(0)
  price: number;

  @IsOptional()
  @IsString()
  status?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  registration?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  frontMeasure?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  backMeasure?: number;

  @IsOptional()
  @IsString()
  svgCoordinates?: string;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  landName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  whatsappNumber?: string;
}

export class UpdateLotStatusDto {
  @IsString()
  @IsIn(['Disponível', 'Reservado', 'Vendido', 'Em aprovação', 'Bloqueado', 'Cancelado'])
  status: string;

  @IsOptional()
  @IsString()
  justification?: string;
}
