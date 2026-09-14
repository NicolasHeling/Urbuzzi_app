import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe, Logger } from '@nestjs/common';
import helmet from 'helmet';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Headers de segurança HTTP
  app.use(helmet());

  // CORS — restrito ao domínio da aplicação
  app.enableCors({
    origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  });

  // Validação global de DTOs — rejeita campos não declarados
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,        // Remove campos não declarados no DTO
    forbidNonWhitelisted: true, // Retorna erro se campos extras forem enviados
    transform: true,        // Transforma o body no tipo do DTO automaticamente
  }));

  // Auth service listens on 3001
  await app.listen(3001);
  Logger.log(`Auth-Service is running on: ${await app.getUrl()}`);
}
bootstrap();
