import { IsString, IsEmail, IsOptional, MaxLength } from 'class-validator';

export class CreateClientDto {
  @IsString()
  @MaxLength(200)
  name: string;

  @IsString()
  @MaxLength(20)
  cpfOrCnpj: string;

  @IsEmail()
  email: string;

  @IsString()
  @MaxLength(20)
  phone: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  address?: string;
}
