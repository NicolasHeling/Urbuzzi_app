import { IsString, IsIn } from 'class-validator';

export class UpdateProposalStatusDto {
  @IsString()
  @IsIn(['Nova', 'Em Análise', 'Aprovada', 'Rejeitada', 'Concluída'])
  status: string;
}
