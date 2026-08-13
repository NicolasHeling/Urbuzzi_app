import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Validação global de DTOs — rejeita campos não declarados
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,        // Remove campos não declarados no DTO
    forbidNonWhitelisted: true, // Retorna erro se campos extras forem enviados
    transform: true,        // Transforma o body no tipo do DTO automaticamente
  }));

  // Auth service listens on 3001
  await app.listen(3001);
  console.log(`Auth-Service is running on: ${await app.getUrl()}`);
}
bootstrap();
