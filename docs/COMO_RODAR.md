# 🚀 Guia de Execução (Como Rodar o Projeto)

Este documento contém todas as instruções necessárias para você configurar, instalar e rodar o ecossistema Urbuzzi (Backend e Frontend) na sua máquina local.

---

## 1. Pré-requisitos

Certifique-se de ter as seguintes ferramentas instaladas em seu ambiente:
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (com Docker Compose)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão `^3.7.1`)
- [Node.js](https://nodejs.org/en/) (versão `20.x` - opcional, apenas caso queira rodar os microsserviços fora do Docker para debug avançado)

---

## 2. Inicializando o Backend (Docker)

O backend do Urbuzzi foi orquestrado para subir de forma 100% automatizada. O Docker construirá as imagens do `API Gateway`, do `Auth Service`, do `Core Service`, além de provisionar o banco de dados `PostgreSQL` e o `Redis`.

1. Abra um terminal na raiz do projeto e navegue até a pasta do backend:
   ```bash
   cd backend
   ```

2. Execute o comando para construir e iniciar os contêineres em segundo plano:
   ```bash
   docker-compose up --build -d
   ```

3. **Portas Expostas:**
   - **API Gateway:** `http://localhost:3000` (Use esta URL no seu frontend)
   - **Banco de Dados (PostgreSQL):** `localhost:5432` (Útil se quiser conectar usando DBeaver ou PgAdmin)
   - **Redis:** `localhost:6379`

### Trabalhando com o Banco de Dados (Migrations)

O projeto usa TypeORM. Caso você adicione ou modifique entidades no `core-service`, será necessário gerar uma migração. Como o banco de dados roda no Docker, você pode gerar as migrations direto da sua máquina (via PowerShell no Windows):

```powershell
cd backend/core-service
npm install

# Defina a senha do banco (conforme o .env)
$env:DB_PASS="UrbuzziStr0ng!P@ssw0rd2024" 

# Para gerar uma nova migration baseada nas suas entidades:
npm run migration:generate

# Para aplicar a migration no banco de dados local:
npm run migration:run
```

---

## 3. Inicializando o Frontend (App Flutter)

O aplicativo foi projetado para consumir variáveis de ambiente em tempo de compilação via `--dart-define`. Isso impede que chaves sensíveis fiquem expostas dentro do pacote do aplicativo.

1. Navegue até a pasta do aplicativo e instale as dependências:
   ```bash
   cd urbuzzi_app
   flutter pub get
   ```

2. Escolha a plataforma que deseja emular e rode o comando injetando a variável do Gateway:

**Para rodar no Windows (Desktop) - Maior Performance:**
```bash
flutter run -d windows --dart-define=API_URL_WEB=http://localhost:3000
```

**Para rodar no Emulador Android:**
*(Nota: O emulador Android acessa o `localhost` da sua máquina através do IP interno `10.0.2.2`)*
```bash
flutter run -d android --dart-define=API_URL_ANDROID=http://10.0.2.2:3000
```

**Para rodar no Navegador (Web):**
```bash
flutter run -d chrome --dart-define=API_URL_WEB=http://localhost:3000
```

---

## 4. Dicas Úteis de Desenvolvimento

- **Visualizando Logs do Backend:** 
  Se houver algum erro de API, você pode verificar os logs dos serviços Docker com:
  ```bash
  docker logs backend-core-service-1 -f
  docker logs backend-gateway-1 -f
  ```
- **Limpeza do Banco:** 
  Se quiser "zerar" os dados do banco de dados, você pode derrubar os contêineres e deletar os volumes:
  ```bash
  cd backend
  docker-compose down -v
  ```
