# Urbuzzi

Este projeto constitui um ecossistema completo de microsserviços e um app mobile para o gerenciamento interativo de lotes urbanos, integrando um backend escalável com um aplicativo Flutter robusto.

A aplicação original (Vanilla JS/HTML) foi arquivada na pasta `legacy_html/` para referência futura.

## Padrões Arquiteturais e Componentes

### 1. Backend (NestJS + PostgreSQL)
- **API Gateway:** Único ponto de entrada na porta `3010` (no ambiente de testes local rodando no docker). Centraliza a validação JWT, Rate Limiting, Helmet e encaminha requisições de forma segura.
- **Auth Service:** Microsserviço independente (porta `3001`) responsável pela entidade `User` e autenticação (Login, Registro, Refresh Tokens, Geração de JWT).
- **Core Service:** Microsserviço independente (porta `3002`) que gerencia a regra de negócio central: `Lots` (Lotes), `Proposals` (Propostas) e `AuditLogs` (Histórico de auditoria).
- **Database per Service:** Cada serviço se conecta a um banco de dados logicamente isolado no PostgreSQL (`auth_db`, `core_db`), garantindo forte segurança e encapsulamento de dados.
- **Orquestração e Build:** Todo o backend sobe perfeitamente com um `docker-compose up`. Os contêineres usam Multi-stage builds para máxima performance e baixo consumo de recursos.

### 2. Frontend (Flutter)
- **Framework:** Flutter (`urbuzzi_app/`).
- **Arquitetura MVVM & Feature-First:** O código em `lib/features` é segmentado logicamente por domínio (home, lots, proposals, audit).
- **Gerenciamento de Estado:** A aplicação utiliza `flutter_riverpod` para gerenciar estado global de forma reativa e eficiente (como fluxo de autenticação via repositório de JWT seguro).
- **Roteamento Centralizado:** As rotas ficam centralizadas no arquivo `app_routes.dart`, que integra o menu lateral (`Drawer`) e transições.

## Como Iniciar a Aplicação

### 1. Backend
```bash
cd backend
docker-compose up --build -d
```
Isso criará automaticamente os bancos de dados, aplicará as migrações/entidades e inicializará o **Gateway** e todos os **Microsserviços**.

### 2. Frontend (App Mobile e Desktop)
*(Certifique-se de ter o Flutter instalado e configurado na sua máquina)*
```bash
cd urbuzzi_app
flutter pub get
```

Para rodar extraindo o máximo de performance no Windows:
```bash
flutter run -d windows --release
```
