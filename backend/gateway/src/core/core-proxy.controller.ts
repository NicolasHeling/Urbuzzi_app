import { Controller, All, Req, Res, Next, UseGuards, Logger } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { createProxyMiddleware, fixRequestBody } from 'http-proxy-middleware';
import { JwtVerifyGuard } from '../guards/jwt-verify.guard';

@Controller()
@UseGuards(JwtVerifyGuard)  // Todas as rotas do core exigem autenticação
export class CoreProxyController {
  private readonly proxy = createProxyMiddleware({
    target: process.env.CORE_SERVICE_URL || 'http://core-service:3002',
    changeOrigin: true,
    on: {
      proxyReq: (proxyReq, req: any, res) => {
        Logger.log(`[Proxy] Forwarding ${req.method} ${req.url}`, 'CoreProxyController');
        if (req.user) {
          proxyReq.setHeader('x-user-id', req.user.sub);
          proxyReq.setHeader('x-user-email', req.user.email);
          proxyReq.setHeader('x-user-role', req.user.role);
        }
        // Fix for parsed body streams
        fixRequestBody(proxyReq, req);
      },
    },
  });

  @All(['lots', 'lots/*', 'proposals', 'proposals/*', 'clients', 'clients/*', 'reservations', 'reservations/*', 'audit', 'audit/*', 'dashboard', 'dashboard/*', 'tasks', 'tasks/*', 'projects', 'projects/*', 'kanban', 'kanban/*', 'analytics', 'analytics/*', 'visits', 'visits/*', 'pipeline', 'pipeline/*'])
  proxyCore(@Req() req: Request, @Res() res: Response, @Next() next: NextFunction) {
    // A função retorna void, e o proxy cuida de enviar a resposta
    (this.proxy as any)(req, res, next);
  }
}
