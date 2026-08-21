import { IsUUID } from 'class-validator';

export class CreateReservationDto {
  @IsUUID()
  clientId: string;

  @IsUUID()
  lotId: string;
}
