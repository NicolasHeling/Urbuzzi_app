import { Controller, All, Req, Res } from '@nestjs/common';
import { Request, Response } from 'express';
import axios from 'axios';

@Controller('auth')
export class AuthProxyController {
  private readonly authServiceUrl = 'http://auth-service:3001/auth';

  @All('*')
  async proxyAuth(@Req() req: Request, @Res() res: Response) {
    try {
      const targetUrl = `${this.authServiceUrl}/${req.params['0'] || ''}`;

      // Filtra headers — envia apenas os necessários
      const safeHeaders: Record<string, string> = {
        'content-type': req.headers['content-type'] || 'application/json',
        'host': 'auth-service',
      };

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
