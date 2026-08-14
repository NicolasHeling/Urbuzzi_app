import { Controller, All, Req, Res, UseGuards } from '@nestjs/common';
import { Request, Response } from 'express';
import axios from 'axios';
import { JwtVerifyGuard } from '../guards/jwt-verify.guard';

@Controller()
@UseGuards(JwtVerifyGuard)  // Todas as rotas do core exigem autenticação
export class CoreProxyController {
  private readonly coreServiceUrl = 'http://core-service:3002';

  @All(['lots', 'lots/*', 'proposals', 'proposals/*', 'clients', 'clients/*', 'reservations', 'reservations/*', 'audit', 'audit/*'])
  async proxyCore(@Req() req: Request, @Res() res: Response) {
    try {
      const targetUrl = `${this.coreServiceUrl}${req.url}`;
      
      // Filtra headers — envia apenas os necessários para o microserviço
      const safeHeaders: Record<string, string> = {
        'content-type': req.headers['content-type'] || 'application/json',
        'host': 'core-service',
      };

      // Repassa informação do usuário autenticado
      if ((req as any).user) {
        safeHeaders['x-user-id'] = (req as any).user.sub;
        safeHeaders['x-user-email'] = (req as any).user.email;
        safeHeaders['x-user-role'] = (req as any).user.role;
      }

      const response = await axios({
        method: req.method,
        url: targetUrl,
        data: req.body,
        headers: safeHeaders,
      });
      return res.status(response.status).send(response.data);
    } catch (error: any) {
      if (error.response) {
        return res.status(error.response.status).send(error.response.data);
      }
      return res.status(500).send({ message: 'Core Service indisponível' });
    }
  }
}
