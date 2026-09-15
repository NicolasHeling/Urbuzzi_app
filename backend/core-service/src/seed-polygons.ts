import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DataSource } from 'typeorm';
import { Logger } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';

async function seedPolygons() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const dataSource = app.get(DataSource);
  
  Logger.log('Iniciando script de seed de polígonos de mapa...');
  
  const seedFilePath = path.join(__dirname, '../../map_seed.json');
  
  if (!fs.existsSync(seedFilePath)) {
    Logger.error(`Arquivo não encontrado: ${seedFilePath}`);
    process.exit(1);
  }

  const fileContent = fs.readFileSync(seedFilePath, 'utf-8');
  const polygons: { block: string, number: string, mapPolygons: number[][] }[] = JSON.parse(fileContent);
  
  Logger.log(`Lidos ${polygons.length} polígonos do arquivo JSON.`);
  
  let updatedCount = 0;
  
  // Como block é string (ex: 'A', 'B') mas no map_data.dart era '01', '02',
  // Precisamos converter: '01' -> 'A', '02' -> 'B', etc.
  for (const poly of polygons) {
    const blockInt = parseInt(poly.block, 10);
    const blockChar = String.fromCharCode(64 + blockInt); // 1 -> A, 2 -> B
    
    // Converte o número de lote ('01' -> '01')
    const numberStr = poly.number; // Já é string no entity
    
    // Tenta achar o lote no banco de dados e atualizar
    const result = await dataSource.query(
      `UPDATE lots SET "mapPolygons" = $1 WHERE block = $2 AND number = $3 RETURNING id`,
      [JSON.stringify(poly.mapPolygons), blockChar, numberStr]
    );
    
    if (result[1] > 0) {
      updatedCount++;
    } else {
      // Se o lote ainda não existe no banco, podemos inseri-lo como "Reservado/Indisponível" para que apareça no mapa?
      // Neste caso, vamos apenas atualizar os que existem, pois o map_data.dart tem 192 lotes, mas o banco tem apenas 12 de seed original.
      // E é normal, os lotes são criados depois.
    }
  }
  
  Logger.log(`✅ Seed concluído! ${updatedCount} lotes atualizados com polígonos.`);
  
  await app.close();
  process.exit(0);
}

seedPolygons().catch(err => {
  console.error(err);
  process.exit(1);
});
