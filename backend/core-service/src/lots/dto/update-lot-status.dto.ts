import { IsString, IsIn, IsOptional } from 'class-validator';

export class UpdateLotStatusDto {
  @IsString()
  @IsIn(['Disponível', 'Reservado', 'Vendido', 'Em aprovação', 'Bloqueado', 'Cancelado'])
  status: string;

  @IsOptional()
  @IsString()
  justification?: string;
}
