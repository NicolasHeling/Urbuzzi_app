import { Controller, All, Req, Res, Post } from '@nestjs/common';
import { Request, Response } from 'express';
import axios from 'axios';

@Controller('auth')
export class AuthProxyController {
  private readonly authServiceUrl = 'http://auth-service:3001';

  @All('*')
  async proxyAuth(@Req() req: Request, @Res() res: Response) {
    try {
      const targetUrl = `${this.authServiceUrl}${req.url}`;

      // Repassa headers necessários, incluindo Authorization para rotas protegidas como /auth/me
      const safeHeaders: Record<string, string> = {
        'content-type': req.headers['content-type'] || 'application/json',
        'host': 'auth-service',
      };

      // Repassar o token JWT para que o auth-service possa autenticar /auth/me
      if (req.headers['authorization']) {
        safeHeaders['authorization'] = req.headers['authorization'] as string;
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
      return res.status(500).send({ message: 'Auth Service indisponível' });
    }
  }
}
