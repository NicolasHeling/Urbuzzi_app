import { Controller, Post, Get, Body, UseGuards, Req, HttpCode } from '@nestjs/common';
import { Request } from 'express';
import { AuthService } from './auth.service';
import { RegisterDto, LoginDto, RefreshDto } from './dto/auth.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { UsersService } from '../users/users.service';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly usersService: UsersService,
  ) {}

  @Post('register')
  register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @Post('login')
  login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  @Post('refresh')
  refresh(@Body() refreshDto: RefreshDto) {
    return this.authService.refreshTokens(refreshDto.refreshToken);
  }

  /**
   * GET /auth/me — retorna os dados do usuário logado.
   * Requer Authorization: Bearer <token>.
   * Usado pelo app Flutter no boot para restaurar o papel do usuário após F5.
   */
  @Get('me')
  @UseGuards(JwtAuthGuard)
  async me(@Req() req: Request & { user: any }) {
    const userId = req.user?.sub;
    const user = await this.usersService.findById(userId);
    if (!user) {
      return { id: null, name: null, email: null, role: 'consulta' };
    }
    return {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    };
  }


}
