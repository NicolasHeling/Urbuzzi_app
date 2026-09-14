import { DataSource, DataSourceOptions } from 'typeorm';
import { join } from 'path';

// Validate required environment variables at boot
const requiredEnvVars = ['DB_HOST', 'DB_PASS'];
for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    console.warn(`[Core-Service] Variável de ambiente ${envVar} não configurada. Usando valor padrão.`);
  }
}

export const dataSourceOptions: DataSourceOptions = {
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  username: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASS || 'postgres',
  database: process.env.DB_NAME || 'core_db',
  entities: [join(__dirname, '**', '*.entity.{ts,js}')],
  migrations: [join(__dirname, 'migrations', '*.{ts,js}')],
  synchronize: false,
  // Connection pool: otimizado para produção
  extra: {
    max: 20,               // Máximo de conexões no pool
    idleTimeoutMillis: 30000, // Timeout de conexão ociosa (30s)
    connectionTimeoutMillis: 5000, // Timeout para obter conexão (5s)
  },
};

const dataSource = new DataSource(dataSourceOptions);
export default dataSource;
