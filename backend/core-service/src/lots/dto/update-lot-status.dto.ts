import { IsString, IsIn } from 'class-validator';

export class UpdateLotStatusDto {
  @IsString()
  @IsIn(['Disponível', 'Reservado', 'Vendido', 'Em aprovação', 'Bloqueado', 'Cancelado'])
  status: string;
}
