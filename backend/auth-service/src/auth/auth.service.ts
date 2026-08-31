import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  async register(registerDto: RegisterDto) {
    const { name, email, password } = registerDto;

    // Verificar se o email já existe
    const existingUser = await this.usersService.findByEmail(email);
    if (existingUser) {
      throw new ConflictException('Este email já está cadastrado.');
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // SEGURANÇA: Apenas name, email e passwordHash são passados.
    // O campo 'role' NÃO é aceito do request — previne escalação de privilégios.
    const user = await this.usersService.create({ name, email, passwordHash });
    
    return this.getTokens(user);
  }

  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;
    const user = await this.usersService.findByEmail(email);

    if (!user) {
      throw new UnauthorizedException('Credenciais inválidas');
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      throw new UnauthorizedException('Credenciais inválidas');
    }

    return this.getTokens(user);
  }

  private async getTokens(user: any) {
    const payload = { sub: user.id, email: user.email, role: user.role };
    
    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload),
      this.jwtService.signAsync(payload, { expiresIn: '7d' }),
    ]);

    const salt = await bcrypt.genSalt(10);
    const hashedRefreshToken = await bcrypt.hash(refreshToken, salt);
    await this.usersService.update(user.id, { hashedRefreshToken });

    return {
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role
      }
    };
  }

  async refreshTokens(refreshToken: string) {
    try {
      const payload = await this.jwtService.verifyAsync(refreshToken);
      const user = await this.usersService.findById(payload.sub);
      
      if (!user || !user.hashedRefreshToken) {
        throw new UnauthorizedException('Token inválido');
      }

      const isMatch = await bcrypt.compare(refreshToken, user.hashedRefreshToken);
      if (!isMatch) {
        throw new UnauthorizedException('Token inválido');
      }

      return this.getTokens(user);
    } catch (error) {
      throw new UnauthorizedException('Token inválido ou expirado');
    }
  }

  async forgotPassword(email: string) {
    const user = await this.usersService.findByEmail(email);
    if (!user) {
      // Para não vazar quais emails existem, retornamos sucesso silencioso
      return { message: 'Se o email existir, um link de recuperação foi enviado.' };
    }

    // Cria um secret único para o usuário, baseado na senha atual
    // Assim, se a senha for alterada, o token é invalidado imediatamente
    const secret = process.env.JWT_SECRET + user.passwordHash;
    const payload = { sub: user.id, email: user.email };
    const resetToken = await this.jwtService.signAsync(payload, {
      secret,
      expiresIn: '1h',
    });

    console.log(`[EMAIL MOCK] Solicitação de redefinição para ${email}. Token: ${resetToken}`);

    return { 
      success: true,
      message: 'Se o email existir, um link de recuperação foi enviado.' 
    };
  }

  async resetPassword(token: string, newPassword: string) {
    try {
      // O JWT service não consegue verificar sozinho pois não sabe o secret ainda.
      // Primeiro decodificamos sem verificar para pegar o ID.
      const decoded = this.jwtService.decode(token) as any;
      if (!decoded || !decoded.sub) {
        throw new UnauthorizedException('Token inválido ou expirado.');
      }

      const user = await this.usersService.findById(decoded.sub);
      if (!user) {
        throw new UnauthorizedException('Usuário não encontrado.');
      }

      // Agora verificamos com a assinatura correta
      const secret = process.env.JWT_SECRET + user.passwordHash;
      await this.jwtService.verifyAsync(token, { secret });

      // Hash da nova senha
      const salt = await bcrypt.genSalt(10);
      const passwordHash = await bcrypt.hash(newPassword, salt);

      await this.usersService.update(user.id, { passwordHash });

      return { message: 'Senha alterada com sucesso.' };
    } catch (error) {
      throw new UnauthorizedException('Token inválido ou expirado.');
    }
  }
}
