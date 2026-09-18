# Urbuzzi

O **Urbuzzi** é um ecossistema completo para a gestão imobiliária e administração de loteamentos urbanos. Ele integra um painel e aplicativo móvel desenvolvidos em **Flutter** com um backend escalável em **NestJS**, arquitetado em microsserviços.

O sistema permite gerenciar clientes, status de lotes, mapas interativos, fluxo de propostas, comissões de corretores e auditoria completa de ações.

---

## 🏗️ Arquitetura e Tecnologias

### Backend (Microsserviços)
- **NestJS:** Framework principal utilizado em todos os microsserviços e no Gateway.
- **PostgreSQL:** Banco de dados relacional isolado (Database-per-service para `core_db` e `auth_db`).
- **Redis:** Gerenciamento de cache e comunicação assíncrona.
- **Docker & Docker Compose:** Orquestração completa do ambiente local com *multi-stage builds* focados em performance.
- **API Gateway:** Único ponto de entrada na porta `3000`. Responsável pelo roteamento, rate limiting (Throttler) e **validação de segurança JWT** antes das requisições atingirem a rede interna.

### Frontend (Flutter)
- **Arquitetura MVVM & Feature-First:** Separação clara de domínios lógicos (`lots`, `proposals`, `crm`, etc).
- **Gerenciamento de Estado:** Utiliza `flutter_riverpod` juntamente com `riverpod_lint` para garantir estado reativo, seguro contra memory-leaks.
- **Roteamento:** `go_router` gerenciando deeplinks e rotas internas.
- **Rede e Real-Time:** `dio` com interceptors avançados de retry, autenticação (JWT Secure Storage), e `socket.io_client` para atualizações em tempo real no mapa de lotes.

Para detalhes sobre como configurar, instalar dependências e executar os microsserviços e o aplicativo Flutter, consulte o nosso guia dedicado:

👉 **[Guia de Execução (Como Rodar o Projeto)](docs/COMO_RODAR.md)**

---

## 🔒 Segurança

- **Proteção de Credenciais:** As variáveis de ambiente do aplicativo mobile são injetadas de forma ofuscada em tempo de compilação.
- **Validação:** Todas as senhas transitam envelopadas, e os roles dos usuários são checados diretamente pelo API Gateway antes de qualquer ação no Core Service.
