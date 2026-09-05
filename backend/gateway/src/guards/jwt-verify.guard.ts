import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import * as jwt from 'jsonwebtoken';

// Throw error on boot if JWT_SECRET is not provided to avoid using a vulnerable default
const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  throw new Error('FATAL: JWT_SECRET não configurado! Por segurança, o sistema não pode iniciar sem uma chave secreta.');
}

@Injectable()
export class JwtVerifyGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    
    // Bypass authentication for public routes, GET /lots, or POST /clients
    if (request.url.includes('/public') || 
       (request.method === 'GET' && request.path === '/lots') ||
       (request.method === 'POST' && request.path === '/clients')) {
      return true;
    }

    const authHeader = request.headers['authorization'];

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('Token não fornecido.');
    }

    const token = authHeader.split(' ')[1];

    try {
      const decoded = jwt.verify(token, JWT_SECRET);
      request.user = decoded; // Anexa o payload do token ao request
      return true;
    } catch (error) {
      throw new UnauthorizedException('Token inválido ou expirado.');
    }
  }
}
