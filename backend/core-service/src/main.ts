import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { DataSource } from 'typeorm';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Validação global de DTOs
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

  // Seeding inicial (Executa após o TypeORM criar as tabelas)
  const dataSource = app.get(DataSource);
  const count = await dataSource.query(`SELECT COUNT(*) FROM lots`);
  if (parseInt(count[0].count) === 0) {
    console.log('Populando banco de dados com dados iniciais (Seed)...');
    await dataSource.query(`
      INSERT INTO lots (id, block, number, area, price, status, "landName", "createdAt", "updatedAt") VALUES
      ('11111111-1111-1111-1111-111111111111', 'A', '12', 300.00, 150000.00, 'Disponível', 'Loteamento Biopark', NOW(), NOW()),
      ('22222222-2222-2222-2222-222222222222', 'A', '13', 312.50, 162500.00, 'Reservado', 'Loteamento Biopark', NOW(), NOW()),
      ('33333333-3333-3333-3333-333333333333', 'B', '04', 360.00, 189900.00, 'Disponível', 'Loteamento Biopark', NOW(), NOW()),
      ('44444444-4444-4444-4444-444444444444', 'B', '05', 360.00, 192000.00, 'Reservado', 'Loteamento Biopark', NOW(), NOW()),
      ('55555555-5555-5555-5555-555555555551', 'C', '08', 250.00, 121000.00, 'Disponível', 'Residencial Vista Verde', NOW(), NOW()),
      ('66666666-6666-6666-6666-666666666661', 'D', '22', 400.00, 226000.00, 'Em aprovação', 'Residencial Vista Verde', NOW(), NOW()),
      ('77777777-7777-7777-7777-777777777771', 'E', '02', 480.00, 289000.00, 'Disponível', 'Parque das Araucárias', NOW(), NOW()),
      ('88888888-8888-8888-8888-888888888881', 'E', '03', 350.00, 268000.00, 'Cancelado', 'Parque das Araucárias', NOW(), NOW()),
      ('99999999-9999-9999-9999-999999999991', 'F', '11', 320.00, 201000.00, 'Vendido', 'Parque das Araucárias', NOW(), NOW()),
      ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'C', '07', 280.00, 118000.00, 'Vendido', 'Residencial Vista Verde', NOW(), NOW()),
      ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'F', '10', 330.00, 198500.00, 'Disponível', 'Parque das Araucárias', NOW(), NOW()),
      ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'D', '21', 370.00, 215000.00, 'Bloqueado', 'Residencial Vista Verde', NOW(), NOW());
    `);
    await dataSource.query(`
      INSERT INTO proposals (id, "customerName", "customerDocument", status, "offeredPrice", lot_id, "responsibleUserName", "slaDeadline", "createdAt", "updatedAt") VALUES
      ('55555555-5555-5555-5555-555555555555', 'Marina Duarte', '111.222.333-44', 'Nova', 162500.00, '22222222-2222-2222-2222-222222222222', 'Carla Menezes', NOW() + INTERVAL '5 days', NOW(), NOW()),
      ('66666666-6666-6666-6666-666666666666', 'Ricardo Bomfim', '555.666.777-88', 'Nova', 192000.00, '44444444-4444-4444-4444-444444444444', 'João Vitor Salles', NOW() + INTERVAL '6 days', NOW(), NOW()),
      ('77777777-7777-7777-7777-777777777777', 'Fernanda Kliemann', '999.000.111-22', 'Em Análise', 189900.00, '33333333-3333-3333-3333-333333333333', 'Carla Menezes', NOW() + INTERVAL '3 days', NOW(), NOW()),
      ('88888888-8888-8888-8888-888888888888', 'Construtora Alvorada Ltda.', '00.111.222/0001-33', 'Em Análise', 226000.00, '66666666-6666-6666-6666-666666666661', 'Diego Prado', NOW() + INTERVAL '1 day', NOW(), NOW()),
      ('99999999-9999-9999-9999-999999999999', 'Helena e Paulo Ramos', '333.444.555-66', 'Aprovada', 201000.00, '99999999-9999-9999-9999-999999999991', 'Diego Prado', NOW() - INTERVAL '2 days', NOW(), NOW()),
      ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'Otávio Lins', '777.888.999-00', 'Aprovada', 118000.00, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Carla Menezes', NOW() - INTERVAL '1 day', NOW(), NOW()),
      ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'Sandra Bertoldi', '222.333.444-55', 'Rejeitada', 268000.00, '88888888-8888-8888-8888-888888888881', 'João Vitor Salles', NOW() - INTERVAL '5 days', NOW(), NOW());
    `);
  }

  // Core service listens on 3002
  await app.listen(3002);
  console.log(`Core-Service is running on: ${await app.getUrl()}`);
}
bootstrap();
