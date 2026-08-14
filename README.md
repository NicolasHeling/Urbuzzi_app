# Urbuzzi 

Este projeto foi completamente reescrito para utilizar os padrões arquiteturais de nível corporativo aplicados no repositório **DoseCerta**. A aplicação original (Vanilla JS/HTML) foi movida para `legacy_html/` e agora o projeto é constituído por um ecossistema completo de microsserviços e um app mobile.

## Padrões Adotados (Estilo DoseCerta)

### 1. Backend (NestJS + PostgreSQL)
- **API Gateway:** Único ponto de entrada na porta `3000`. Centraliza a validação JWT e encaminha requisições.
- **Auth Service:** Microsserviço independente (porta `3001`) responsável pela entidade `User` e autenticação (Login, Registro, Geração de JWT).
- **Core Service:** Microsserviço independente (porta `3002`) que gerencia a regra de negócio central: `Lots` (Lotes), `Proposals` (Propostas) e `AuditLogs` (Histórico de auditoria).
- **Database per Service:** Cada serviço se conecta a um banco isolado no PostgreSQL (`auth_db`, `core_db`), garantindo forte encapsulamento.
- **Orquestração:** Todo o backend sobe com apenas um `docker-compose up` (porta `3000` pro gateway, e `5432` pro postgres).
*Nota: Diferente do DoseCerta original, não há necessidade do RabbitMQ ou mensageria assíncrona, pois os módulos foram simplificados para o contexto da Urbuzzi.*

### 2. Frontend (Flutter / MVVM)
- **Framework:** Flutter (`urbuzzi_app/`).
- **Arquitetura MVVM & Feature-First:** O código em `lib/features` é separado por domínio (home, lots, proposals, audit).
- **Injeção de dependências & Estado:** Preparado para usar `flutter_riverpod`, isolando as camadas lógicas das telas visuais, nos mesmos moldes do DoseCerta.
- **Rotas Globais:** Classe estática `AppRoutes` mapeia os caminhos (`/home`, `/lots`, `/proposals`, `/audit`).

## Como Iniciar

### Iniciar Backend
```bash
cd backend
docker-compose up --build -d
```
Isso criará automaticamente as bases de dados e iniciará o **Gateway** e os **Microsserviços**.

### Iniciar Frontend (App)
*(Certifique-se de ter o Flutter instalado na sua máquina)*
```bash
cd urbuzzi_app
flutter pub get
flutter run
```
