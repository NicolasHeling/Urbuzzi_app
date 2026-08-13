import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import helmet from 'helmet';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Headers de segurança HTTP
  app.use(helmet());

  // CORS — configure com os domínios permitidos em produção
  app.enableCors({
    origin: process.env.CORS_ORIGIN || '*', // Em produção, especifique o domínio do app
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  });

  await app.listen(3000);
  console.log(`Gateway is running on: ${await app.getUrl()}`);
}
bootstrap();
