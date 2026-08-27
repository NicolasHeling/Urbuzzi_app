import { RolesGuard } from './roles.guard';
import { Reflector } from '@nestjs/core';
import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { HttpArgumentsHost } from '@nestjs/common/interfaces';

describe('RolesGuard', () => {
  let guard: RolesGuard;
  let reflector: Reflector;

  beforeEach(() => {
    reflector = new Reflector();
    guard = new RolesGuard(reflector);
  });

  const createMockContext = (method: string, role: string, handler: any = () => {}): ExecutionContext => {
    const mockHttpHost = {
      getRequest: jest.fn().mockReturnValue({
        method,
        headers: {
          'x-user-role': role,
        },
      }),
    } as unknown as HttpArgumentsHost;

    return {
      switchToHttp: () => mockHttpHost,
      getHandler: () => handler,
      getClass: () => ({}),
      getArgs: () => [],
      getArgByIndex: () => null,
      switchToRpc: () => null,
      switchToWs: () => null,
      getType: () => 'http',
    } as unknown as ExecutionContext;
  };

  it('(a) usuário com papel "consulta" tentando fazer POST/PATCH/DELETE deve ser bloqueado', () => {
    const methods = ['POST', 'PATCH', 'DELETE', 'PUT'];
    for (const method of methods) {
      const context = createMockContext(method, 'consulta');
      jest.spyOn(reflector, 'get').mockReturnValue(undefined); // Sem @Roles

      expect(() => guard.canActivate(context)).toThrow(ForbiddenException);
    }
  });

  it('(b) usuário com papel "consulta" fazendo GET deve passar', () => {
    const context = createMockContext('GET', 'consulta');
    jest.spyOn(reflector, 'get').mockReturnValue(undefined);

    expect(guard.canActivate(context)).toBe(true);
  });

  it('(c) rota marcada com @Roles("gestor","administrador") deve bloquear "comercial" e permitir "gestor"', () => {
    // Bloquear "comercial"
    const contextComercial = createMockContext('POST', 'comercial');
    jest.spyOn(reflector, 'get').mockReturnValue(['gestor', 'administrador']);
    
    expect(() => guard.canActivate(contextComercial)).toThrow(ForbiddenException);

    // Permitir "gestor"
    const contextGestor = createMockContext('POST', 'gestor');
    expect(guard.canActivate(contextGestor)).toBe(true);
  });

  it('(d) rota sem @Roles nenhum deve permitir qualquer papel que não seja "consulta" em escrita', () => {
    const context = createMockContext('POST', 'comercial');
    jest.spyOn(reflector, 'get').mockReturnValue(undefined);

    expect(guard.canActivate(context)).toBe(true);
  });
});
