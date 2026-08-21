# Análise Técnica e Melhorias para o Urbuzzi

Baseado no estado atual do projeto (Flutter Web/Mobile + NestJS Microsserviços), elaborei um diagnóstico completo com as próximas etapas para transformar o Urbuzzi de um MVP (Produto Mínimo Viável) em um sistema **robusto, seguro e pronto para produção**.

---

## 🏗️ 1. Backend (NestJS & Banco de Dados)

### O que precisa ser mudado:
1. **Remover `synchronize: true` do TypeORM:** Atualmente o banco é recriado ou modificado automaticamente baseado nas entidades. Isso é perigoso para produção (pode apagar ou corromper dados). **Solução:** Implementar **TypeORM Migrations** formais.
2. **Controle de Acesso (RBAC):** O Gateway repassa o `x-user-id`, mas não temos restrição rigorosa por cargo sendo checada nas rotas. **Solução:** O Core-Service deve validar perfis (ex: um "Cliente" não pode alterar o status de um lote para "Vendido", apenas um "Admin" ou "Gerente").
3. **Paginação e Filtros Nativos:** A listagem de lotes e o histórico de auditoria atualmente carregam *todos* os registros de uma vez (`findAll`). **Solução:** Implementar paginação (`limit` e `offset`) e ordenação na API.
4. **Tratamento Global de Erros:** Exceções do banco (ex: chaves duplicadas, FKs falhas) podem estar vazando pro frontend. **Solução:** Criar um `ExceptionFilter` global no NestJS para padronizar as mensagens de erro em formato amigável para o app (JSON).

---

## 📱 2. Frontend (Flutter)

### O que precisa ser mudado:
1. **Refresh de Token Automático:** O sistema de login usa JWT, mas se o token expirar, o usuário provavelmente toma erro ou é deslogado. **Solução:** Configurar um Interceptor no `Dio` para tentar fazer um *Refresh Token* automático caso a API retorne `401 Unauthorized`.
2. **Mapa Interativo (Core do App):** A `HomePage` atualmente é básica. Clicar em um mapa real é o diferencial do produto. **Solução:** Usar o package `interactive_viewer` integrado com um SVG do mapa da cidade/loteamento real, mapeando as coordenadas dos lotes para torná-los clicáveis.
3. **Máscaras e Validação (UX):** Os formulários precisam de máscaras. **Solução:** Adicionar o package `mask_text_input_formatter` para formatar CPF/CNPJ, Telefone e campos Monetários em tempo real.
4. **Infinite Scroll na Auditoria:** Com o tempo teremos milhares de logs. Carregar tudo trava a tela. **Solução:** Integrar o Riverpod com paginação, carregando os dados de 20 em 20 itens enquanto o usuário rola a página.
5. **Suporte Offline (Diferencial):** Corretores frequentemente vão em terrenos sem sinal 4G. **Solução:** Fazer cache inteligente dos Lotes disponíveis usando `shared_preferences` ou banco local (Hive), para que a tela abra imediatamente mesmo sem internet.

---

## 🚀 3. Infraestrutura e DevOps

### O que precisa ser mudado:
1. **Containerização do Flutter Web:** Hoje rodamos o Flutter via linha de comando local. Para ir para produção na nuvem, ele precisa virar um conteiner. **Solução:** Criar um `Dockerfile` no frontend que compila a versão web (`flutter build web`) e a serve num servidor Nginx leve dentro do `docker-compose.yml`.
2. **Variáveis de Ambiente (.env):** As URLs estão fixas (hardcoded) no código ou em constantes simples. **Solução:** Implementar `flutter_dotenv` no frontend para injetar `BASE_URL` dependendo de onde o projeto for publicado.
3. **Pipeline de Testes:** Não encontrei arquivos de testes estruturados no core da regra de negócio (Reservas e Propostas). Testes unitários para cálculos de SLA seriam muito importantes.

---

## 🎯 Por onde devemos começar?

As 3 melhorias de **Maior Impacto Rápido** (Quick Wins) para a evolução imediata do protótipo são:

1. **Implementar as Máscaras e Formatações Monetárias** nos inputs do frontend (para o app não aceitar dado errado).
2. **Implementar a Paginação (Backend e Frontend)** na página de Auditoria.
3. **Desativar o `synchronize: true`** e gerar a primeira Migration no backend, para garantir que não perderemos dados a partir de agora.
