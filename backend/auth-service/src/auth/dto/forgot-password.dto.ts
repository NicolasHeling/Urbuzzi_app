import { IsEmail, IsNotEmpty } from 'class-validator';

export class ForgotPasswordDto {
  @IsEmail({}, { message: 'Por favor, informe um email válido' })
  @IsNotEmpty({ message: 'O email é obrigatório' })
  email: string;
}
