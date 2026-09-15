import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { AppModule } from './app.module';
import helmet from 'helmet';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Headers de segurança HTTP
  app.use(helmet());

  // CORS — configure com os domínios permitidos em produção
  app.enableCors({
    origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  });

  const { createProxyMiddleware } = require('http-proxy-middleware');

  // Proxy WebSocket para o core-service
  const wsProxy = createProxyMiddleware({
    target: process.env.CORE_SERVICE_URL || 'http://core-service:3002',
    changeOrigin: true,
    ws: true, // Habilita proxy de WebSocket
    logLevel: 'error',
  });

  app.use('/socket.io', wsProxy);

  const server = await app.listen(3000);
  
  // Ouve os upgrades do servidor HTTP para passar para o proxy WS
  server.on('upgrade', wsProxy.upgrade);

  Logger.log(`Gateway is running on: ${await app.getUrl()}`);
}
bootstrap();
