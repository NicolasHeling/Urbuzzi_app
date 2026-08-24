import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';

export const ROLES_KEY = 'roles';

/**
 * Decorator @Roles('gestor', 'administrador')
 * Marca uma rota como exigindo um dos papéis listados.
 */
export const Roles = (...roles: string[]): MethodDecorator & ClassDecorator =>
  (target: any, key?: string | symbol, descriptor?: PropertyDescriptor) => {
    const target2 = descriptor?.value ?? target;
    Reflect.defineMetadata(ROLES_KEY, roles, target2);
    return descriptor ?? target;
  };

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const method = request.method as string;
    const role = (request.headers['x-user-role'] as string) || '';

    // Verificar se a rota tem @Roles() específico
    const requiredRoles = this.reflector.get<string[]>(
      ROLES_KEY,
      context.getHandler(),
    );

    if (requiredRoles && requiredRoles.length > 0) {
      // Rota tem @Roles() — verificar se o usuário tem um dos papéis requeridos
      if (!requiredRoles.includes(role)) {
        throw new ForbiddenException(
          `Requer papel: ${requiredRoles.join(' ou ')}. Papel atual: ${role || 'nenhum'}`,
        );
      }
      return true;
    }

    // Sem @Roles() específico: bloquear métodos de escrita para papel 'consulta'
    const writeMethods = ['POST', 'PATCH', 'PUT', 'DELETE'];
    if (writeMethods.includes(method) && role === 'consulta') {
      throw new ForbiddenException(
        'Papel "consulta" não tem permissão para operações de escrita.',
      );
    }

    return true;
  }
}
