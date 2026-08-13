import { IsString, IsNumber, IsUUID, IsOptional, Min, MaxLength } from 'class-validator';

export class CreateProposalDto {
  @IsString()
  @MaxLength(200)
  customerName: string;

  @IsString()
  @MaxLength(20)
  customerDocument: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  offeredPrice?: number;

  @IsUUID()
  lotId: string;
}
