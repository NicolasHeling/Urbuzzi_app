import { IsString, IsNumber, IsUUID, IsOptional, Min, MaxLength, IsIn } from 'class-validator';

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

  @IsOptional()
  @IsString()
  @MaxLength(200)
  responsibleUserName?: string;
}

export class UpdateProposalStatusDto {
  @IsString()
  @IsIn(['Nova', 'Em Análise', 'Aprovada', 'Rejeitada', 'Concluída'])
  status: string;
}
