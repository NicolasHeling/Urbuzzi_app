import { IsString, IsIn } from 'class-validator';

export class UpdateLotStatusDto {
  @IsString()
  @IsIn(['Disponível', 'Reservado', 'Vendido'])
  status: string;
}
