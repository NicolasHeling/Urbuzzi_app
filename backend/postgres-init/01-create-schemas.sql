-- Criação idempotente dos bancos de dados
SELECT 'CREATE DATABASE auth_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'auth_db')\gexec
SELECT 'CREATE DATABASE core_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'core_db')\gexec
